################################################################################
# File     : Makefile
# Author   : David Gussler
# Language : gnu make
# ==============================================================================
# Project maintenance
################################################################################
-include local.mk

################################################################################
# Project Settings
################################################################################
PROJECT_NAME := template
PROJECT_VERSION := 0.1.1
REQUIRE_VIVADO_VER := v2025.2


################################################################################
# Rules
################################################################################

# Defaults (can be overridden by local.mk)
BOARD ?= basys3
JOBS ?= 2
VIVADO ?= $(shell which vivado 2>/dev/null)

# Check the Vivado version
define check_vivado
	@if ! command -v $(VIVADO) >/dev/null 2>&1; then \
		echo "ERROR: Vivado binary '$(VIVADO)' could not be found. Check your PATH or local.mk."; \
		exit 1; \
	fi; \
	v=$$($(VIVADO) -version | awk '/vivado/ {print $$2; exit}'); \
	if [ "$$v" != "$(REQUIRE_VIVADO_VER)" ]; then \
		echo "ERROR: Requires Vivado $(REQUIRE_VIVADO_VER) (found $$v)"; \
		exit 1; \
	fi
endef

THIS_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
SRC_DIR := $(THIS_DIR)src
TEST_DIR := $(THIS_DIR)test
BUILD_DIR := $(THIS_DIR)build
DOC_DIR := $(THIS_DIR)doc
LIB_DIR := $(THIS_DIR)lib
BOARD_DIR := $(THIS_DIR)boards
VENV_DIR = $(THIS_DIR).build_venv
BOARD_LIST := $(notdir $(wildcard boards/*))
VER_STRING := v$(PROJECT_VERSION)
BUILD_NAME := $(PROJECT_NAME)_$(VER_STRING)-$(BOARD)
RELEASE_DIR := $(BUILD_DIR)/$(BUILD_NAME)
REGS_SRC := $(SRC_DIR)/*/regs/*.toml $(LIB_DIR)/sblib/src/*/regs/*.toml
STYLE_SRC := $(SRC_DIR)/*/hdl/*.vhd $(BOARD_DIR)/*/hdl/*.vhd $(TEST_DIR)/*/*.vhd
PYTHON := $(VENV_DIR)/bin/python
PIP := $(VENV_DIR)/bin/pip
VSG := $(VENV_DIR)/bin/vsg
XPR_FILE := $(BUILD_DIR)/vivado_out/$(PROJECT_NAME)_$(BOARD)/$(PROJECT_NAME)_$(BOARD).xpr

# Phony rules
.PHONY: package build release proj sim regs style style-fix tool-check clean all

# Run the complete build procedure for ALL boards
all:
	@{ \
	for brd in $(BOARD_LIST); do \
		echo "INFO: Building board $$brd..."; \
		$(MAKE) build BOARD=$$brd; \
		$(MAKE) package BOARD=$$brd; \
	done; \
	}

# Package the built files
package:
	cd $(BUILD_DIR) && tar -czvf $(BUILD_NAME).tar.gz $(BUILD_NAME)

# Build the FPGA with Vivado
build: $(BUILD_DIR)/regs_out/.stamp $(XPR_FILE)
	$(call check_vivado)
	cd scripts && $(VIVADO) -mode batch -nojournal -nolog -notrace \
	-source build.tcl \
	-tclargs $(PROJECT_NAME) $(BOARD) $(PROJECT_VERSION) $(JOBS)

# Create the FPGA Vivado project
proj: $(XPR_FILE)
$(XPR_FILE): $(BUILD_DIR)/regs_out/.stamp
	cd scripts && $(VIVADO) -mode batch -nojournal -nolog -notrace \
	-source proj.tcl \
	-tclargs $(PROJECT_NAME) $(BOARD)

# Run the VUnit simulation
sim: $(BUILD_DIR)/regs_out/.stamp
	cd scripts && $(PYTHON) sim.py --vhdl_ls
	cd scripts && $(PYTHON) sim.py --xunit-xml $(BUILD_DIR)/sim_report.xml

# Check the coding style of the VHDL src files
style: $(VENV_DIR)/.stamp $(STYLE_SRC)
	mkdir -p $(BUILD_DIR)
	$(VSG) -f $(STYLE_SRC) \
	-c vsg_rules.yaml \
	-of vsg \
	--all_phases \
	--quality_report $(BUILD_DIR)/style_report.json

# Check AND FIX the coding style of the VHDL src files
style-fix: $(VENV_DIR)/.stamp $(STYLE_SRC)
	mkdir -p $(BUILD_DIR)
	$(VSG) -f $(STYLE_SRC) \
	-c vsg_rules.yaml \
	-of vsg \
	--fix

# Generate register output products
$(BUILD_DIR)/regs_out/.stamp: $(VENV_DIR)/.stamp $(REGS_SRC)
	cd scripts && $(PYTHON) regs.py $(REGS_SRC)
	touch $(BUILD_DIR)/regs_out/.stamp

# Install venv and python packages
$(VENV_DIR)/.stamp: build-requirements.txt
	test -d $(VENV_DIR) || python3 -m venv $(VENV_DIR)
	$(PIP) install --upgrade pip
	$(PIP) install -r build-requirements.txt
	touch $(VENV_DIR)/.stamp

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
	@echo "may be changed by modifying the PROJECT_VERSION Makefile variable."
	@echo
	@echo "NOTICE: Before proceeding, don't forget to update CHANGELOG.md with the"
	@echo "details of this release."
	@echo
	@read -p "Do you want to proceed? (y/n): " user_input; \
	if [ "$$user_input" != "y" ]; then \
		echo "Aborting..."; \
		exit 1; \
	fi
	git tag -a $(VER_STRING) -m "Release $(VER_STRING)"
	git push origin $(VER_STRING)

clean:
	rm -rf $(BUILD_DIR) $(VENV_DIR) scripts/__pycache__ scripts/vunit_out
