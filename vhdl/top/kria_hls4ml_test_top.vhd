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
use work.axi_datamover_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
--  Port ( );
end top;

architecture Behavioral of top is

constant DMA_NUM_OF_WORDS_WIDTH  : natural := 32;
constant MNIST_MODEL_OUTPUT_W    : natural := 10;
constant MNIST_MODEL_OUTPUT_DATA_W    : natural := 16;

signal pl_clk0_0 : std_logic;
signal counter   : unsigned(31 downto 0);
signal gpio_out  : std_logic_vector(31 downto 0);
constant NUMBER_OF_AXIL_REGISTERS  : natural := 10;
signal global_axil_reg_master  : axil_master_t;
signal global_axil_reg_slave   : axil_slave_t;
signal dma_axil_reg_master  : axil_master_t;
signal dma_axil_reg_slave   : axil_slave_t;
signal axil_write_regs  : array_slv_t(NUMBER_OF_AXIL_REGISTERS - 1 downto 0)(AXIL_DATA_W - 1 downto 0);

signal dma_controller_m_tdata               : std_logic_vector(MM2S_DATA_WIDTH - 1 downto 0); 
signal dma_controller_m_tvalid              : std_logic;   
signal dma_controller_m_tready              : std_logic;   
signal dma_controller_m_tlast               : std_logic; 
signal dma_controller_s_tdata               : std_logic_vector(S2MM_DATA_WIDTH - 1 downto 0); 
signal dma_controller_s_tvalid              : std_logic;   
signal dma_controller_s_tready              : std_logic; -- Usually this is an output, but in this case the axi datamover controller only monitors the master channel of datamover, the slave module receiving the data should assign the tready.   
signal dma_controller_s_tlast               : std_logic; 
signal dma_controller_write_start_prev      : std_logic;
signal dma_interface_master                 : dma_ports_master_t;
signal dma_interface_slave                  : dma_ports_slave_t;
signal mnist_model_out_data                 : array_slv_t(MNIST_MODEL_OUTPUT_W - 1 downto 0)(MNIST_MODEL_OUTPUT_DATA_W - 1 downto 0);
signal mnist_model_out_valid                : std_logic_vector(MNIST_MODEL_OUTPUT_W - 1 downto 0);
signal mnist_start                          : std_logic;  
signal mnist_start_prev                     : std_logic;      
signal mnist_model_ap_done                  : std_logic;          
signal mnist_model_ap_idle                  : std_logic;          
signal mnist_model_ap_ready                 : std_logic;          
signal mnist_model_ap_start                 : std_logic:='0';          
attribute mark_debug : string;
--attribute mark_debug of counter: signal is "true";
--attribute mark_debug of gpio_out: signal is "true";
--attribute mark_debug of axil_master: signal is "true";
--attribute mark_debug of dma_interface_master: signal is "true";
--attribute mark_debug of dma_interface_slave: signal is "true";

attribute mark_debug of dma_controller_m_tdata   : signal is "true";
attribute mark_debug of dma_controller_m_tvalid  : signal is "true";
attribute mark_debug of dma_controller_m_tready  : signal is "true";
attribute mark_debug of dma_controller_m_tlast   : signal is "true";
attribute mark_debug of mnist_model_out_data    : signal is "true";
attribute mark_debug of mnist_model_out_valid   : signal is "true";
attribute mark_debug of mnist_start             : signal is "true"; 
attribute mark_debug of mnist_start_prev        : signal is "true";      
attribute mark_debug of mnist_model_ap_done     : signal is "true";        
attribute mark_debug of mnist_model_ap_idle     : signal is "true";        
attribute mark_debug of mnist_model_ap_ready    : signal is "true";          
attribute mark_debug of mnist_model_ap_start    : signal is "true";          
--attribute mark_debug of dma_controller_s_tdata   : signal is "true";
--attribute mark_debug of dma_controller_s_tvalid  : signal is "true";
--attribute mark_debug of dma_controller_s_tready  : signal is "true";
--attribute mark_debug of dma_controller_s_tlast   : signal is "true";

begin
ibd_1 : entity work.design_1_wrapper
port map(
    pl_clk0_0 => pl_clk0_0,
    gpio_0_out_tri_o => gpio_out,
    gpio_1_in_tri_i  => std_logic_vector(counter),
    
    -- axil_master
    global_reg_axil_awaddr      => global_axil_reg_master.awaddr,    
    global_reg_axil_awprot      => global_axil_reg_master.awprot,    
    global_reg_axil_awvalid     => global_axil_reg_master.awvalid,    
    global_reg_axil_wdata       => global_axil_reg_master.wdata,  
    global_reg_axil_wstrb       => global_axil_reg_master.wstrb,  
    global_reg_axil_wvalid      => global_axil_reg_master.wvalid,    
    global_reg_axil_bready      => global_axil_reg_master.bready,    
    global_reg_axil_araddr      => global_axil_reg_master.araddr,    
    global_reg_axil_arprot      => global_axil_reg_master.arprot,    
    global_reg_axil_arvalid     => global_axil_reg_master.arvalid,    
    global_reg_axil_rready      => global_axil_reg_master.rready,
    -- axil slave     
    global_reg_axil_awready     => global_axil_reg_slave.awready,    
    global_reg_axil_wready      => global_axil_reg_slave.wready,    
    global_reg_axil_bresp       => global_axil_reg_slave.bresp,  
    global_reg_axil_bvalid      => global_axil_reg_slave.bvalid,    
    global_reg_axil_arready     => global_axil_reg_slave.arready,    
    global_reg_axil_rdata       => global_axil_reg_slave.rdata,  
    global_reg_axil_rresp       => global_axil_reg_slave.rresp,  
    global_reg_axil_rvalid      => global_axil_reg_slave.rvalid,

    dma_reg_axil_awaddr         => dma_axil_reg_master.awaddr,    
    dma_reg_axil_awprot         => dma_axil_reg_master.awprot,    
    dma_reg_axil_awvalid        => dma_axil_reg_master.awvalid,    
    dma_reg_axil_wdata          => dma_axil_reg_master.wdata,  
    dma_reg_axil_wstrb          => dma_axil_reg_master.wstrb,  
    dma_reg_axil_wvalid         => dma_axil_reg_master.wvalid,    
    dma_reg_axil_bready         => dma_axil_reg_master.bready,    
    dma_reg_axil_araddr         => dma_axil_reg_master.araddr,    
    dma_reg_axil_arprot         => dma_axil_reg_master.arprot,    
    dma_reg_axil_arvalid        => dma_axil_reg_master.arvalid,    
    dma_reg_axil_rready         => dma_axil_reg_master.rready,
    -- axil slave     
    dma_reg_axil_awready        => dma_axil_reg_slave.awready,    
    dma_reg_axil_wready         => dma_axil_reg_slave.wready,    
    dma_reg_axil_bresp          => dma_axil_reg_slave.bresp,  
    dma_reg_axil_bvalid         => dma_axil_reg_slave.bvalid,    
    dma_reg_axil_arready        => dma_axil_reg_slave.arready,    
    dma_reg_axil_rdata          => dma_axil_reg_slave.rdata,  
    dma_reg_axil_rresp          => dma_axil_reg_slave.rresp,  
    dma_reg_axil_rvalid         => dma_axil_reg_slave.rvalid,


    M_AXIS_MM2S_STS_0_tdata     => dma_interface_master.mm2s_sts_tdata,    
    M_AXIS_MM2S_STS_0_tkeep     => open,    
    M_AXIS_MM2S_STS_0_tlast     => dma_interface_master.mm2s_sts_tlast,    
    M_AXIS_MM2S_STS_0_tready    => dma_interface_slave.mm2s_sts_tready,      
    M_AXIS_MM2S_STS_0_tvalid    => dma_interface_master.mm2s_sts_tvalid,      
    M_AXIS_S2MM_STS_0_tdata     => dma_interface_master.s2mm_sts_tdata,    
    M_AXIS_S2MM_STS_0_tkeep     => open,    
    M_AXIS_S2MM_STS_0_tlast     => dma_interface_master.s2mm_sts_tlast,    
    M_AXIS_S2MM_STS_0_tready    => dma_interface_slave.s2mm_sts_tready,      
    M_AXIS_S2MM_STS_0_tvalid    => dma_interface_master.s2mm_sts_tvalid,      

    M_AXIS_MM2S_0_tdata         => dma_interface_master.axis_mm2s_tdata,
    M_AXIS_MM2S_0_tkeep         => open,
    M_AXIS_MM2S_0_tlast         => dma_interface_master.axis_mm2s_tlast,
    M_AXIS_MM2S_0_tready        => dma_interface_slave.axis_mm2s_tready,  
    M_AXIS_MM2S_0_tvalid        => dma_interface_master.axis_mm2s_tvalid,    
    S_AXIS_MM2S_CMD_0_tdata     => dma_interface_slave.mm2s_cmd_tdata,    
    S_AXIS_MM2S_CMD_0_tready    => dma_interface_master.mm2s_cmd_tready,      
    S_AXIS_MM2S_CMD_0_tvalid    => dma_interface_slave.mm2s_cmd_tvalid,      
    S_AXIS_S2MM_0_tdata         => dma_interface_slave.axis_s2mm_tdata,
    S_AXIS_S2MM_0_tkeep         => (others => '1'),
    S_AXIS_S2MM_0_tlast         => dma_interface_slave.axis_s2mm_tlast,
    S_AXIS_S2MM_0_tready        => dma_interface_master.axis_s2mm_tready,  
    S_AXIS_S2MM_0_tvalid        => dma_interface_slave.axis_s2mm_tvalid,  
    S_AXIS_S2MM_CMD_0_tdata     => dma_interface_slave.s2mm_cmd_tdata,    
    S_AXIS_S2MM_CMD_0_tready    => dma_interface_master.s2mm_cmd_tready,      
    S_AXIS_S2MM_CMD_0_tvalid    => dma_interface_slave.s2mm_cmd_tvalid,

    ap_ctrl_0_done              => mnist_model_ap_done,
    ap_ctrl_0_idle              => mnist_model_ap_idle,
    ap_ctrl_0_ready             => mnist_model_ap_ready,
    ap_ctrl_0_start             => mnist_model_ap_start,

    input_1_0_tdata             => dma_controller_m_tdata,
    input_1_0_tready            => dma_controller_m_tready,
    input_1_0_tvalid            => dma_controller_m_tvalid,

    layer5_out_0_0              => mnist_model_out_data(0),
    layer5_out_0_ap_vld_0       => mnist_model_out_valid(0),      
    layer5_out_1_0              => mnist_model_out_data(1),
    layer5_out_1_ap_vld_0       => mnist_model_out_valid(1),      
    layer5_out_2_0              => mnist_model_out_data(2),
    layer5_out_2_ap_vld_0       => mnist_model_out_valid(2),      
    layer5_out_3_0              => mnist_model_out_data(3),
    layer5_out_3_ap_vld_0       => mnist_model_out_valid(3),      
    layer5_out_4_0              => mnist_model_out_data(4),
    layer5_out_4_ap_vld_0       => mnist_model_out_valid(4),      
    layer5_out_5_0              => mnist_model_out_data(5),
    layer5_out_5_ap_vld_0       => mnist_model_out_valid(5),      
    layer5_out_6_0              => mnist_model_out_data(6),
    layer5_out_6_ap_vld_0       => mnist_model_out_valid(6),      
    layer5_out_7_0              => mnist_model_out_data(7),
    layer5_out_7_ap_vld_0       => mnist_model_out_valid(7),      
    layer5_out_8_0              => mnist_model_out_data(8),
    layer5_out_8_ap_vld_0       => mnist_model_out_valid(8),      
    layer5_out_9_0              => mnist_model_out_data(9),
    layer5_out_9_ap_vld_0       => mnist_model_out_valid(9),
    ap_rst_n_0                  => '1'
    
);


--dma_controller_m_tready <= '1';

iaxi_dma_interface : entity work.axi_dma_interface
generic map (
  AXIL_REG_BASE_ADDRESS => x"A0030000", 
  NUM_OF_WORDS_WIDTH   => DMA_NUM_OF_WORDS_WIDTH
)
port map(
  clk_i                => pl_clk0_0,
  reset_i              => '0',

  data_m_tdata_o       => dma_controller_m_tdata,
  data_m_tvalid_o      => dma_controller_m_tvalid,
  data_m_tready_i      => dma_controller_m_tready,
  data_m_tlast_o       => dma_controller_m_tlast,
  data_s_tdata_i       => dma_controller_s_tdata,
  data_s_tvalid_i      => dma_controller_s_tvalid,
  data_s_tready_o      => dma_controller_s_tready,
  data_s_tlast_i       => dma_controller_s_tlast,

  dma_interface_master_i   => dma_interface_master,
  dma_interface_slave_o    => dma_interface_slave,
  axil_reg_master_i        => dma_axil_reg_master,
  axil_reg_slave_o         => dma_axil_reg_slave
);

iglobal_axi_reg : entity work.axi_registers
generic map (
  AXIL_BASE_ADDRESS   => x"A0020000",
  NUMBER_OF_REGISTERS => NUMBER_OF_AXIL_REGISTERS,
  WRITE_MASK          => (others =>'1')
)
port map(
  clk_i             => pl_clk0_0,
  reset_i           => '0',
  axil_master_i     => global_axil_reg_master,
  axil_slave_o      => global_axil_reg_slave,
  read_reg_i        => (others=>( others =>'0')),
  write_reg_o       => axil_write_regs
);
dma_controller_s_tdata <= std_logic_vector(counter(15 downto 0));
mnist_start<= axil_write_regs(0)(0);
process(pl_clk0_0)
begin
 if rising_edge(pl_clk0_0) then
    mnist_start_prev <= mnist_start;
    
    if mnist_start = '1' and mnist_start_prev = '0' then
      mnist_model_ap_start <='1';
    end if;
    if mnist_model_ap_start = '1' and mnist_model_ap_ready = '1' then 
      mnist_model_ap_start <= '0';
    end if;
    --if mnist_model_ap_start = '1' and mnist_model_ap_idle = '1' then 
    
    --end if;
    dma_controller_s_tvalid <= '1';
    if dma_controller_s_tready = '1' then
        counter <= counter + 1;
    end if; 
 end if;
end process;

end Behavioral;

