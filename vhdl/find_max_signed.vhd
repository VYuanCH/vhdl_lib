
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.array_types.all;
use work.basic_pkg.all;

entity find_max_signed is
  generic (
    NUMBER_OF_INPUTS  : natural := 1;
    DATA_W            : natural := 16
  );
  port (
    clk_i               : in std_logic;
    reset_i             : in std_logic;
    src_data_i          : in array_signed_t(0 to NUMBER_OF_INPUTS - 1)(DATA_W - 1 downto 0);
    src_valid_i         : in std_logic;
    dst_max_data_o      : out signed(DATA_W - 1 downto 0);
    dst_max_index_o     : out unsigned(ceil_log2(NUMBER_OF_INPUTS) - 1 downto 0);
    dst_valid_o         : out std_logic
        
  );
end entity;

architecture Behavioral of find_max_signed is
constant MAX_TREE_FULL_SIZE : natural := 2**(ceil_log2(NUMBER_OF_INPUTS)+1);
signal max_index_tree   : array_unsigned_t(1 to MAX_TREE_FULL_SIZE - 1)(ceil_log2(NUMBER_OF_INPUTS) - 1 downto 0):= (others=>(others=>'0'));
signal max_data_tree    : array_signed_t(1 to MAX_TREE_FULL_SIZE - 1)(DATA_W - 1 downto 0):= (others=>(others=>'0'));
signal valid_sr         : std_logic_vector(0 to ceil_log2(NUMBER_OF_INPUTS)) := (others => '0');

begin

  g_index: for max_idx in 0 to NUMBER_OF_INPUTS - 1 generate
    max_index_tree(2**ceil_log2(NUMBER_OF_INPUTS)+ max_idx) <= to_unsigned(max_idx,ceil_log2(NUMBER_OF_INPUTS));
  end generate;
  
  process(clk_i)
  begin
  if rising_edge(clk_i) then
    
    if src_valid_i = '1' then
      max_data_tree(2**ceil_log2(NUMBER_OF_INPUTS) to 2**ceil_log2(NUMBER_OF_INPUTS) + NUMBER_OF_INPUTS - 1) <= src_data_i;
      max_data_tree(2**ceil_log2(NUMBER_OF_INPUTS) + NUMBER_OF_INPUTS to MAX_TREE_FULL_SIZE - 1 ) <= (others=>(others=>'0'));
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
          if max_data_tree(2**(i_idx+1) + j_idx*2) > max_data_tree(2**(i_idx+1) + j_idx*2 + 1) then
            max_data_tree(2**i_idx+j_idx)  <= max_data_tree(2**(i_idx+1) + j_idx*2);
            max_index_tree(2**i_idx+j_idx) <= max_index_tree(2**(i_idx+1) + j_idx*2);
          else
            max_data_tree(2**i_idx+j_idx) <= max_data_tree(2**(i_idx+1) + j_idx*2 + 1);
            max_index_tree(2**i_idx+j_idx) <= max_index_tree(2**(i_idx+1) + j_idx*2 + 1);
          end if;
          if reset_i = '1' then
            max_data_tree(2**i_idx+j_idx)  <= (others =>'0');
            max_index_tree(2**i_idx+j_idx) <= (others =>'0');
          end if;
        end if;
      end process;
    end generate;
  end generate;

  dst_max_index_o <= max_index_tree(1);
  dst_max_data_o  <= max_data_tree(1);
  dst_valid_o     <= valid_sr(ceil_log2(NUMBER_OF_INPUTS));

end Behavioral;
