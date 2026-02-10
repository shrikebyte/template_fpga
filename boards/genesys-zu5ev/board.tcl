################################################################################
# Build target configuration
################################################################################
set board_dir [file dirname [info script]]
set root_dir [file normalize $board_dir/../..]

set FPGA_PART "xczu5ev-sfvc784-1-e"
set FPGA_TOP "fpga"
set FPGA_ID "00000008"
set SYNTH_STRATEGY "Default"
set IMPL_STRATEGY "Default"
set CHECK_TIMING true
set CHECK_CDC false

set SRC_HDL [list \
  $board_dir/hdl/* \
  $root_dir/src/adder/hdl/*
  $root_dir/lib/sblib/src/bus/hdl/axil_arbiter.vhd
  $root_dir/lib/sblib/src/bus/hdl/axil_decoder.vhd
  $root_dir/lib/sblib/src/bus/hdl/axil_xbar.vhd
  $root_dir/lib/sblib/src/stdver/hdl/*
  $root_dir/lib/sblib/src/cdc/hdl/cdc_bit.vhd
  $root_dir/build/regs_out/adder/hdl/*
  $root_dir/build/regs_out/sdtver/hdl/*
]

set SRC_CNSTR [list \
  $board_dir/cnstr/* \
]

set SRC_CNSTR_SCOPED [list \
  $root_dir/lib/sblib/src/cdc/cnstr/cdc_bit.tcl
]

set SRC_IP [list \
  $board_dir/ip/* \
]
