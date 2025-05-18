library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package axi_fir_filter_pkg is
  constant WEIGHTS_FIXED_POINTS : natural := 15;
  constant NUMBER_OF_TAPS  : natural := 16;
  constant WEIGHTS_W       : natural := 18;
  constant NUMBER_OF_REG   : natural := NUMBER_OF_TAPS;
  constant FIR_WEIGHTS_START_IDX        : natural := 0;
  constant WRITE_MASK             : std_logic_vector(NUMBER_OF_REG - 1 downto 0) := (others => '1');

end package;