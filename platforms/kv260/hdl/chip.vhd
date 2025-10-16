--##############################################################################
--# File : chip.vhd
--# Auth : David Gussler
--# Lang : VHDL'08
--# ============================================================================
--! Top level chip
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity chip is
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

architecture rtl of chip is

  signal clk_100m     : std_logic;
  signal srst_100m    : std_logic;
  signal axil_req_bd  : axil_req_t;
  signal axil_rsp_bd  : axil_rsp_t;
  signal axil_req_ver : axil_req_t;
  signal axil_rsp_ver : axil_rsp_t;

begin

  u_bd_wrapper : entity work.bd_wrapper
  port map (
    clk_100m   => clk_100m,
    srst_100m  => srst_100m,
    m_axil_req => axil_req_bd,
    m_axil_rsp => axil_rsp_bd,
    uart_rxd   => i_uart_rxd,
    uart_txd   => o_uart_txd
  );

  u_axil_xbar : entity work.axil_xbar
  generic map (
    G_NUM_MASTERS => 1,
    G_NUM_SLAVES => 1,
    G_BASEADDRS => x"0000_0000"
  )
  port map (
    clk           => clk_100m,
    srst          => srst_100m,
    s_axil_req(0) => axil_req_bd,
    s_axil_rsp(0) => axil_rsp_bd,
    m_axil_req(0) => axil_req_ver,
    m_axil_rsp(0) => axil_rsp_ver
  );

  u_stdver_axil : entity work.stdver_axil
  generic map (
    G_DEVICE_ID => G_DEVICE_ID,
    G_VER_MAJOR => G_VER_MAJOR,
    G_VER_MINOR => G_VER_MINOR,
    G_VER_PATCH => G_VER_PATCH,
    G_LOCAL_BUILD => G_LOCAL_BUILD,
    G_DEV_BUILD => G_DEV_BUILD,
    G_BUILD_DATE => G_BUILD_DATE,
    G_BUILD_TIME => G_BUILD_TIME,
    G_GIT_HASH => G_GIT_HASH,
    G_GIT_DIRTY => G_GIT_DIRTY
  )
  port map (
    clk => clk_100m,
    srst => srst_100m,
    s_axil_req => axil_req_ver,
    s_axil_rsp => axil_rsp_ver
  );

end architecture;
