-- Testbench for: <EntityName>
-- Filename: tb_<EntityName>.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_types.all;
use work.basic_pkg.all;

entity fir_filter_tb is
end entity;

architecture behavior of fir_filter_tb is
  constant NUMBER_OF_TAPS    : natural := 8;
  constant DATA_W            : natural := 16;
  constant WEIGHTS_FIXED_POINTS : natural := 15;
  -- Signals for UUT connections
  signal clk     : std_logic := '0';
  signal reset   : std_logic := '1';
  signal src_data_r    : signed(DATA_W - 1 downto 0) := (others=>'0');
  signal src_data_i    : signed(DATA_W - 1 downto 0) := (others=>'0');
  signal src_valid     : std_logic := '0';

  signal dst_data_r    : signed(DATA_W - 1 downto 0) := (others=>'0');
  signal dst_data_i    : signed(DATA_W - 1 downto 0) := (others=>'0');
  signal dst_valid     : std_logic := '0';
  
  signal weights : array_signed_t(0 to NUMBER_OF_TAPS - 1)(17 downto 0);

  
  signal clock_counter : unsigned(31 downto 0) := (others => '0');
  signal p_valid    : std_logic := '0';
    -- Clock period definition
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  iUUT : entity work.fir_filter
  generic map (
    NUMBER_OF_TAPS         => NUMBER_OF_TAPS,         
    DATA_W                 => DATA_W, 
    WEIGHTS_FIXED_POINTS   => WEIGHTS_FIXED_POINTS               
  )
  port map(
    clk_i             => clk,
    reset_i           => reset,
    weights_i         => weights,
    src_data_r_i      => src_data_r,  
    src_data_i_i      => src_data_i, 
    src_data_valid_i  => src_valid, 
    dst_data_r_o      => dst_data_r,  
    dst_data_i_o      => dst_data_i, 
    dst_data_valid_i  => dst_valid
        
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
        weights(0) <= to_signed(32768,18);
        weights(1) <= to_signed(32768,18);
        weights(2) <= to_signed(32768,18);
        weights(3) <= to_signed(32768,18);
        weights(4) <= to_signed(32768,18);
        weights(5) <= to_signed(32768,18);
        weights(6) <= to_signed(32768,18);
        weights(7) <= to_signed(32768,18);
        src_valid <= '1';
        if clock_counter = 5 then
            reset <= '0';
        end if;

        if clock_counter = 10 then
          src_data_r   <= to_signed(1,DATA_W);
          src_data_i   <= to_signed(1,DATA_W);
          src_valid <= '1';
        end if;
        
        if clock_counter = 300 then
          src_data_r   <= to_signed(10,DATA_W);
          src_data_i   <= to_signed(10,DATA_W);
          src_valid <= '1';
        end if;

      end if;
  
  end process;

end architecture;
