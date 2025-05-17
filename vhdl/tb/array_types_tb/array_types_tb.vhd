-- Testbench for: <EntityName>
-- Filename: tb_<EntityName>.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_types.all;
use work.basic_pkg.all;

entity array_types_tb is
end entity;

architecture behavior of array_types_tb is
  constant DATA_W            : natural := 16;
  constant ARRAY_SIZE        : natural := 8;
  -- Signals for UUT connections
  signal clk     : std_logic := '0';
  signal reset   : std_logic := '1';
  signal clock_counter : unsigned(31 downto 0) := (others => '0');
  signal unsigned_array   : array_unsigned_t(0 to ARRAY_SIZE - 1)(DATA_W - 1 downto 0):= (others=>(others=>'0'));
  signal signed_array   : array_signed_t(0 to ARRAY_SIZE - 1)(DATA_W - 1 downto 0):= (others=>(others=>'0'));
  signal slv_array   : array_slv_t(0 to ARRAY_SIZE - 1)(DATA_W - 1 downto 0):= (others=>(others=>'0'));
  -- flat slv
  signal slv_flat    : std_logic_vector(ARRAY_SIZE*DATA_W - 1 downto 0);
  -- converted array
  signal slv_array_1   : array_slv_t(0 to ARRAY_SIZE - 1)(DATA_W - 1 downto 0):= (others=>(others=>'0'));
  signal unsigned_array_1   : array_unsigned_t(0 to ARRAY_SIZE - 1)(DATA_W - 1 downto 0):= (others=>(others=>'0'));
  signal signed_array_1   : array_signed_t(0 to ARRAY_SIZE - 1)(DATA_W - 1 downto 0):= (others=>(others=>'0'));

    -- Clock period definition
  constant clk_period : time := 10 ns;

begin

  unsigned_array <= to_array_unsigned(signed_array);
  slv_array <= to_array_slv(unsigned_array);

  slv_flat <= to_flat_slv(slv_array);
  
  slv_array_1 <= slv_to_array_slv(slv_flat,ARRAY_SIZE,DATA_W);
  unsigned_array_1 <= slv_to_array_unsigned(slv_flat,ARRAY_SIZE,DATA_W);
  signed_array_1 <= slv_to_array_signed(slv_flat,ARRAY_SIZE,DATA_W);
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
        if clock_counter = 5 then
            reset <= '0';
        end if;
        if clock_counter = 10 then
          signed_array(0) <= to_signed(1,DATA_W);
          signed_array(1)  <= to_signed(2,DATA_W);
          signed_array(2)  <= to_signed(3,DATA_W);
          signed_array(3)  <= to_signed(4,DATA_W);
          signed_array(4)  <= to_signed(5,DATA_W);
          signed_array(5)  <= to_signed(6,DATA_W);
          signed_array(6)  <= to_signed(7,DATA_W);
          signed_array(7)  <= to_signed(8,DATA_W);
        end if;

        if clock_counter = 11 then
          signed_array(0) <= to_signed(10,DATA_W);
          signed_array(1)  <= to_signed(20,DATA_W);
          signed_array(2)  <= to_signed(30,DATA_W);
          signed_array(3)  <= to_signed(40,DATA_W);
          signed_array(4)  <= to_signed(50,DATA_W);
          signed_array(5)  <= to_signed(60,DATA_W);
          signed_array(6)  <= to_signed(70,DATA_W);
          signed_array(7)  <= to_signed(80,DATA_W);
        end if;

        if clock_counter = 12 then
          signed_array(0) <= to_signed(100,DATA_W);
          signed_array(1)  <= to_signed(200,DATA_W);
          signed_array(2)  <= to_signed(300,DATA_W);
          signed_array(3)  <= to_signed(400,DATA_W);
          signed_array(4)  <= to_signed(500,DATA_W);
          signed_array(5)  <= to_signed(600,DATA_W);
          signed_array(6)  <= to_signed(700,DATA_W);
          signed_array(7)  <= to_signed(800,DATA_W);
        end if;
      end if;
  
  end process;

end architecture;
