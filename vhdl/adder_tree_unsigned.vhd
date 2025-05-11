
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.array_types.all;
use work.basic_pkg.all;

entity adder_tree_unsigned is
  generic (
    NUMBER_OF_INPUTS  : natural := 1;
    DATA_W            : natural := 16
  );
  port (
    clk_i               : in std_logic;
    reset_i             : in std_logic;
    src_data_i          : in array_unsigned_t(0 to NUMBER_OF_INPUTS - 1)(DATA_W - 1 downto 0);
    src_valid_i         : in std_logic;
    dst_data_o          : out unsigned(DATA_W - 1 downto 0);
    dst_valid_o         : out std_logic
        
  );
end entity;

architecture Behavioral of adder_tree_unsigned is
constant ADDER_TREE_FULL_SIZE : natural := 2**(ceil_log2(NUMBER_OF_INPUTS)+1);
signal data_tree    : array_unsigned_t(1 to ADDER_TREE_FULL_SIZE - 1)(DATA_W - 1 downto 0):= (others=>(others=>'0'));
signal valid_sr         : std_logic_vector(0 to ceil_log2(NUMBER_OF_INPUTS)) := (others => '0');

begin
  
  process(clk_i)
  begin
  if rising_edge(clk_i) then
    
    if src_valid_i = '1' then
      data_tree(2**ceil_log2(NUMBER_OF_INPUTS) to 2**ceil_log2(NUMBER_OF_INPUTS) + NUMBER_OF_INPUTS - 1) <= src_data_i;
      data_tree(2**ceil_log2(NUMBER_OF_INPUTS) + NUMBER_OF_INPUTS to ADDER_TREE_FULL_SIZE - 1 ) <= (others=>(others=>'0'));
    end if;
    valid_sr(0) <= src_valid_i;
    valid_sr(1 to ceil_log2(NUMBER_OF_INPUTS)) <= valid_sr(0 to ceil_log2(NUMBER_OF_INPUTS) - 1);
      if reset_i = '1' then
        valid_sr(0 to ceil_log2(NUMBER_OF_INPUTS))<= (others => '0');
      end if;
  end if;
  end process;
  

  g_tree_vertical : for i_idx in 0 to ceil_log2(NUMBER_OF_INPUTS) - 1 generate
    g_tree_horizontal :  for j_idx in 0 to (2**i_idx)-1 generate
      process(clk_i)
      begin
        if rising_edge(clk_i) then
          data_tree(2**i_idx+j_idx)  <= data_tree(2**(i_idx+1) + j_idx*2) +  data_tree(2**(i_idx+1) + j_idx*2 + 1);
          if reset_i = '1' then
            data_tree(2**i_idx+j_idx)  <= (others =>'0');
          end if;
        end if;
      end process;
    end generate;
  end generate;

  dst_data_o  <= data_tree(1);
  dst_valid_o <= valid_sr(ceil_log2(NUMBER_OF_INPUTS));

end Behavioral;
