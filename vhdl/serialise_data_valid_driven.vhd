-- Serialise data when input valid array is not all 0
-- Do not reserve cycle for channels with valid = '0'
-- e.g when src_valid = "0101", src_data_i = "UUU","123","UUU","456"
-- Output in the next 4 clock cycles are: 
-- clk cycle 1 : dst_valid_o = '1', src_data_i = "123"
-- clk cycle 2 : dst_valid_o = '1', src_data_i = "456"
-- clk cycle 3 : dst_valid_o = '0', src_data_i = "UUU"
-- clk cycle 4 : dst_valid_o = '0', src_data_i = "UUU"
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.array_types.all;
use work.basic_pkg.all;

entity serialise_data_valid_driven is
  generic (
    NUMBER_OF_INPUTS  : natural;
    DATA_W            : natural := 16
  );
  port (
    clk_i               : in std_logic;
    reset_i             : in std_logic;
    src_data_i          : in array_slv_t(0 to NUMBER_OF_INPUTS - 1)(DATA_W - 1 downto 0);
    src_valid_i         : in std_logic_vector(0 to NUMBER_OF_INPUTS - 1);
    src_ready_o         : out std_logic;
    dst_data_o          : out std_logic_vector(DATA_W - 1 downto 0);
    dst_valid_o         : out std_logic;
    dst_ready_i         : in std_logic
        
  );
end entity;

architecture Behavioral of serialise_data_valid_driven is

signal src_data_reg          : array_slv_t(0 to NUMBER_OF_INPUTS - 1)(DATA_W - 1 downto 0):= (others=>(others=>'0'));
signal src_valid_reg         : std_logic_vector(0 to NUMBER_OF_INPUTS - 1):= (others => '0');

begin
  
  src_ready_o <= not (or src_valid_reg);
  process(clk_i)
    variable array_idx_var :natural := 0;
  begin
  if rising_edge(clk_i) then
  
    if (or src_valid_i) = '1' and (or src_valid_reg) = '0' then 
      src_valid_reg <= src_valid_i;
      src_data_reg <= src_data_i;
    end if;

    for i in NUMBER_OF_INPUTS - 1 downto 0 loop
      if src_valid_reg(i) = '1' then
        array_idx_var := i;
      end if;
    end loop;

    dst_valid_o <= src_valid_reg(array_idx_var);
    dst_data_o  <= src_data_reg(array_idx_var);
    if dst_ready_i = '1' then
      src_valid_reg(array_idx_var) <= '0';
    end if;


      
  end if;
  end process;


end Behavioral;
