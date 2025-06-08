library ieee;
use ieee.std_logic_1164.all;
use work.array_types.all;
use work.basic_pkg.all;
use IEEE.NUMERIC_STD.ALL;
use work.axil_interface_pkg.all;
use work.axi_fir_filter_pkg.all;

entity fir_filter_axil is
  generic (
    
    AXIL_REG_BASE_ADDRESS : UNSIGNED(AXIL_ADDR_W - 1 downto 0);
    DATA_W            : natural := 16   

  );
  port (
    
    clk_i             : in std_logic;
    reset_i           : in std_logic;

    src_data_r_i      : in signed(DATA_W - 1 downto 0);
    src_data_i_i      : in signed(DATA_W - 1 downto 0);
    src_data_valid_i  : in std_logic:= '1';
    dst_data_r_o      : out signed(DATA_W - 1 downto 0);
    dst_data_i_o      : out signed(DATA_W - 1 downto 0);
    dst_data_valid_i  : out std_logic;

    axil_reg_master_i        : in axil_master_t;
    axil_reg_slave_o         : out axil_slave_t
  );
end entity;

architecture Behavioral of fir_filter_axil is
  
  signal axil_write_regs  : array_slv_t(0 to NUMBER_OF_REG - 1)(AXIL_DATA_W - 1 downto 0);
  signal fir_weights : array_signed_t(0 to NUMBER_OF_TAPS - 1)(17 downto 0);

begin

  iaxi_reg : entity work.axi_registers
  generic map (
    AXIL_BASE_ADDRESS   => AXIL_REG_BASE_ADDRESS,
    NUMBER_OF_REGISTERS => NUMBER_OF_REG,
    WRITE_MASK          => WRITE_MASK
  )
  port map(
    clk_i             => clk_i,
    reset_i           => reset_i,
    axil_master_i     => axil_reg_master_i,
    axil_slave_o      => axil_reg_slave_o,
    read_reg_i        => (others=>( others =>'0')),
    write_reg_o       => axil_write_regs
  );
  
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      for i in 0 to NUMBER_OF_TAPS - 1 loop
        fir_weights(i) <= signed(axil_write_regs(FIR_WEIGHTS_START_IDX + i)(WEIGHTS_W - 1 downto 0));
      end loop;
    end if;
  end process;

  i_fir_filter : entity work.fir_filter
  generic map (
    NUMBER_OF_TAPS         => NUMBER_OF_TAPS,         
    DATA_W                 => DATA_W, 
    WEIGHTS_W              => WEIGHTS_W,
    WEIGHTS_FIXED_POINTS   => WEIGHTS_FIXED_POINTS               
  )
  port map(
    clk_i             => clk_i,
    reset_i           => reset_i,
    weights_i         => fir_weights,
    src_data_r_i      => src_data_r_i,  
    src_data_i_i      => src_data_i_i, 
    src_data_valid_i  => src_data_valid_i, 
    dst_data_r_o      => dst_data_r_o,  
    dst_data_i_o      => dst_data_i_o, 
    dst_data_valid_i  => dst_data_valid_i
        
  );


end Behavioral;