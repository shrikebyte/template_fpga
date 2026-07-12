################################################################################
# File : timing.xdc
# Auth : David Gussler
# ==============================================================================
# Shrikebyte FPGA Template - https://github.com/shrikebyte/template_fpga
# Copyright (C) Shrikebyte, LLC
# Licensed under the Apache 2.0 license, see LICENSE for details.
# ==============================================================================
# Timing constraints
################################################################################

create_clock -add -name fpga_clk_100m -period 10.00 [get_ports i_fpga_clk_100m]
