--##############################################################################
--# File : bd_wrapper.vhd
--# Auth : David Gussler
--# Lang : VHDL'08
--# ============================================================================
--! Manually maintained block design wrapper
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

use work.util_pkg.all;

entity bd_wrapper is
  port (
    clk_100m       : out   std_logic;
    srst_100m      : out   std_logic;
    --
    m_axil_req     : out   axil_req_t;
    m_axil_rsp     : in    axil_rsp_t;
    --
    uart_rxd       : in    std_logic;
    uart_txd       : out   std_logic
  );
end entity;

architecture rtl of bd_wrapper is

  component bd is
    port (
      clk_100m       : out   std_logic;
      m_axil_awaddr  : out   std_logic_vector( 31 downto 0);
      m_axil_awprot  : out   std_logic_vector( 2 downto 0);
      m_axil_awvalid : out   std_logic;
      m_axil_awready : in    std_logic;
      m_axil_wdata   : out   std_logic_vector( 31 downto 0);
      m_axil_wstrb   : out   std_logic_vector( 3 downto 0);
      m_axil_wvalid  : out   std_logic;
      m_axil_wready  : in    std_logic;
      m_axil_bresp   : in    std_logic_vector( 1 downto 0);
      m_axil_bvalid  : in    std_logic;
      m_axil_bready  : out   std_logic;
      m_axil_araddr  : out   std_logic_vector( 31 downto 0);
      m_axil_arprot  : out   std_logic_vector( 2 downto 0);
      m_axil_arvalid : out   std_logic;
      m_axil_arready : in    std_logic;
      m_axil_rdata   : in    std_logic_vector( 31 downto 0);
      m_axil_rresp   : in    std_logic_vector( 1 downto 0);
      m_axil_rvalid  : in    std_logic;
      m_axil_rready  : out   std_logic;
      srst_100m      : out   std_logic_vector( 0 to 0);
      uart_rxd       : in    std_logic;
      uart_txd       : out   std_logic
    );
  end component;

begin

  u_bd : component bd
  port map (
    clk_100m      => clk_100m,
    srst_100m(0)  => srst_100m,
    --
    m_axil => m_axil_req.araddr,
    m_axil => m_axil_req.arprot,
    m_axil => m_axil_rsp.arready,
    m_axil => m_axil_req.arvalid,
    m_axil => m_axil_req.awaddr,
    m_axil => m_axil_req.awprot,
    m_axil => m_axil_rsp.awready,
    m_axil => m_axil_req.awvalid,
    m_axil => m_axil_req.bready,
    m_axil => m_axil_rsp.bresp,
    m_axil => m_axil_rsp.bvalid,
    m_axil => m_axil_rsp.rdata,
    m_axil => m_axil_req.rready,
    m_axil => m_axil_rsp.rresp,
    m_axil => m_axil_rsp.rvalid,
    m_axil => m_axil_req.wdata,
    m_axil => m_axil_rsp.wready,
    m_axil => m_axil_req.wstrb,
    m_axil => m_axil_req.wvalid,
    --
    uart_rxd  => uart_rxd,
    uart_txd  => uart_txd
  );

end architecture;
