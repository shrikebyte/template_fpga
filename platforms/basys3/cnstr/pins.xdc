
set_property -dict { PACKAGE_PIN W5    IOSTANDARD LVCMOS33 } [get_ports { i_fpga_clk_100m }]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { i_fpga_arst     }]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports { i_uart_rxd      }]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { o_uart_txd      }]
