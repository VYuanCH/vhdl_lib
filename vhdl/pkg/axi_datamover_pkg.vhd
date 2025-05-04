
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


package axi_datamover_pkg is
   constant MM2S_DATA_WIDTH : natural := 16;
   constant S2MM_DATA_WIDTH : natural := 16;
   constant MM2S_MEM_DATA_WIDTH : natural := 128;
   constant S2MM_MEM_DATA_WIDTH : natural := 128;
   constant MM2S_MAX_BURST_SIZE : natural := 256;
   constant S2MM_MAX_BURST_SIZE : natural := 256;
   constant MM2S_BTT_WIDTH      : natural := 16;
   constant S2MM_BTT_WIDTH      : natural := 16;
   constant MM2S_CMD_WIDTH      : natural := 96;
   constant S2MM_CMD_WIDTH      : natural := 96;
   constant S2MM_STS_WIDTH      : natural := 8;
   constant MM2S_STS_WIDTH      : natural := 8;
   
   
   constant ADDRESS_WIDTH       : natural := 49;


  type dma_ports_master_t is record
    axis_s2mm_tready      : std_logic;
    axis_mm2s_tdata       : std_logic_vector(MM2S_DATA_WIDTH - 1 downto 0);
    axis_mm2s_tvalid      : std_logic;
    axis_mm2s_tlast       : std_logic;
    mm2s_cmd_tready       : std_logic;
    s2mm_cmd_tready       : std_logic;
    
    s2mm_sts_tdata        : std_logic_vector(S2MM_STS_WIDTH - 1 downto 0);
    s2mm_sts_tlast        : std_logic;
    s2mm_sts_tvalid       : std_logic;
    mm2s_sts_tdata        : std_logic_vector(MM2S_STS_WIDTH - 1 downto 0);
    mm2s_sts_tlast        : std_logic;
    mm2s_sts_tvalid       : std_logic;
  end record;
  
  type dma_ports_slave_t is record
    axis_s2mm_tdata       : std_logic_vector(S2MM_DATA_WIDTH - 1 downto 0);
    axis_s2mm_tvalid      : std_logic;
    axis_s2mm_tlast       : std_logic;
    axis_mm2s_tready      : std_logic; 
    mm2s_cmd_tdata        : std_logic_vector(MM2S_CMD_WIDTH - 1 downto 0);
    mm2s_cmd_tvalid       : std_logic;
    s2mm_cmd_tdata        : std_logic_vector(S2MM_CMD_WIDTH - 1 downto 0);
    s2mm_cmd_tvalid       : std_logic;
    
    s2mm_sts_tready       : std_logic;
    mm2s_sts_tready       : std_logic;
    
  end record;
end package;