################################################################################
# File: build.tcl
# Auth: David Gussler
# ==============================================================================
# Build FPGA binaries with Vivado
################################################################################


################################################################################
# Procedures
################################################################################

# Current date, time, and seconds since epoch
# 0 = 4-digit year
# 1 = 2-digit year
# 2 = 2-digit month
# 3 = 2-digit day
# 4 = 2-digit hour
# 5 = 2-digit minute
# 6 = 2-digit second
# 7 = Epoch (seconds since 1970-01-01_00:00:00)
proc getDateTime {} {

  # Array index                                   0  1  2  3  4  5  6  7
  set datetime_arr [clock format [clock seconds] -format {%Y %y %m %d %H %M %S 00}]
  # Example :
  # 2020 20 05 27 13 45 45 00

  # Get the datecode in the yyyy-mm-dd format
  set datecode [lindex $datetime_arr 0][lindex $datetime_arr 2][lindex $datetime_arr 3]
  # Get the timecode in the hh-mm-ss format
  set timecode [lindex $datetime_arr 4][lindex $datetime_arr 5][lindex $datetime_arr 6]
  # Show this in the log
  puts "Build Date = $datecode"
  puts "Build Time = $timecode"

  return [ list $datecode $timecode ]
}


# Returns the git hash for this project
# Also determine if the repo is "dirty" (has uncommitted changes)
proc getGitHash {} {

  set saved_dir [pwd]
  cd [file dirname [info script]]

  if { [catch {exec git rev-parse --short=8 HEAD}] } {
    puts "#########################################################################"
    puts "## WARNING: No git version control in $proj_dir directory"
    puts "#########################################################################"
    set git_hash DEADBEEF
    set git_dirty 1
  } else {
    set git_hash [exec git rev-parse --short=8 HEAD]
    set git_dirty [catch { exec git diff-index --quiet HEAD -- }]
  }

  if {$git_dirty} {
    puts "#########################################################################"
    puts "## WARNING: Build started with a dirty repository."
    puts "#########################################################################"
  } else {
    puts "#########################################################################"
    puts "## INFO: Build started with a clean repository"
    puts "#########################################################################"
  }
  puts "Git Hash = $git_hash"

  cd $saved_dir

  return [ list $git_dirty $git_hash ]
}

# Figure out if this build has been initiated from a local engineer's PC or
# from a CI server
proc getLocalBuildStatus {} {

  if { [info exists ::env(CI)] } {
    set local_build 0
    puts "#########################################################################"
    puts "## INFO: This is a CI build"
    puts "#########################################################################"
  } else {
    set local_build 1
    puts "#########################################################################"
    puts "## INFO: This is a local build"
    puts "#########################################################################"
  }
  return $local_build
}

# Figure out if this is a release or development build. The CI server should set
# this env variable when a new tag is committed.
proc getDevBuildStatus {} {

  if { [info exists ::env(FPGA_RELEASE_BUILD)] } {
    set dev_build 0
    puts "#########################################################################"
    puts "## INFO: This is an official release build"
    puts "#########################################################################"
  } else {
    set dev_build 1
    puts "#########################################################################"
    puts "## INFO: This is a development build"
    puts "#########################################################################"
  }
  return $dev_build
}


# Print the last N lines of a file
proc tail {filename {num_lines 20}} {
  set fp [open $filename r]
  set content [read $fp]
  close $fp
  set lines [split $content "\n"]
  set last_n [lrange $lines end-[expr {$num_lines - 1}] end]
  puts [join $last_n "\n"]
}


################################################################################
# Setup variables
################################################################################
if { $argc != 6 } {
  puts "ERROR: Script usage - build.tcl <project_name> <board_name> <ver_maj> <ver_min> <ver_pat> <jobs>"
  exit
}
set proj_name [lindex $argv 0]
set board_name [lindex $argv 1]
set ver_major [lindex $argv 2]
set ver_minor [lindex $argv 3]
set ver_patch [lindex $argv 4]
set num_cpus  [lindex $argv 5]

set build_time_start [clock seconds]
set host_name [info hostname]
set script_dir [file normalize [file dirname [info script]]]
set root_dir [file normalize ${script_dir}/../]
set build_date_time [getDateTime]
set build_date [lindex $build_date_time 0]
set build_time [lindex $build_date_time 1]
set git_dirty_hash [getGitHash]
set git_dirty [lindex $git_dirty_hash 0]
set git_hash [lindex $git_dirty_hash 1]
set local_build [getLocalBuildStatus]
set dev_build [getDevBuildStatus]
set proj_dir [file normalize ${root_dir}/build/vivado_out/${proj_name}_${board_name}]
set board_dir [file normalize ${root_dir}/boards/${board_name}]

source $board_dir/board.tcl

foreach value [list $ver_major $ver_minor $ver_patch] {
  if { $value < 0 || $value > 255 } {
    puts "ERROR: version number out of range (0-255): $value"
    exit 1
  }
}
puts "Major version: $ver_major"
puts "Minor version: $ver_minor"
puts "Patch version: $ver_patch"
set ver_string "v${ver_major}.${ver_minor}.${ver_patch}"
set build_name ${proj_name}_${ver_string}-${board_name}
set release_dir [file normalize ${root_dir}/build/${build_name}]

################################################################################
# Run the build
################################################################################
puts "INFO: Starting build with $num_cpus jobs."

# Open the project if it's not already open
if {[catch current_project] != 0} {
  open_project ${proj_dir}/${proj_name}_${board_name}.xpr
}

set top_entity [lindex [find_top] 0]

# Create the build release directory
set build_name ${proj_name}_${ver_string}-${board_name}
if {![file isdirectory $release_dir]} {
  file mkdir $release_dir
}
puts "Build Directory = $release_dir"

# Set build-time generics
set_property generic " \
  G_DEVICE_ID=32'h$FPGA_ID \
  G_VER_MAJOR=$ver_major \
  G_VER_MINOR=$ver_minor \
  G_VER_PATCH=$ver_patch \
  G_LOCAL_BUILD=1'b$local_build \
  G_DEV_BUILD=1'b$dev_build \
  G_GIT_DIRTY=1'b$git_dirty \
  G_GIT_HASH=32'h$git_hash \
  G_BUILD_DATE=32'h$build_date \
  G_BUILD_TIME=24'h$build_time \
" [current_fileset]

# Run strategies
set_property strategy $SYNTH_STRATEGY [get_runs synth_1]
set_property strategy $IMPL_STRATEGY [get_runs impl_1]

# Synthesis
reset_runs synth_1
launch_runs synth_1 -jobs $num_cpus
wait_on_runs [get_runs synth_1] -quiet

# Exit failure if there was an error during synthesis
set synth_dir [get_property DIRECTORY [current_run -synthesis]]
if {[get_property STATUS [get_runs synth_1]] != "synth_design Complete!"} {
  file copy -force ${synth_dir}/${top_entity}.vds ${release_dir}/${build_name}_synth.log
  puts "ERROR: Synthesis FAILED. See ${release_dir}/${build_name}_synth.log"
  tail ${release_dir}/${build_name}_synth.log 80
  exit 1
}

# Implementation
launch_runs impl_1 -to_step write_bitstream -jobs $num_cpus
wait_on_runs [get_runs impl_1] -quiet

# Exit failure if there was an error during implementation
set impl_dir [get_property DIRECTORY [current_run -implementation]]
if {[get_property STATUS [get_runs impl_1]] != "write_bitstream Complete!"} {
  file copy -force ${synth_dir}/${top_entity}.vds ${release_dir}/${build_name}_synth.log
  file copy -force ${impl_dir}/${top_entity}.vdi ${release_dir}/${build_name}_impl.log
  puts "ERROR: Implementation FAILED. See ${release_dir}/${build_name}_impl.log"
  tail ${release_dir}/${build_name}_impl.log 80
  exit 1
}



################################################################################
# Generate reports & check for timing errors
################################################################################
open_run impl_1

report_timing_summary -delay_type min_max -max_paths 10 -report_unconstrained -file ${release_dir}/${build_name}_timing.rpt
report_utilization -hierarchical -hierarchical_depth 4 -file ${release_dir}/${build_name}_util.rpt
report_io -file ${release_dir}/${build_name}_io.rpt
report_power -file ${release_dir}/${build_name}_power.rpt
report_methodology -file ${release_dir}/${build_name}_methodology.rpt
report_cdc -file ${release_dir}/${build_name}_cdc.rpt -details -severity "Critical"
report_clock_interaction -file ${release_dir}/${build_name}_clock_interaction.rpt -delay_type "min_max"
file copy -force ${synth_dir}/${top_entity}.vds ${release_dir}/${build_name}_synth.log
file copy -force ${impl_dir}/${top_entity}.vdi ${release_dir}/${build_name}_impl.log


set should_exit 0

if {$CHECK_TIMING} {
  # Check for negative slack
  set slack [get_property SLACK [get_timing_paths -delay_type "min_max"]]
  if {${slack} != "" && [expr {${slack} < 0}]} {
    puts "ERROR: Setup/hold timing negative slack after implementation run. See ${release_dir}/${build_name}_timing.rpt"
    tail ${release_dir}/${build_name}_timing.rpt 80
    set should_exit 1
  }

  # Check for pulse width violations
  if {[report_pulse_width -return_string -all_violators -no_header] != ""} {
    puts "ERROR: Pulse width timing violation after implementation run. See ${release_dir}/${build_name}_pulse_width.rpt"
    report_pulse_width -all_violators -file "${release_dir}/${build_name}_pulse_width.rpt"
    tail ${release_dir}/${build_name}_pulse_width.rpt 80
    set should_exit 1
  }
}

if {$CHECK_CDC} {
  # Check for unhandled CDC
  set clock_interaction_report [report_clock_interaction -delay_type "min_max" -no_header -return_string]
  if {[string first "(unsafe)" ${clock_interaction_report}] != -1} {
    puts "ERROR: Unhandled clock crossing after implementation run. See ${release_dir}/${build_name}_clock_interaction.rpt & ${release_dir}/${build_name}_timing.rpt"
    set should_exit 1
  }

  # Check for critical CDC warnings
  set cdc_report [report_cdc -return_string -no_header -details -severity "Critical"]
  if {[string first "Critical" ${cdc_report}] != -1} {
    puts "ERROR: Critical CDC rule violation after implementation run. See ${release_dir}/${build_name}_cdc.rpt"
    set should_exit 1
  }

  if {${should_exit} eq 1} {
    exit 1
  }
}


################################################################################
# Generate secondary output products if build was error-free
################################################################################

# Copy bit file to build output directory
set bit_file ${impl_dir}/${top_entity}.bit
file copy -force $bit_file ${release_dir}/${build_name}.bit

# # Generate the flash configuration file
# set mcs_file ${impl_dir}/${top_entity}.mcs
# write_cfgmem -force -format mcs -size 256 -interface SPIx4 -loadbit "up 0x0 $bit_file" -file $mcs_file
# file copy -force $mcs_file ${release_dir}/${build_name}.mcs

# Generate the xsa
write_hw_platform -force -fixed -include_bit -file ${release_dir}/${build_name}.xsa

# Generate debug probes
write_debug_probes -force ${release_dir}/${build_name}.ltx

# Save BRAM layout in case we want to inject init data into it post-build
write_mem_info -force -quiet -file ${release_dir}/${build_name}.mmi


# Stop build script timer and generate a build report
set build_time_stop [clock seconds]
set build_time_total_sec [expr $build_time_stop - $build_time_start]
set build_time_hrs [format "%02d" [expr $build_time_total_sec / 3600]]
set build_time_min [format "%02d" [expr $build_time_total_sec % 3600 / 60]]
set build_time_sec [format "%02d" [expr $build_time_total_sec % 60]]

set build_info [list \
  "------====== Build report for the $build_name FPGA ======------" \
  "Build Machine Name       : $host_name" \
  "Build Threads            : $num_cpus" \
  "Device ID                : $FPGA_ID" \
  "Project Directory        : [file normalize $script_dir]" \
  "Output Directory         : [file normalize $release_dir]" \
  "Build Timer \[hh:mm:ss\] : ${build_time_hrs}:${build_time_min}:${build_time_sec}" \
  "Build Date \[yyyymmdd\]  : $build_date" \
  "Build Time \[hhmmss\]    : $build_time" \
  "Local Build (Not CI)     : $local_build" \
  "Development Build        : $dev_build" \
  "Git Dirty                : $git_dirty" \
  "Git Hash                 : $git_hash" \
]
set build_info_str [join $build_info "\n"]
set fp [open "${release_dir}/${build_name}_build_info.rpt" w]
puts $fp $build_info_str
close $fp
puts "\n$build_info_str\n"
puts "All done... Great success!"
