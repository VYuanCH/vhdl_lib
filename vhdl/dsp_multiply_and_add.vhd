
library ieee;
use ieee.std_logic_1164.all;
use work.array_types.all;
use work.basic_pkg.all;

entity dsp_multiply_and_add is
  generic (
    USE_CASCADE_PORTS : boolean := false
      
  );
  port (
    clk_i           : in std_logic;
    reset_i         : in std_logic;
    valid_i         : in std_logic:= '1';
    a_i             : in std_logic_vector(29 downto 0);
    b_i             : in std_logic_vector(17 downto 0);
    c_i             : in std_logic_vector(47 downto 0);
    p_o             : out std_logic_vector(47 downto 0);
    valid_o         : out std_logic
        
  );
end entity;


architecture Behavioral of dsp_multiply_and_add is

constant ALUMODE       : std_logic_vector(3 downto 0):= "0000";   
constant CARRYINSEL    : std_logic_vector(2 downto 0):= "000";     
constant INMODE        : std_logic_vector(4 downto 0):= "10001"; 
constant OPMODE        : std_logic_vector(8 downto 0):= "110000101"; 
constant LATENCY       : natural:= 1;
signal valid_reg       : std_logic_vector(LATENCY - 1 downto 0) := (others=>'0');
--signal c_reg           : std_logic_vector(47 downto 0) := (others=>'0');
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
--        if valid_i = '1' then
--          c_reg <= c_i;
--        end if;
        if reset_i = '0' then
          valid_reg(0) <= valid_i;
        end if;
        valid_reg(LATENCY - 1 downto 1) <= valid_reg(LATENCY - 2 downto 0);
    end if;
  end process;
  valid_o <= valid_reg(LATENCY - 1);

  g_no_cas_ports: if USE_CASCADE_PORTS = false generate
    idsp_wrapper : entity work.dsp_wrapper
    generic map (
      ALUMODE         => ALUMODE,
      CARRYINSEL      => CARRYINSEL,
      INMODE          => INMODE,
      OPMODE          => OPMODE,
      AMULTSEL        => "A",
      A_INPUT         => "DIRECT",
      BMULTSEL        => "B",
      B_INPUT         => "DIRECT",
      PREADDINSEL     => "A",
      ALUMODEREG      => 1,
      AREG            => 1,
      BREG            => 1,
      CREG            => 1,
      MREG            => 0,      
      PREG            => 0
    )
    port map(
      clk_i           => clk_i,
      reset_i         => reset_i,
      ce_i            => valid_i,
      a_i             => a_i,
      b_i             => b_i,
      c_i             => c_i,
      p_o             => p_o
    );
  end generate;

end Behavioral;