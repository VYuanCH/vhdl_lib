library ieee;
use ieee.std_logic_1164.all;
use work.array_types.all;
use work.basic_pkg.all;
use IEEE.NUMERIC_STD.ALL;

entity fir_filter is
  generic (
    NUMBER_OF_TAPS    : natural := 8;
    DATA_W            : natural := 16;
    WEIGHTS_FIXED_POINTS : natural := 15     
  );
  port (
    clk_i             : in std_logic;
    reset_i           : in std_logic;
    weights_i         : in array_signed_t(0 to NUMBER_OF_TAPS - 1)(17 downto 0);
    src_data_r_i      : in signed(DATA_W - 1 downto 0);
    src_data_i_i      : in signed(DATA_W - 1 downto 0);
    src_data_valid_i  : in std_logic:= '1';
    dst_data_r_o      : out signed(DATA_W - 1 downto 0);
    dst_data_i_o      : out signed(DATA_W - 1 downto 0);
    dst_data_valid_i  : out std_logic
  );
end entity;

architecture Behavioral of fir_filter is

constant A_W            : natural := 30;
constant B_W            : natural := 18;
constant C_W            : natural := 48;
constant P_W            : natural := 48;
signal mult_out_imag          : array_signed_t(0 to NUMBER_OF_TAPS)(P_W - 1 downto 0);
signal mult_out_real          : array_signed_t(0 to NUMBER_OF_TAPS)(P_W - 1 downto 0);
signal mult_out_imag_truncate : signed(P_W - 1 downto 0);
signal mult_out_real_truncate : signed(P_W - 1 downto 0);
signal fir_out_pre_trunc_r    : signed(P_W - 1 downto 0);
signal fir_out_pre_trunc_i    : signed(P_W - 1 downto 0);
signal mult_out_real_valid    : std_logic_vector(0 to NUMBER_OF_TAPS - 1);
signal mult_out_imag_valid    : std_logic_vector(0 to NUMBER_OF_TAPS - 1);

begin

  mult_out_real(0) <= (others =>'0');
  mult_out_imag(0) <= (others =>'0');

  g_real: for i in 0 to NUMBER_OF_TAPS - 1 generate
    i_taps_r : entity work.dsp_multiply_and_add
    generic map (
      USE_CASCADE_PORTS            => false
    )
    port map(
      clk_i           => clk_i,
      reset_i         => reset_i,
      valid_i         => src_data_valid_i,
      a_i             => std_logic_vector(resize(src_data_r_i,A_W)),
      b_i             => std_logic_vector(resize(weights_i(i),B_W)),
      c_i             => std_logic_vector(mult_out_real(i)),
      signed(p_o)     => mult_out_real(i+1),
      valid_o         => mult_out_real_valid(i) 
    );
  end generate;

  g_imag: for i in 0 to NUMBER_OF_TAPS - 1 generate
    i_taps_i : entity work.dsp_multiply_and_add
    generic map (
      USE_CASCADE_PORTS            => false
    )
    port map(
      clk_i           => clk_i,
      reset_i         => reset_i,
      valid_i         => src_data_valid_i,
      a_i             => std_logic_vector(resize(src_data_i_i,A_W)),
      b_i             => std_logic_vector(resize(weights_i(i),B_W)),
      c_i             => std_logic_vector(mult_out_imag(i)),
      signed(p_o)     => mult_out_imag(i+1),
      valid_o         => mult_out_imag_valid(i) 
    );
  end generate;
  
  fir_out_pre_trunc_r <= mult_out_real(NUMBER_OF_TAPS)+2**(WEIGHTS_FIXED_POINTS - 1);
  fir_out_pre_trunc_i <= mult_out_imag(NUMBER_OF_TAPS)+2**(WEIGHTS_FIXED_POINTS - 1);
  
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      mult_out_real_truncate <= resize(fir_out_pre_trunc_r(P_W - 1 downto WEIGHTS_FIXED_POINTS),P_W);
      mult_out_imag_truncate <= resize(fir_out_pre_trunc_i(P_W - 1 downto WEIGHTS_FIXED_POINTS),P_W);
      dst_data_valid_i <= mult_out_real_valid(NUMBER_OF_TAPS - 1);
    end if;
  
  end process;
  dst_data_r_o <= mult_out_real_truncate(DATA_W - 1 downto 0);
  dst_data_i_o <= mult_out_imag_truncate(DATA_W - 1 downto 0);
  
end Behavioral;