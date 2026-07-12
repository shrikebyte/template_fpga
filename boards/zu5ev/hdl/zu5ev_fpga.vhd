--##############################################################################
--# File : zu5ev_fpga.vhd
--# Auth : David Gussler
--# Lang : VHDL'08
--# ============================================================================
--# Top level fpga
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util_pkg.all;
use work.bus_pkg.all;

entity zu5ev_fpga is
  generic (
    G_DEVICE_ID  : std_logic_vector(31 downto 0) := x"DEAD_BEEF";
    G_VER_MAJOR  : integer range 0 to 255        := 255;
    G_VER_MINOR  : integer range 0 to 255        := 255;
    G_VER_PATCH  : integer range 0 to 255        := 255;
    G_GIT_DIRTY  : boolean                       := true;
    G_GIT_HASH   : std_logic_vector(31 downto 0) := x"DEAD_BEEF";
    G_BUILD_DATE : std_logic_vector(31 downto 0) := x"DEAD_BEEF";
    G_BUILD_TIME : std_logic_vector(23 downto 0) := x"DEAD_BE"
  );
  port (
    i_uart_rxd : in    std_logic;
    o_uart_txd : out   std_logic;
    i_gpio0    : in    std_logic;
    o_gpio1    : out   std_logic
  );
end entity;

architecture rtl of zu5ev_fpga is

  signal clk_100m  : std_logic;
  signal srst_100m : std_logic;
  signal axil_bd   : bus_axil_t;
  signal axil_ver  : bus_axil_t;
  signal axil_add  : bus_axil_t;

begin

  -- ---------------------------------------------------------------------------
  u_zu5ev_bd : entity work.zu5ev_bd
  port map (
    clk_100m  => clk_100m,
    srst_100m => srst_100m,
    m_axil    => axil_bd,
    uart_rxd  => i_uart_rxd,
    uart_txd  => o_uart_txd
  );

  -- ---------------------------------------------------------------------------
  u_axil_xbar : entity work.axil_xbar
  generic map (
    G_NUM_S      => 1,
    G_NUM_M      => 2,
    G_ADDR_WIDTH => 16,
    G_BASEADDRS  => (
      0 => (addr => x"0000_1000", width => 12),
      1 => (addr => x"0000_2000", width => 12)
    )
  )
  port map (
    clk       => clk_100m,
    srst      => srst_100m,
    s_axil(0) => axil_bd,
    m_axil(0) => axil_ver,
    m_axil(1) => axil_add
  );

  -- ---------------------------------------------------------------------------
  u_stdver_axil : entity work.stdver_axil
  generic map (
    G_DEVICE_ID  => G_DEVICE_ID,
    G_VER_MAJOR  => G_VER_MAJOR,
    G_VER_MINOR  => G_VER_MINOR,
    G_VER_PATCH  => G_VER_PATCH,
    G_ENGR_BUILD => false,
    G_BUILD_DATE => G_BUILD_DATE,
    G_BUILD_TIME => G_BUILD_TIME,
    G_GIT_HASH   => G_GIT_HASH,
    G_GIT_DIRTY  => G_GIT_DIRTY
  )
  port map (
    clk    => clk_100m,
    srst   => srst_100m,
    s_axil => axil_ver
  );

  -- ---------------------------------------------------------------------------
  u_adder : entity work.adder
  port map (
    clk    => clk_100m,
    srst   => srst_100m,
    s_axil => axil_add
  );

  -- ---------------------------------------------------------------------------
  u_cdc_bit : entity work.cdc_bit
  generic map (
    G_WIDTH       => 1,
    G_USE_SRC_REG => false,
    G_EXTRA_SYNC  => 0
  )
  port map (
    src_bit(0) => i_gpio0,
    dst_clk    => clk_100m,
    dst_bit(0) => o_gpio1
  );

end architecture;
