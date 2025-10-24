--##############################################################################
--# File : adder.vhd
--# Auth : David Gussler
--# Lang : VHDL'08
--# ============================================================================
--! Signed adder example
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.util_pkg.all;
use work.adder_regs_pkg.all;
use work.adder_register_record_pkg.all;

entity adder is
  port (
    clk        : in    std_logic;
    srst       : in    std_logic;
    s_axil_req : in    axil_req_t;
    s_axil_rsp : out   axil_rsp_t
  );
end entity;

architecture rtl of adder is

  -- ---------------------------------------------------------------------------
  signal i : adder_regs_up_t;
  signal o : adder_regs_down_t;
  signal r : adder_reg_was_read_t;
  signal w : adder_reg_was_written_t;
  signal c : signed(31 downto 0);

begin

  -- ---------------------------------------------------------------------------
  u_adder_reg_file : entity work.adder_register_file_axi_lite
  port map (
    clk             => clk,
    reset           => srst,
    s_axil_req      => s_axil_req,
    s_axil_rsp      => s_axil_rsp,
    regs_up         => i,
    regs_down       => o,
    reg_was_read    => r,
    reg_was_written => w
  );

  -- ---------------------------------------------------------------------------
  prc_adder : process (clk) is begin
    if rising_edge(clk) then
      c <= signed(o.a.data) + signed(o.b.data);
    end if;
  end process;

  i.c.data <= unsigned(c);

end architecture;
