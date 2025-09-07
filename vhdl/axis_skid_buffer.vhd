
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.array_types.all;
use work.basic_pkg.all;
-- Skid buffer for axis interface
-- This module should be kept simple as it will likely be generated many copies for multiple axis modules
-- Use Low buffer depth. 
-- If more pipeline is required, it is preferred to generate multiple copies of this module and connect them in a chain.
-- Todo: Add Tlast, it should go through the same buffering as tdata. 
--       Complete all conditional statement so it does not infer unnecessary control sets
--       Check implementation results and optimise for resource usage. 
--       Add cocotb for more comprehensive testbench. Currently only basic testbenching is done 
entity axis_skid_buffer is
  generic (
    BUFFER_DEPTH : natural := 2; -- Recommended depth: 2
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
      -- src tready is always 1 if dst tready is 1 in the previous cycle.
      -- This is because one sample has been taken out, therefore one buffer space is available
      src_tready <= dst_tready_i; 
      
      if dst_tready_i = '1' and dst_tvalid = '1' then 
        -- One sample has been taken out, incr the read pointer
        rd_idx <= incr_and_wrap(rd_idx,BUFFER_DEPTH);
        -- The src should always be ready in this case
        src_tready <= '1';
        if src_tvalid_i = '1' and src_tready = '1' then
         -- One sample in, one sample out, incr wr pointer too
         -- Put data into buffer.
         -- Valid data in the next cycle.
         skid_buffer(to_integer(wr_idx)) <= src_tdata_i;
         wr_idx <= incr_and_wrap(wr_idx,BUFFER_DEPTH);
         dst_tvalid <= '1';
        else
         if rd_idx = wr_idx - 1 then 
          -- Rd pointer = Wr Pointer after incr in this cycle, no more data in the buffer.
          dst_tvalid <= '0';
         end if;
        end if;
      else
        if src_tvalid_i = '1' and src_tready = '1' then
        -- One sample has been taken out, no sample taken in for this cycle. 
        -- Write data into buffer, and incr write pointer only.
         skid_buffer(to_integer(wr_idx)) <= src_tdata_i; 
         wr_idx <= incr_and_wrap(wr_idx,BUFFER_DEPTH);
         dst_tvalid <= '1';
         if wr_idx = rd_idx - 1 then 
          -- If the wr pointer = rd pointer after incr, the buffer is full 
          -- The ring buffer has ben through the whole circle. Set ready to 0
           src_tready <= '0';
         else 
           src_tready <= '1';
         end if;
        end if;
      end if;

      reset_prev <= reset_i;
      -- Reset, set rd and wr pointer to 0
      if reset_i = '1' then 
       rd_idx <= (others =>'0');
       wr_idx <= (others =>'0');
       dst_tvalid <= '0';
       src_tready <= '0';
      end if;
      -- Reset complete, the buffer should be empty, therefore set input ready to 1
      if reset_prev = '1' and reset_i = '0' then 
        src_tready <= '1';
      end if;
      

    end if;
  end process;
end Behavioral;