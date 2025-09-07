
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.array_types.all;
use work.basic_pkg.all;

entity axis_skid_buffer is
  generic (
    BUFFER_DEPTH : natural := 2;
    DATA_W       : natural := 32
    
  );
  port (
    clk_i           : in std_logic;
    reset_i         : in std_logic;
    clk_en_i        : in std_logic:= '1';
    src_tdata_i     : in std_logic_vector(DATA_W - 1 downto 0);
    src_tvalid_i    : in std_logic;
    src_tready_o    : out std_logic;
    dst_tdata_o     : out std_logic_vector(DATA_W - 1 downto 0);  
    dst_tvalid_o    : out std_logic;
    dst_tready_i    : in std_logic
    
  );
end entity;


architecture Behavioral of axis_skid_buffer is
function incr_and_wrap(a : unsigned; max : natural) return unsigned is
begin
  if a = max - 1 then
  return to_unsigned(0,a'length);
  else
  return a + 1;
  end if;
end function;
signal skid_buffer      : array_slv_t(BUFFER_DEPTH - 1 downto 0)(DATA_W - 1 downto 0):= (others=>(others=>'0'));
signal src_tready       : std_logic :='1';
signal dst_tvalid       : std_logic :='0';
signal reset_prev       : std_logic :='0';
signal rd_idx           : unsigned(ceil_log2(BUFFER_DEPTH) - 1 downto 0):= (others=>'0');
signal wr_idx           : unsigned(ceil_log2(BUFFER_DEPTH) - 1 downto 0):= (others=>'0');
begin

  src_tready_o <= src_tready;
  dst_tvalid_o <= dst_tvalid;
  dst_tdata_o  <= skid_buffer(to_integer(rd_idx));
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if dst_tready_i = '1' and dst_tvalid = '1' then 
        rd_idx <= incr_and_wrap(rd_idx,BUFFER_DEPTH);
        src_tready <= '1';
        if src_tvalid_i = '1' and src_tready = '1' then
         skid_buffer(to_integer(wr_idx)) <= src_tdata_i;
         wr_idx <= incr_and_wrap(wr_idx,BUFFER_DEPTH);
         dst_tvalid <= '1';
        else
         if rd_idx = wr_idx - 1 then 
         dst_tvalid <= '0';
         end if;
        end if;
      else
        if src_tvalid_i = '1' and src_tready = '1' then
         skid_buffer(to_integer(wr_idx)) <= src_tdata_i; 
         wr_idx <= incr_and_wrap(wr_idx,BUFFER_DEPTH);
         dst_tvalid <= '1';
         if wr_idx = rd_idx - 1 then 
           src_tready <= '0';
         else 
           src_tready <= '1';
         end if;
        end if;
      end if;
      reset_prev <= reset_i;
      if reset_i = '1' then 
       rd_idx <= (others =>'0');
       wr_idx <= (others =>'0');
       dst_tvalid <= '0';
       src_tready <= '0';
      end if;
      
      if reset_prev = '1' and reset_i = '0' then 
        src_tready <= '1';
      end if;
      

    end if;
  end process;
end Behavioral;