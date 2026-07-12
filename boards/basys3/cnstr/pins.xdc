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

set_property -dict { PACKAGE_PIN W5    IOSTANDARD LVCMOS33 } [get_ports { i_fpga_clk_100m }];
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { i_fpga_arst     }];
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports { i_uart_rxd      }];
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { o_uart_txd      }];
set_property -dict { PACKAGE_PIN J1    IOSTANDARD LVCMOS33 } [get_ports { i_gpio0         }];
set_property -dict { PACKAGE_PIN L2    IOSTANDARD LVCMOS33 } [get_ports { o_gpio1         }];
