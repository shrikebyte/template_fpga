################################################################################
# File : pins.xdc
# Auth : David Gussler
# ==============================================================================
# Shrikebyte FPGA Template - https://github.com/shrikebyte/template_fpga
# Copyright (C) Shrikebyte, LLC
# Licensed under the Apache 2.0 license, see LICENSE for details.
# ==============================================================================
# Pin constraints
################################################################################

set_property -dict { PACKAGE_PIN AE13  IOSTANDARD LVCMOS33 } [get_ports { i_uart_rxd }];
set_property -dict { PACKAGE_PIN AG14  IOSTANDARD LVCMOS33 } [get_ports { o_uart_txd }];
set_property -dict { PACKAGE_PIN AH14  IOSTANDARD LVCMOS33 } [get_ports { i_gpio0    }];
set_property -dict { PACKAGE_PIN AG13  IOSTANDARD LVCMOS33 } [get_ports { o_gpio1    }];
