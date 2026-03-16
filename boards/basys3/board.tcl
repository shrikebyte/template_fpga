################################################################################
# Build target configuration
################################################################################
set board_dir [file dirname [info script]]
set root_dir [file normalize $board_dir/../..]

# Project settings
set FPGA_PART "xc7a35tcpg236-1"
set FPGA_TOP "basys3_fpga"
set FPGA_ID "00000008"
set SYNTH_STRATEGY "Vivado Synthesis Defaults"
set IMPL_STRATEGY "Vivado Implementation Defaults"
set CHECK_TIMING true
set CHECK_CDC false
set WRITE_XSA true
set WRITE_MCS false
set MCS_SIZE_MBYTES 64

# HDL source files
set SRC_HDL [glob \
  $root_dir/lib/sblib/src/util/hdl/util_pkg.vhd \
  $root_dir/lib/sblib/src/cdc/hdl/cdc_bit.vhd \
  $root_dir/lib/sblib/src/hdlm/hdl/* \
  $root_dir/lib/sblib/src/bus/hdl/axil_arbiter.vhd \
  $root_dir/lib/sblib/src/bus/hdl/axil_decoder.vhd \
  $root_dir/lib/sblib/src/bus/hdl/axil_xbar.vhd \
  $root_dir/lib/sblib/src/stdver/hdl/* \
  $root_dir/build/regs_out/stdver/hdl/* \
  $root_dir/build/regs_out/adder/hdl/* \
  $root_dir/src/adder/hdl/* \
  $board_dir/hdl/* \
]

# Top-level constraints
set SRC_CNSTR [glob \
  $board_dir/cnstr/* \
]

# Scoped constraints. These constraints are only applied to modules that match
# their file name. For example: cdc_bit.tcl is only applied to cdc_bit.vhd
set SRC_CNSTR_SCOPED [glob \
  $root_dir/lib/sblib/src/cdc/cnstr/cdc_bit.tcl \
]

# IP sources. These should be tcl scripts for generating IPs or block designs.
set SRC_IP [glob \
  $board_dir/ip/* \
]
