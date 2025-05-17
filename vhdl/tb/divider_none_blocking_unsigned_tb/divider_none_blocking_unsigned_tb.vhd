-- Testbench for: <EntityName>
-- Filename: tb_<EntityName>.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_types.all;
use work.basic_pkg.all;

entity divider_none_blocking_unsigned_tb is
end entity;

architecture behavior of divider_none_blocking_unsigned_tb is
  constant DATA_W            : natural := 16;
  -- Signals for UUT connections
  signal clk     : std_logic := '0';
  signal reset   : std_logic := '1';
  signal src_dividend   : unsigned(DATA_W - 1 downto 0) := (others=>'0');
  signal src_divisor    : unsigned(DATA_W - 1 downto 0) := (others=>'0');
  signal src_valid      : std_logic;
  signal dst_quotient    : unsigned(DATA_W - 1 downto 0):= (others => '0');
  signal dst_remainder   : unsigned(DATA_W - 1 downto 0):= (others => '0');
  signal dst_valid  : std_logic := '0';
  signal dst_ready  : std_logic := '0';
  signal clock_counter : unsigned(31 downto 0) := (others => '0');

    -- Clock period definition
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  iUUT : entity work.divider_none_blocking_unsigned
  generic map (
      DATA_W            => DATA_W
  )
  port map(
      clk_i               => clk,
      reset_i             => reset,
      src_dividend_i      => src_dividend,
      src_divisor_i       => src_divisor,
      src_valid_i         => src_valid,
      dst_quotient_o      => dst_quotient,
      dst_remainder_o     => dst_remainder,
      dst_valid_o         => dst_valid
  );
  -- Clock generation process
  clk_process : process
  begin
      while true loop
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
      end loop;
  end process;
  -- Stimulus process
  stim_proc: process(clk)
  begin
      if rising_edge(clk) then
        clock_counter <= clock_counter + 1;
        src_valid <= '0';
        if clock_counter = 5 then
            reset <= '0';
        end if;
        if clock_counter = 10 then
          src_dividend <= to_unsigned(50,DATA_W);
          src_divisor  <= to_unsigned(7,DATA_W);
          src_valid <= '1';
        end if;

        if clock_counter = 50 then
            reset <= '1';
        end if;

        if clock_counter = 51 then
            reset <= '0';
        end if;

        if clock_counter = 52 then
          src_dividend <= to_unsigned(150,DATA_W);
          src_divisor  <= to_unsigned(7,DATA_W);
          src_valid <= '1';
          end if;

        if clock_counter = 53 then
          src_dividend <= to_unsigned(50,DATA_W);
          src_divisor  <= to_unsigned(50,DATA_W);
          src_valid <= '1';
        end if;
      end if;
  
  end process;

end architecture;
