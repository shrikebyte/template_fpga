--##############################################################################
--# File : basys3_fpga.vhd
--# Auth : David Gussler
--# Lang : VHDL'08
--# ============================================================================
--! Top level fpga
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util_pkg.all;

entity basys3_fpga is
  generic (
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
    i_fpga_clk_100m : in    std_logic;
    i_fpga_arst     : in    std_logic;
    i_uart_rxd      : in    std_logic;
    o_uart_txd      : out   std_logic;
    i_gpio0         : in    std_logic;
    o_gpio1         : out   std_logic
  );
end entity;

architecture rtl of basys3_fpga is

  signal clk_100m     : std_logic;
  signal srst_100m    : std_logic;
  signal axil_req_bd  : axil_req_t;
  signal axil_rsp_bd  : axil_rsp_t;
  signal axil_req_ver : axil_req_t;
  signal axil_rsp_ver : axil_rsp_t;
  signal axil_req_add : axil_req_t;
  signal axil_rsp_add : axil_rsp_t;

begin

  -- ---------------------------------------------------------------------------
  basys3_bd_inst : entity work.basys3_bd
  port map (
    clk_100m      => clk_100m,
    srst_100m     => srst_100m,
    m_axil_req    => axil_req_bd,
    m_axil_rsp    => axil_rsp_bd,
    fpga_clk_100m => i_fpga_clk_100m,
    fpga_arst     => i_fpga_arst,
    uart_rxd      => i_uart_rxd,
    uart_txd      => o_uart_txd
  );

  -- ---------------------------------------------------------------------------
  axil_xbar_inst : entity work.axil_xbar
  generic map (
    G_NUM_MASTERS => 1,
    G_NUM_SLAVES  => 2,
    G_BASEADDRS   => (0 => x"0000_0000", 1 => x"0000_1000")
  )
  port map (
    clk           => clk_100m,
    srst          => srst_100m,
    s_axil_req(0) => axil_req_bd,
    s_axil_rsp(0) => axil_rsp_bd,
    m_axil_req(0) => axil_req_ver,
    m_axil_req(1) => axil_req_add,
    m_axil_rsp(0) => axil_rsp_ver,
    m_axil_rsp(1) => axil_rsp_add
  );

  -- ---------------------------------------------------------------------------
  stdver_axil_inst : entity work.stdver_axil
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

  -- ---------------------------------------------------------------------------
  adder_inst : entity work.adder
  port map (
    clk        => clk_100m,
    srst       => srst_100m,
    s_axil_req => axil_req_add,
    s_axil_rsp => axil_rsp_add
  );

  -- ---------------------------------------------------------------------------
  cdc_bit_inst : entity work.cdc_bit
  generic map (
    G_USE_SRC_REG => false,
    G_EXTRA_SYNC  => 0
  )
  port map (
    src_bit(0) => i_gpio0,
    dst_clk    => clk_100m,
    dst_bit(0) => o_gpio1
  );

end architecture;
