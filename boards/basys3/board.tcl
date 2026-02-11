################################################################################
# Build target configuration
################################################################################
set board_dir [file dirname [info script]]
set root_dir [file normalize $board_dir/../..]

set FPGA_PART "xc7a35tcpg236-1"
set FPGA_TOP "basys3_fpga"
set FPGA_ID "00000008"
set SYNTH_STRATEGY "Vivado Synthesis Defaults"
set IMPL_STRATEGY "Vivado Implementation Defaults"
set CHECK_TIMING true
set CHECK_CDC false

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

set SRC_CNSTR [glob \
  $board_dir/cnstr/* \
]

set SRC_CNSTR_SCOPED [glob \
  $root_dir/lib/sblib/src/cdc/cnstr/cdc_bit.tcl \
]

set SRC_IP [glob \
  $board_dir/ip/* \
]
