################################################################################
# File: proj.tcl
# Auth: David Gussler
# Lang: Vivado TCL
# ==============================================================================
# Create a Vivado project from sources
################################################################################

# Parse input args
if { $argc != 3 } {
  puts "ERROR: Script usage - proj.tcl <project_name> <platform_name> <part_number>"
  exit
}
set proj_name [lindex $argv 0]
set plat_name [lindex $argv 1]
set part_num [lindex $argv 2]

set script_dir [file dirname [info script]]
set proj_dir ${script_dir}/../build/vivado_out/${proj_name}_${plat_name}
set src_dir ${script_dir}/../src
set regs_dir ${script_dir}/../build/regs_out/
set lib_dir ${script_dir}/../lib
set plat_src_dir ${script_dir}/../platforms/${plat_name}

# Create the project
create_project -force ${proj_name}_${plat_name} $proj_dir -part $part_num

# Project properties
set_property target_language VHDL [current_project]
set_property simulator_language Mixed [current_project]
set_property enable_vhdl_2008 1 [current_project]

# Add project HDL source files 
add_files -fileset sources_1 [ glob -nocomplain -- \
  $src_dir/*/hdl/* \
  $lib_dir/*/src/*/hdl/* \
  $regs_dir/*/hdl/* \
  $plat_src_dir/hdl/* \
]

# Set VHDL files to VHDL'08
set_property file_type {VHDL 2008} [get_files -filter {FILE_TYPE == VHDL}]

# Add top-level platform constraints
add_files -fileset constrs_1 [ glob -nocomplain -- \
  $plat_src_dir/cnstr/* \
]

# Set the target constraints file. This file is managed by Vivado, not the user.
set_property target_constrs_file $plat_src_dir/cnstr/vivado.xdc [current_fileset -constrset]

# Physical constraints only need to be enabled for implementation, not synthesis
set_property used_in_synthesis false [get_files $plat_src_dir/cnstr/pins.xdc]
set_property used_in_synthesis false [get_files $plat_src_dir/cnstr/config.xdc]

# Add submodule scoped constraints
foreach cnstrfile [glob -nocomplain -- $src_dir/*/cnstr/* $lib_dir/*/src/*/cnstr/*] {
  set refname [file tail $cnstrfile]
  set refname [file rootname $refname]
  read_xdc -unmanaged -ref $refname $cnstrfile
}

# Generate BDs and IPs from tcl
foreach tclfile [glob -nocomplain -- $plat_src_dir/ip/*.tcl $src_dir/*/ip/*.tcl $lib_dir/*/src/*/ip/*.tcl] {
  source $tclfile
}

# Tell Vivado which entity is the top-level
set_property top chip [current_fileset]
update_compile_order -fileset sources_1

puts "All done... Great success!"
