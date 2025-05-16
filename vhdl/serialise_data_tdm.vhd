-- Serialise data by time slots (TDM)
-- Reserve cycle for channels with valid = '0'
-- e.g when src_valid = "0101", src_data_i = "UUU","123","UUU","456"
-- Output in the next 4 clock cycles are: 
-- clk cycle 1 : dst_valid_o = '0', src_data_i = "123"
-- clk cycle 2 : dst_valid_o = '1', src_data_i = "456"
-- clk cycle 3 : dst_valid_o = '0', src_data_i = "UUU"
-- clk cycle 4 : dst_valid_o = '1', src_data_i = "UUU"
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.array_types.all;
use work.basic_pkg.all;

entity serialise_data_tdm is
  generic (
    NUMBER_OF_INPUTS  : natural;
    DATA_W            : natural := 16
  );
  port (
    clk_i               : in std_logic;
    reset_i             : in std_logic;
    src_data_i          : in array_slv_t(0 to NUMBER_OF_INPUTS - 1)(DATA_W - 1 downto 0);
    src_valid_i         : in std_logic_vector(0 to NUMBER_OF_INPUTS - 1);
    dst_data_o          : out std_logic_vector(DATA_W - 1 downto 0);
    dst_valid_o         : out std_logic
        
  );
end entity;

architecture Behavioral of serialise_data_tdm is

signal channel_index         : unsigned(ceil_log2(NUMBER_OF_INPUTS) - 1 downto 0);

begin
  
  dst_valid_o <= src_valid_i(to_integer(channel_index));
  dst_data_o  <= src_data_i(to_integer(channel_index));
  process(clk_i)
  begin
    if rising_edge(clk) then
      channel_index <= channel_index + 1;
      if channel_index = NUMBER_OF_INPUTS - 1 then
        channel_index <= (others =>'0');
      end if;
    end if;
  end process;


end Behavioral;
