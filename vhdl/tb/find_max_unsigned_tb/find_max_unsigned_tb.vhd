-- Testbench for: <EntityName>
-- Filename: tb_<EntityName>.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_types.all;
use work.basic_pkg.all;

entity find_max_unsigned_tb is
end entity;

architecture behavior of find_max_unsigned_tb is
  constant NUMBER_OF_INPUTS  : natural := 16;
  constant DATA_W            : natural := 16;
  -- Signals for UUT connections
  signal clk     : std_logic := '0';
  signal reset   : std_logic := '1';
  signal src_data   : array_unsigned_t(0 to NUMBER_OF_INPUTS - 1)(DATA_W - 1 downto 0) := (others=>(others=>'0'));
  signal src_valid  : std_logic := '0';
  signal dst_max_index   : unsigned(ceil_log2(NUMBER_OF_INPUTS) - 1 downto 0):= (others => '0');
  signal dst_max_data    : unsigned(DATA_W - 1 downto 0):= (others => '0');
  signal dst_valid  : std_logic := '0';
  signal clock_counter : unsigned(31 downto 0) := (others => '0');

    -- Clock period definition
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  iUUT : entity work.find_max_unsigned
  generic map (
      NUMBER_OF_INPUTS  => NUMBER_OF_INPUTS,
      DATA_W            => DATA_W
  )
  port map(
      clk_i               => clk,
      reset_i             => reset,
      src_data_i          => src_data,
      src_valid_i         => src_valid,
      dst_max_data_o      => dst_max_data,
      dst_max_index_o      => dst_max_index,
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
          src_data(0) <= to_unsigned(123,DATA_W);
          src_data(1) <= to_unsigned(100,DATA_W);
          src_data(2) <= to_unsigned(1,DATA_W);
          src_data(3) <= to_unsigned(150,DATA_W);
          src_data(4) <= to_unsigned(200,DATA_W);
          src_data(5) <= to_unsigned(1,DATA_W);
          src_data(6) <= to_unsigned(1,DATA_W);
          src_data(7) <= to_unsigned(133,DATA_W);
          src_data(8) <= to_unsigned(1,DATA_W);
          src_data(9) <= to_unsigned(397,DATA_W);
          src_data(10) <= to_unsigned(100,DATA_W);
          src_data(11) <= to_unsigned(100,DATA_W);
          src_data(12) <= to_unsigned(100,DATA_W);
          src_data(13) <= to_unsigned(100,DATA_W);
          src_data(14) <= to_unsigned(100,DATA_W);
          src_data(15) <= to_unsigned(500,DATA_W);
          src_valid <= '1';
        end if;

        if clock_counter = 50 then
            reset <= '1';
        end if;

        if clock_counter = 51 then
            reset <= '0';
        end if;

        if clock_counter = 52 then
            src_data(0) <= to_unsigned(100,DATA_W);
            src_data(1) <= to_unsigned(12,DATA_W);
            src_data(2) <= to_unsigned(1,DATA_W);
            src_data(3) <= to_unsigned(15,DATA_W);
            src_data(4) <= to_unsigned(1,DATA_W);
            src_data(5) <= to_unsigned(1,DATA_W);
            src_data(6) <= to_unsigned(99,DATA_W);
            src_data(7) <= to_unsigned(1,DATA_W);
            src_data(8) <= to_unsigned(1,DATA_W);
            src_data(9) <= to_unsigned(1,DATA_W);
            src_data(10) <= to_unsigned(10,DATA_W);
            src_data(11) <= to_unsigned(10,DATA_W);
            src_data(12) <= to_unsigned(10,DATA_W);
            src_data(13) <= to_unsigned(10,DATA_W);
            src_data(14) <= to_unsigned(10,DATA_W);
            src_data(15) <= to_unsigned(10,DATA_W);
            src_valid <= '1';
          end if;
          if clock_counter = 53 then
            src_data(0) <= to_unsigned(99,DATA_W);
            src_data(1) <= to_unsigned(100,DATA_W);
            src_data(2) <= to_unsigned(1,DATA_W);
            src_data(3) <= to_unsigned(15,DATA_W);
            src_data(4) <= to_unsigned(1,DATA_W);
            src_data(5) <= to_unsigned(1,DATA_W);
            src_data(6) <= to_unsigned(150,DATA_W);
            src_data(7) <= to_unsigned(1,DATA_W);
            src_data(8) <= to_unsigned(1,DATA_W);
            src_data(9) <= to_unsigned(1,DATA_W);
            src_data(10) <= to_unsigned(10,DATA_W);
            src_data(11) <= to_unsigned(10,DATA_W);
            src_data(12) <= to_unsigned(10,DATA_W);
            src_data(13) <= to_unsigned(10,DATA_W);
            src_data(14) <= to_unsigned(10,DATA_W);
            src_data(15) <= to_unsigned(10,DATA_W);
            src_valid <= '1';
          end if;
      end if;
  
  end process;

end architecture;
