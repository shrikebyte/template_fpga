--##############################################################################
--# File : sbsdr.vhd
--# Auth : David Gussler
--# Lang : VHDL'08
--# ============================================================================
--! SB SDR
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util_pkg.all;

entity sbsdr is
  generic (
    G_IS_SIM      : boolean                       := false;
    G_DEVICE_ID   : std_logic_vector(31 downto 0) := x"DEAD_BEEF";
    G_VER_MAJOR   : integer range 0 to 255        := 255;
    G_VER_MINOR   : integer range 0 to 255        := 255;
    G_VER_PATCH   : integer range 0 to 255        := 255;
    G_LOCAL_BUILD : boolean                       := true;
    G_DEV_BUILD   : boolean                       := true;
    G_GIT_DIRTY   : boolean                       := true;
    G_GIT_HASH    : std_logic_vector(31 downto 0) := x"DEAD_BEEF";
    G_BUILD_DATE  : std_logic_vector(31 downto 0) := x"DEAD_BEEF";
    G_BUILD_TIME  : std_logic_vector(23 downto 0) := x"DEAD_BE"
  );
  port (
    i_uart_rxd : in    std_logic;
    o_uart_txd : out   std_logic
  );
end entity;

architecture rtl of sbsdr is

  signal clk_100m     : std_logic;
  signal srst_100m    : std_logic;
  signal axil_req_ver : axil_req_t;
  signal axil_rsp_ver : axil_rsp_t;

begin

  -- ---------------------------------------------------------------------------
  u_bd_wrapper : entity work.bd_wrapper
  port map (
    clk_100m           => clk_100m,
    srst_100m(0)       => srst_100m,
    m_axil_ver_araddr  => axil_req_ver.araddr,
    m_axil_ver_arprot  => axil_req_ver.arprot,
    m_axil_ver_arready => axil_rsp_ver.arready,
    m_axil_ver_arvalid => axil_req_ver.arvalid,
    m_axil_ver_awaddr  => axil_req_ver.awaddr,
    m_axil_ver_awprot  => axil_req_ver.awprot,
    m_axil_ver_awready => axil_rsp_ver.awready,
    m_axil_ver_awvalid => axil_req_ver.awvalid,
    m_axil_ver_bready  => axil_req_ver.bready,
    m_axil_ver_bresp   => axil_rsp_ver.bresp,
    m_axil_ver_bvalid  => axil_rsp_ver.bvalid,
    m_axil_ver_rdata   => axil_rsp_ver.rdata,
    m_axil_ver_rready  => axil_req_ver.rready,
    m_axil_ver_rresp   => axil_rsp_ver.rresp,
    m_axil_ver_rvalid  => axil_rsp_ver.rvalid,
    m_axil_ver_wdata   => axil_req_ver.wdata,
    m_axil_ver_wready  => axil_rsp_ver.wready,
    m_axil_ver_wstrb   => axil_req_ver.wstrb,
    m_axil_ver_wvalid  => axil_req_ver.wvalid
  );

  -- ---------------------------------------------------------------------------
  u_stdver_axil : entity work.stdver_axil
  generic map (
    G_DEVICE_ID   => G_DEVICE_ID,
    G_VER_MAJOR   => G_VER_MAJOR,
    G_VER_MINOR   => G_VER_MINOR,
    G_VER_PATCH   => G_VER_PATCH,
    G_LOCAL_BUILD => G_LOCAL_BUILD,
    G_DEV_BUILD   => G_DEV_BUILD,
    G_BUILD_DATE  => G_BUILD_DATE,
    G_BUILD_TIME  => G_BUILD_TIME,
    G_GIT_HASH    => G_GIT_HASH,
    G_GIT_DIRTY   => G_GIT_DIRTY
  )
  port map (
    clk        => clk_100m,
    srst       => srst_100m,
    s_axil_req => axil_req_ver,
    s_axil_rsp => axil_rsp_ver
  );

end architecture;
