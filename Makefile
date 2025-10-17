################################################################################
# File     : Makefile
# Author   : David Gussler
# Language : gnu make
# ==============================================================================
# Project maintenance
################################################################################

################################################################################
# Configuration Settings
################################################################################

# FPGA Project Version
# Use semantic versioning with respect to the register API. Each version 
# variable may range from 0 to 255.
# Update the version and add appropriate notes to the CHANGELOG.md each time 
# a new tag is released
VER_MAJOR := 0
VER_MINOR := 1
VER_PATCH := 0

# Required project build tool versions
REQUIRE_VIVADO_VER := v2024.2
REQUIRE_REGS_VER   := 8.0.0
REQUIRE_VSG_VER    := 3.30.0
REQUIRE_VUNIT_VER  := 5.0.0.dev6


# Select the target hardware platform to build. Must match one of the
# directories in "platforms". This variable can be set from the command line,
# for example "make PLATFORM=basys3". Running "make all" will automatically find
# and make all of the target platforms.
PLATFORM ?= basys3

# Number of processor threads to use for builds
JOBS ?= 16



################################################################################
# Rules
################################################################################

# Check a Python package version
define check_python_pkg_ver
	@v=$$(python -m pip show $(1) 2>/dev/null | awk '/Version:/ {print $$2}'); \
	if [ "$$v" != "$($(2))" ]; then \
		echo "ERROR: Requires $(1) version $($(2)) (found $$v)"; \
		exit 1; \
	fi
endef

# Check the Vivado version
define check_vivado_ver
	@v=$$(vivado -version | awk '/vivado/ {print $$2; exit}'); \
	if [ "$$v" != "$(REQUIRE_VIVADO_VER)" ]; then \
		echo "ERROR: Requires Vivado $(REQUIRE_VIVADO_VER) (found $$v)"; \
		exit 1; \
	fi
endef

MAKEFILE_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
PROJECT_NAME := $(notdir $(patsubst %/,%,$(MAKEFILE_DIR)))
PLATFORM_LIST := $(notdir $(wildcard platforms/*))
SRC_DIR := $(MAKEFILE_DIR)src
TEST_DIR := $(MAKEFILE_DIR)test
BUILD_DIR := $(MAKEFILE_DIR)build
DOC_DIR := $(MAKEFILE_DIR)doc
LIB_DIR := $(MAKEFILE_DIR)lib
PLATS_DIR := $(MAKEFILE_DIR)platforms
VER_STRING := v$(VER_MAJOR).$(VER_MINOR).$(VER_PATCH)
BUILD_NAME := $(PROJECT_NAME)_$(VER_STRING)-$(PLATFORM)
RELEASE_DIR := $(BUILD_DIR)/$(BUILD_NAME)
REGS_SRC := $(SRC_DIR)/*/regs/*.toml $(LIB_DIR)/sblib-open/src/*/regs/*.toml
STYLE_SRC := $(SRC_DIR)/*/hdl/*.vhd $(PLATS_DIR)/*/hdl/*.vhd $(TEST_DIR)/*/*.vhd

# Get the platform info
include $(PLATS_DIR)/$(PLATFORM)/platform.mk

# Phony rules
.PHONY: package build release lint proj sim regs style style-fix tool-check clean update-libs all


# Run the complete build procedure for ALL platforms
all:
	$(MAKE) tool-check
	@{ \
	for plat in $(PLATFORM_LIST); do \
		$(MAKE) proj PLATFORM=$${plat} JOBS=$(JOBS); \
		$(MAKE) build PLATFORM=$${plat} JOBS=$(JOBS); \
		$(MAKE) package PLATFORM=$${plat} JOBS=$(JOBS); \
	done; \
	}	

# If this passes, then your environment is configured correctly
tool-check:
	@echo "INFO: Checking tools..."
	$(call check_vivado_ver)
	$(call check_python_pkg_ver,hdl_registers,REQUIRE_REGS_VER)
	$(call check_python_pkg_ver,vsg,REQUIRE_VSG_VER)
	$(call check_python_pkg_ver,vunit_hdl,REQUIRE_VUNIT_VER)
	@echo "INFO: Tool check passed."

# Package the built files
package: regs
	cd $(BUILD_DIR) && tar -czvf $(BUILD_NAME).tar.gz $(BUILD_NAME)

update-libs:
	git subtree pull --prefix lib/sblib-open https://github.com/shrikebyte/sblib-open.git main --squash

# Build the FPGA with Vivado
build: regs
	cd tools && vivado -mode batch -nojournal -nolog -notrace -source build.tcl -tclargs $(PROJECT_NAME) $(PLATFORM) $(PLATFORM_DEVICE_ID) $(VER_MAJOR) $(VER_MINOR) $(VER_PATCH) $(JOBS)

# Create the FPGA Vivado project
proj: regs
	cd tools && vivado -mode batch -nojournal -nolog -notrace -source proj.tcl -tclargs $(PROJECT_NAME) $(PLATFORM) $(PLATFORM_PART) 

# Run the VUnit simulation
sim: regs
	cd tools && python sim.py --xunit-xml $(BUILD_DIR)/sim_report.xml

# Check the coding style of the VHDL src files
style:
	mkdir -p $(BUILD_DIR)
	vsg -f $(STYLE_SRC) -c ./tools/vsg_rules.yaml -of vsg --all_phases --quality_report $(BUILD_DIR)/style_report.json

# Check AND FIX the coding style of the VHDL src files
style-fix:
	mkdir -p $(BUILD_DIR)
	vsg -f $(STYLE_SRC) -c ./tools/vsg_rules.yaml -of vsg --fix

# Generate the register output products
regs:
	cd tools && python regs.py $(REGS_SRC)

# Create a new git tag and Github release for this version of the code. A Github
# action will generate the release from source.
release:
	@if ! git diff-index --quiet HEAD --; then \
		echo "ERROR: Uncommitted changes detected. Commit them before proceeding." >&2; \
		exit 1; \
	fi
	@echo "Last tag: $(shell git describe --tags --abbrev=0 2>/dev/null || echo "NA")"
	@echo "New tag : $(VER_STRING)"
	@echo
	@echo "NOTICE: If the value for the new tag is unacceptable, then the tag"
	@echo "may be changed by modifying the VER_* Makefile variables."
	@echo
	@echo "NOTICE: Before proceeding, don't forget to update CHANGELOG.md with the"
	@echo "details of this release."
	@echo
	@echo "NOTICE: A Github action that builds and releases this version of the FPGA"
	@echo "will be triggered."
	@echo
	@read -p "Do you want to proceed? (y/n): " user_input; \
	if [ "$$user_input" != "y" ]; then \
		echo "Aborting..."; \
		exit 1; \
	fi
	git tag -a $(VER_STRING) -m "Release $(VER_STRING)" 
	git push origin $(VER_STRING)

clean:
	rm -rf build
