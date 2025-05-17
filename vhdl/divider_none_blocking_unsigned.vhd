
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.array_types.all;
use work.basic_pkg.all;

entity divider_none_blocking_unsigned is
  generic (
    DATA_W            : natural := 16
  );
  port (
    clk_i               : in std_logic;
    reset_i             : in std_logic;
    src_dividend_i      : in unsigned(DATA_W - 1 downto 0); -- Number being divided
    src_divisor_i       : in unsigned(DATA_W - 1 downto 0); -- Number to divide by
    src_valid_i         : in std_logic;
    dst_quotient_o      : out unsigned(DATA_W - 1 downto 0);
    dst_remainder_o     : out unsigned(DATA_W - 1 downto 0);
    dst_valid_o         : out std_logic
        
  );
end entity;

architecture Behavioral of divider_none_blocking_unsigned is

signal dividend_reg             : array_unsigned_t(0 to DATA_W)(DATA_W - 1 downto 0):= (others=>(others=>'0'));
signal partial_remainder_reg    : array_unsigned_t(0 to DATA_W)(DATA_W * 2 - 1 downto 0):= (others=>(others=>'0'));
signal quotient_reg             : array_unsigned_t(0 to DATA_W)(DATA_W downto 0):= (others=>(others=>'0'));
signal valid_reg                : std_logic_vector(DATA_W downto 0);
begin
  
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      partial_remainder_reg(0)((DATA_W * 2) - 1 downto DATA_W) <= src_divisor_i;
      partial_remainder_reg(0)(DATA_W - 1 downto 0) <= (others => '0'); 
      quotient_reg(0) <= (others => '0');
      dividend_reg(0) <= src_dividend_i;
      valid_reg(0) <= src_valid_i;
      for i in 0 to DATA_W - 1 loop
        --partial_remainder_reg(i)(DATA_W * 2 - i - 2 downto DATA_W * 2 - i - 1) <= partial_remainder_reg(i - 1)(DATA_W * 2 - 1 - i downto DATA_W * 2 - i); 
        partial_remainder_reg(i+1) <= (others => '0');
        partial_remainder_reg(i+1)(DATA_W * 2 - i - 2 downto DATA_W - i - 1) <= partial_remainder_reg(i)(DATA_W * 2 - 1 - i downto DATA_W - i); 
        quotient_reg(i+1) <= quotient_reg(i);
        dividend_reg(i+1) <= dividend_reg(i);
        valid_reg(i+1) <= valid_reg(i);
        if dividend_reg(i) >= partial_remainder_reg(i) then
          quotient_reg(i+1)(DATA_W - i) <= '1';
          dividend_reg(i+1) <= dividend_reg(i) - partial_remainder_reg(i)(DATA_W - 1 downto 0);
        end if;
      end loop;
      
      if dividend_reg(DATA_W) >= partial_remainder_reg(DATA_W) then 
        dst_quotient_o  <= quotient_reg(DATA_W)(DATA_W - 1 downto 0) + 1;
        dst_remainder_o <= dividend_reg(DATA_W) - partial_remainder_reg(DATA_W)(DATA_W - 1 downto 0);
      else
        dst_quotient_o  <= quotient_reg(DATA_W)(DATA_W - 1 downto 0);
        dst_remainder_o <= dividend_reg(DATA_W);
      end if;
      dst_valid_o <= valid_reg(DATA_W);

    end if;
  end process;

  
end Behavioral;
