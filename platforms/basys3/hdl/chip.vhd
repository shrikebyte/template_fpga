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

begin

end architecture;
