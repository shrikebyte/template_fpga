################################################################################
# File: proj.tcl
# Auth: David Gussler
# ==============================================================================
# Create Vivado project from source
################################################################################

if { $argc != 2 } {
  puts "ERROR: Script usage - proj.tcl <project_name> <board_name>"
  exit
}
set proj_name [lindex $argv 0]
set board_name [lindex $argv 1]

set script_dir [file normalize [file dirname [info script]]]
set root_dir [file normalize ${script_dir}/../]
set board_dir [file normalize ${root_dir}/boards/${board_name}]
set proj_dir [file normalize ${root_dir}/build/vivado_out/${proj_name}_${board_name}]

source $board_dir/board.tcl

create_project -force ${proj_name}_${board_name} $proj_dir -part $FPGA_PART

add_files -fileset sources_1 $SRC_HDL
add_files -fileset constrs_1 $SRC_CNSTR

foreach cnstrfile $SRC_CNSTR_SCOPED {
  set refname [file tail $cnstrfile]
  set refname [file rootname $refname]
  read_xdc -unmanaged -ref $refname $cnstrfile
}

foreach tclfile $SRC_IP {
  source $tclfile
}

set_property target_language VHDL [current_project]
set_property simulator_language Mixed [current_project]
set_property enable_vhdl_2008 1 [current_project]
set_property file_type {VHDL 2008} [get_files -filter {FILE_TYPE == VHDL}]
set_property top $FPGA_TOP [current_fileset]
update_compile_order -fileset sources_1

puts "All done... Great success!"
