-- Testbench for: <EntityName>
-- Filename: tb_<EntityName>.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_types.all;
use work.basic_pkg.all;

entity dsp_multiply_and_add_tb is
end entity;

architecture behavior of dsp_multiply_and_add_tb is
  constant A_W            : natural := 30;
  constant B_W            : natural := 18;
  constant C_W            : natural := 48;
  constant P_W            : natural := 48;
  -- Signals for UUT connections
  signal clk     : std_logic := '0';
  signal reset   : std_logic := '1';
  signal a_i    : signed(A_W - 1 downto 0) := (others=>'0');
  signal b_i    : signed(B_W - 1 downto 0) := (others=>'0');
  signal c_i    : signed(C_W - 1 downto 0):= (others=>'0');
  signal p_o    : signed(P_W - 1 downto 0):= (others => '0');
  signal in_valid  : std_logic := '0';
  signal clock_counter : unsigned(31 downto 0) := (others => '0');
  signal p_valid    : std_logic := '0';
    -- Clock period definition
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  iUUT : entity work.dsp_multiply_and_add
  generic map (
    USE_CASCADE_PORTS            => false
  )
  port map(
    clk_i           => clk,
    reset_i         => reset,
    valid_i         => in_valid,
    a_i             => std_logic_vector(a_i),
    b_i             => std_logic_vector(b_i),
    c_i             => std_logic_vector(c_i),
    signed(p_o)     => p_o,
    valid_o         => p_valid
        
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
        in_valid <= '0';
        a_i   <= to_signed(0,A_W);
        b_i   <= to_signed(0,B_W);
        c_i   <= to_signed(0,C_W);
        if clock_counter = 5 then
            reset <= '0';
        end if;
        if clock_counter = 10 then
          a_i   <= to_signed(10,A_W);
          b_i   <= to_signed(10,B_W);
          c_i   <= to_signed(10,C_W);
          in_valid <= '1';
        end if;
        if clock_counter = 12 then
          a_i   <= to_signed(20,A_W);
          b_i   <= to_signed(20,B_W);
          c_i   <= to_signed(200,C_W);
          in_valid <= '1';
        end if;
        
        if clock_counter = 13 then
          a_i   <= to_signed(-20,A_W);
          b_i   <= to_signed(20,B_W);
          c_i   <= to_signed(-200,C_W);
          in_valid <= '1';
        end if;

      end if;
  
  end process;

end architecture;
