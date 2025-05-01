----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/07/2025 09:25:54 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use work.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.axil_interface_pkg.all;
use work.array_types.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
--  Port ( );
end top;

architecture Behavioral of top is

constant  DMA_MM2S_DATA_WIDTH     : natural := 16;
constant  DMA_S2MM_DATA_WIDTH     : natural := 16;
constant  DMA_MM2S_MEM_DATA_WIDTH : natural := 128;
constant  DMA_S2MM_MEM_DATA_WIDTH : natural := 128;
constant  DMA_MM2S_MAX_BURST_SIZE : natural := 256;
constant  DMA_S2MM_MAX_BURST_SIZE : natural := 256;
constant  DMA_MM2S_BTT_WIDTH      : natural := 16;
constant  DMA_S2MM_BTT_WIDTH      : natural := 16;
constant  DMA_MM2S_CMD_WIDTH      : natural := 96;
constant  DMA_S2MM_CMD_WIDTH      : natural := 96;
constant  DMA_ADDRESS_WIDTH       : natural := 49;
constant  DMA_NUM_OF_WORDS_WIDTH  : natural := 32;


signal pl_clk0_0 : std_logic;
signal counter   : unsigned(31 downto 0);
signal gpio_out  : std_logic_vector(31 downto 0);
constant NUMBER_OF_AXIL_REGISTERS  : natural := 10;
signal axil_master  : axil_master_t;
signal axil_slave   : axil_slave_t;
signal axil_write_regs  : array_slv_t(NUMBER_OF_AXIL_REGISTERS - 1 downto 0)(AXIL_DATA_W - 1 downto 0);

signal M_DMA_MM2S_0_tdata            : STD_LOGIC_VECTOR ( 15 downto 0 );
signal M_DMA_MM2S_0_tkeep            : STD_LOGIC_VECTOR ( 1 downto 0 );
signal M_DMA_MM2S_0_tlast            : STD_LOGIC;
signal M_DMA_MM2S_0_tready           : STD_LOGIC;  
signal M_DMA_MM2S_0_tvalid           : STD_LOGIC;  
signal M_DMA_MM2S_STS_0_tdata        : STD_LOGIC_VECTOR ( 7 downto 0 );    
signal M_DMA_MM2S_STS_0_tkeep        : STD_LOGIC_VECTOR ( 0 to 0 );    
signal M_DMA_MM2S_STS_0_tlast        : STD_LOGIC;    
signal M_DMA_MM2S_STS_0_tready       : STD_LOGIC;      
signal M_DMA_MM2S_STS_0_tvalid       : STD_LOGIC;      
signal M_DMA_S2MM_STS_0_tdata        : STD_LOGIC_VECTOR ( 31 downto 0 );    
signal M_DMA_S2MM_STS_0_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 );    
signal M_DMA_S2MM_STS_0_tlast        : STD_LOGIC;    
signal M_DMA_S2MM_STS_0_tready       : STD_LOGIC;      
signal M_DMA_S2MM_STS_0_tvalid       : STD_LOGIC;      
signal S_DMA_MM2S_CMD_0_tdata        : STD_LOGIC_VECTOR ( 95 downto 0 );    
signal S_DMA_MM2S_CMD_0_tready       : STD_LOGIC;      
signal S_DMA_MM2S_CMD_0_tvalid       : STD_LOGIC;      
signal S_DMA_S2MM_0_tdata            : STD_LOGIC_VECTOR ( 15 downto 0 );
signal S_DMA_S2MM_0_tkeep            : STD_LOGIC_VECTOR ( 1 downto 0 );
signal S_DMA_S2MM_0_tlast            : STD_LOGIC;
signal S_DMA_S2MM_0_tready           : STD_LOGIC;  
signal S_DMA_S2MM_0_tvalid           : STD_LOGIC;  
signal S_DMA_S2MM_CMD_0_tdata        : STD_LOGIC_VECTOR ( 95 downto 0 );    
signal S_DMA_S2MM_CMD_0_tready       : STD_LOGIC;      
signal S_DMA_S2MM_CMD_0_tvalid       : STD_LOGIC;      


signal dma_controller_write_address         : unsigned(DMA_ADDRESS_WIDTH - 1 downto 0);       
signal dma_controller_write_num_of_words    : unsigned(DMA_NUM_OF_WORDS_WIDTH - 1 downto 0);             
signal dma_controller_write_start           : std_logic;     
signal dma_controller_read_address          : unsigned(DMA_ADDRESS_WIDTH - 1 downto 0);       
signal dma_controller_read_num_of_words     : unsigned(DMA_NUM_OF_WORDS_WIDTH - 1 downto 0);           
signal dma_controller_read_start            : std_logic;     
signal dma_controller_m_tdata               : std_logic_vector(DMA_MM2S_DATA_WIDTH - 1 downto 0); 
signal dma_controller_m_tvalid              : std_logic;   
signal dma_controller_m_tready              : std_logic;   
signal dma_controller_m_tlast               : std_logic; 
signal dma_controller_s_tdata               : std_logic_vector(DMA_S2MM_DATA_WIDTH - 1 downto 0); 
signal dma_controller_s_tvalid              : std_logic;   
signal dma_controller_s_tready              : std_logic; -- Usually this is an output, but in this case the axi datamover controller only monitors the master channel of datamover, the slave module receiving the data should assign the tready.   
signal dma_controller_s_tlast               : std_logic; 

attribute mark_debug : string;
--attribute mark_debug of counter: signal is "true";
--attribute mark_debug of gpio_out: signal is "true";
--attribute mark_debug of axil_master: signal is "true";
--attribute mark_debug of axil_slave: signal is "true";
--attribute mark_debug of axil_write_regs: signal is "true";

attribute mark_debug of dma_controller_m_tdata   : signal is "true";
attribute mark_debug of dma_controller_m_tvalid  : signal is "true";
attribute mark_debug of dma_controller_m_tready  : signal is "true";
attribute mark_debug of dma_controller_m_tlast   : signal is "true";
attribute mark_debug of dma_controller_s_tdata   : signal is "true";
attribute mark_debug of dma_controller_s_tvalid  : signal is "true";
attribute mark_debug of dma_controller_s_tready  : signal is "true";
attribute mark_debug of dma_controller_s_tlast   : signal is "true";

attribute mark_debug of S_DMA_MM2S_CMD_0_tdata   : signal is "true";
attribute mark_debug of S_DMA_MM2S_CMD_0_tready  : signal is "true";
attribute mark_debug of S_DMA_MM2S_CMD_0_tvalid  : signal is "true";
attribute mark_debug of S_DMA_S2MM_CMD_0_tdata   : signal is "true";
attribute mark_debug of S_DMA_S2MM_CMD_0_tready  : signal is "true";
attribute mark_debug of S_DMA_S2MM_CMD_0_tvalid  : signal is "true";
begin
ibd_1 : entity work.design_1_wrapper
port map(
    pl_clk0_0 => pl_clk0_0,
    gpio_0_out_tri_o => gpio_out,
    gpio_1_in_tri_i  => std_logic_vector(counter),
    
    -- axil_master
    M02_AXI_0_awaddr      => axil_master.awaddr,    
    M02_AXI_0_awprot      => axil_master.awprot,    
    M02_AXI_0_awvalid     => axil_master.awvalid,    
    M02_AXI_0_wdata       => axil_master.wdata,  
    M02_AXI_0_wstrb       => axil_master.wstrb,  
    M02_AXI_0_wvalid      => axil_master.wvalid,    
    M02_AXI_0_bready      => axil_master.bready,    
    M02_AXI_0_araddr      => axil_master.araddr,    
    M02_AXI_0_arprot      => axil_master.arprot,    
    M02_AXI_0_arvalid     => axil_master.arvalid,    
    M02_AXI_0_rready      => axil_master.rready,
    -- axil slave     
    M02_AXI_0_awready     => axil_slave.awready,    
    M02_AXI_0_wready      => axil_slave.wready,    
    M02_AXI_0_bresp       => axil_slave.bresp,  
    M02_AXI_0_bvalid      => axil_slave.bvalid,    
    M02_AXI_0_arready     => axil_slave.arready,    
    M02_AXI_0_rdata       => axil_slave.rdata,  
    M02_AXI_0_rresp       => axil_slave.rresp,  
    M02_AXI_0_rvalid      => axil_slave.rvalid,

    M_AXIS_MM2S_0_tdata         => M_DMA_MM2S_0_tdata,
    M_AXIS_MM2S_0_tkeep         => M_DMA_MM2S_0_tkeep,
    M_AXIS_MM2S_0_tlast         => M_DMA_MM2S_0_tlast,
    M_AXIS_MM2S_0_tready        => M_DMA_MM2S_0_tready,  
    M_AXIS_MM2S_0_tvalid        => M_DMA_MM2S_0_tvalid,  
    M_AXIS_MM2S_STS_0_tdata     => M_DMA_MM2S_STS_0_tdata,    
    M_AXIS_MM2S_STS_0_tkeep     => M_DMA_MM2S_STS_0_tkeep,    
    M_AXIS_MM2S_STS_0_tlast     => M_DMA_MM2S_STS_0_tlast,    
    M_AXIS_MM2S_STS_0_tready    => '1',      
    M_AXIS_MM2S_STS_0_tvalid    => M_DMA_MM2S_STS_0_tvalid,      
    M_AXIS_S2MM_STS_0_tdata     => M_DMA_S2MM_STS_0_tdata,    
    M_AXIS_S2MM_STS_0_tkeep     => M_DMA_S2MM_STS_0_tkeep,    
    M_AXIS_S2MM_STS_0_tlast     => M_DMA_S2MM_STS_0_tlast,    
    M_AXIS_S2MM_STS_0_tready    => '1',      
    M_AXIS_S2MM_STS_0_tvalid    => M_DMA_S2MM_STS_0_tvalid,      
    S_AXIS_MM2S_CMD_0_tdata     => S_DMA_MM2S_CMD_0_tdata,    
    S_AXIS_MM2S_CMD_0_tready    => S_DMA_MM2S_CMD_0_tready,      
    S_AXIS_MM2S_CMD_0_tvalid    => S_DMA_MM2S_CMD_0_tvalid,      
    S_AXIS_S2MM_0_tdata         => S_DMA_S2MM_0_tdata,
    S_AXIS_S2MM_0_tkeep         => S_DMA_S2MM_0_tkeep,
    S_AXIS_S2MM_0_tlast         => S_DMA_S2MM_0_tlast,
    S_AXIS_S2MM_0_tready        => S_DMA_S2MM_0_tready,  
    S_AXIS_S2MM_0_tvalid        => S_DMA_S2MM_0_tvalid,  
    S_AXIS_S2MM_CMD_0_tdata     => S_DMA_S2MM_CMD_0_tdata,    
    S_AXIS_S2MM_CMD_0_tready    => S_DMA_S2MM_CMD_0_tready,      
    S_AXIS_S2MM_CMD_0_tvalid    => S_DMA_S2MM_CMD_0_tvalid      
    
);


dma_controller_m_tready <= '1';

iaxi_datamover_controller : entity work.axi_datamover_controller
generic map (
  MM2S_DATA_WIDTH      => DMA_MM2S_DATA_WIDTH, 
  S2MM_DATA_WIDTH      => DMA_S2MM_DATA_WIDTH, 
  MM2S_MEM_DATA_WIDTH  => DMA_MM2S_MEM_DATA_WIDTH, 
  S2MM_MEM_DATA_WIDTH  => DMA_S2MM_MEM_DATA_WIDTH, 
  MM2S_MAX_BURST_SIZE  => DMA_MM2S_MAX_BURST_SIZE, 
  S2MM_MAX_BURST_SIZE  => DMA_S2MM_MAX_BURST_SIZE, 
  MM2S_BTT_WIDTH       => DMA_MM2S_BTT_WIDTH, 
  S2MM_BTT_WIDTH       => DMA_S2MM_BTT_WIDTH, 
  MM2S_CMD_WIDTH       => DMA_MM2S_CMD_WIDTH, 
  S2MM_CMD_WIDTH       => DMA_S2MM_CMD_WIDTH, 
  ADDRESS_WIDTH        => DMA_ADDRESS_WIDTH, 
  NUM_OF_WORDS_WIDTH   => DMA_NUM_OF_WORDS_WIDTH
)
port map(
  clk_i                => pl_clk0_0,
  reset_i              => '0',


  write_address_i      => dma_controller_write_address, 
  write_num_of_words_i => dma_controller_write_num_of_words,
  write_start_i        => dma_controller_write_start,
  read_address_i       => dma_controller_read_address,
  read_num_of_words_i  => dma_controller_read_num_of_words,
  read_start_i         => dma_controller_read_start,
  data_m_tdata_o       => dma_controller_m_tdata,
  data_m_tvalid_o      => dma_controller_m_tvalid,
  data_m_tready_i      => dma_controller_m_tready,
  data_m_tlast_o       => dma_controller_m_tlast,
  data_s_tdata_i       => dma_controller_s_tdata,
  data_s_tvalid_i      => dma_controller_s_tvalid,
  data_s_tready_o      => dma_controller_s_tready,
  data_s_tlast_i       => dma_controller_s_tlast,
  
  -- Axi Datamover interface
  -- axi_datamover axis interface
  axis_s2mm_tdata_o    => S_DMA_S2MM_0_tdata, 
  axis_s2mm_tvalid_o   => S_DMA_S2MM_0_tvalid,
  axis_s2mm_tready_i   => S_DMA_S2MM_0_tready,
  axis_s2mm_tlast_o    => S_DMA_S2MM_0_tlast, 
  axis_mm2s_tdata_i    => M_DMA_MM2S_0_tdata, 
  axis_mm2s_tvalid_i   => M_DMA_MM2S_0_tvalid,
  axis_mm2s_tready_o   => M_DMA_MM2S_0_tready,
  axis_mm2s_tlast_i    => M_DMA_MM2S_0_tlast, 
  
  -- axi_datamover cmd interface
  mm2s_cmd_m_tdata_o   => S_DMA_MM2S_CMD_0_tdata,
  mm2s_cmd_m_tvalid_o  => S_DMA_MM2S_CMD_0_tvalid,  
  mm2s_cmd_m_tready_i  => S_DMA_MM2S_CMD_0_tready,  

  -- axi_datamover cmd interface
  s2mm_cmd_m_tdata_o   => S_DMA_S2MM_CMD_0_tdata, 
  s2mm_cmd_m_tvalid_o  => S_DMA_S2MM_CMD_0_tvalid,  
  s2mm_cmd_m_tready_i  => S_DMA_S2MM_CMD_0_tready  
);

dma_controller_write_start                      <= axil_write_regs(0)(0);
dma_controller_write_address(31 downto 0)       <= unsigned(axil_write_regs(1)(31 downto 0));
dma_controller_write_address(48 downto 32)      <= unsigned(axil_write_regs(2)(16 downto 0));
dma_controller_write_num_of_words(31 downto 0)  <= unsigned(axil_write_regs(3)(31 downto 0));

dma_controller_read_start                      <= axil_write_regs(4)(0);
dma_controller_read_address(31 downto 0)       <= unsigned(axil_write_regs(5)(31 downto 0));
dma_controller_read_address(48 downto 32)      <= unsigned(axil_write_regs(6)(16 downto 0));
dma_controller_read_num_of_words(31 downto 0)  <= unsigned(axil_write_regs(7)(31 downto 0));

iaxi_reg : entity work.axi_registers
generic map (
  AXIL_BASE_ADDRESS   => x"A0020000",
  NUMBER_OF_REGISTERS => NUMBER_OF_AXIL_REGISTERS,
  WRITE_MASK          => (others =>'1')
)
port map(
  clk_i             => pl_clk0_0,
  reset_i           => '0',
  axil_master_i     => axil_master,
  axil_slave_o      => axil_slave,
  read_reg_i        => (others=>( others =>'0')),
  write_reg_o       => axil_write_regs
);
process(pl_clk0_0)
begin
 if rising_edge(pl_clk0_0) then
    counter <= counter + 1;
 end if;
end process;

end Behavioral;

