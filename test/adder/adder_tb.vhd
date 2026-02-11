--##############################################################################
--# File : adder_tb.vhd
--# Auth : David Gussler
--# Lang : VHDL '08
--# ============================================================================
--! Adder testbench
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
  context vunit_lib.vunit_context;
  context vunit_lib.vc_context;
use vunit_lib.axi_lite_master_pkg.all;
use work.util_pkg.all;
use work.adder_regs_pkg.all;

entity adder_tb is
  generic (
    RUNNER_CFG : string
  );
end entity;

architecture tb of adder_tb is

  -- Clock period
  constant CLK_PERIOD : time := 10 ns;
  constant CLK_TO_Q   : time := 1 ns;

  -- Ports
  signal clk  : std_logic := '1';
  signal srst : std_logic := '1';

  signal axil_req : axil_req_t;
  signal axil_rsp : axil_rsp_t;

  constant AXIM : bus_master_t := new_bus(data_length => AXIL_DATA_WIDTH, address_length => AXIL_ADDR_WIDTH);

  function fn_addr (
    idx : natural
  ) return std_logic_vector is begin
    return std_logic_vector(to_unsigned(idx * 4, 32));
  end function;

begin

  prc_main : process is

    -- Helper Procedures
    procedure prd_wait_clk (
      cnt : in positive := 1
    ) is
    begin
      for i in 0 to cnt - 1 loop
        wait until rising_edge(clk);
        wait for CLK_TO_Q;
      end loop;
    end procedure;

    procedure prd_rst (
      cnt : in positive := 1
    ) is
    begin
      prd_wait_clk(1);
      srst <= '1';
      prd_wait_clk(cnt);
      srst <= '0';
    end procedure;

  begin

    -- This code is common to the entire test suite
    -- and is executed *once* prior to all test cases.
    test_runner_setup(runner, RUNNER_CFG);

    while test_suite loop

      -- This code executed before *every* test case.
      prd_rst(16);

      if run("test_0") then
        info("Running test_0");

        write_axi_lite(net, AXIM, fn_addr(adder_a), x"0000_0004", AXI_RSP_OKAY, x"F");
        write_axi_lite(net, AXIM, fn_addr(adder_b), x"0000_0005", AXI_RSP_OKAY, x"F");
        check_axi_lite(net, AXIM, fn_addr(adder_c), AXI_RSP_OKAY, x"0000_0009", "Adder test failed");

      end if;

      -- Put test case cleanup code here. This code executed after *every* test case.
      info("Test done");
      prd_wait_clk(16);

    end loop;

    -- Put test suite cleanup code here. This code is common to the entire test suite
    -- and is executed *once* after all test cases have been run.
    test_runner_cleanup(runner);

  end process;

  -- Watchdog
  test_runner_watchdog(runner, 100 us);

  -- ---------------------------------------------------------------------------
  clk <= not clk after CLK_PERIOD / 2;

  -- ---------------------------------------------------------------------------
  u_adder : entity work.adder
  port map (
    clk        => clk,
    srst       => srst,
    s_axil_req => axil_req,
    s_axil_rsp => axil_rsp
  );

  -- ---------------------------------------------------------------------------
  u_axil_bfm : entity work.bfm_axil_man
  generic map (
    G_BUS_HANDLE => AXIM
  )
  port map (
    clk        => clk,
    m_axil_req => axil_req,
    m_axil_rsp => axil_rsp
  );

end architecture;
