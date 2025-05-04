
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package axil_reg_dma_pkg is
  constant NUMBER_OF_REG   : natural :=16;

  constant WRITE_START_IDX        : natural := 0;
  constant WRITE_ADDRESS_L_IDX    : natural := 1;
  constant WRITE_ADDRESS_H_IDX    : natural := 2;
  constant WRITE_NUM_OF_WORDS_IDX : natural := 3;
  constant READ_START_IDX         : natural := 4;
  constant READ_ADDRESS_L_IDX     : natural := 5;
  constant READ_ADDRESS_H_IDX     : natural := 6;
  constant READ_NUM_OF_WORDS_IDX  : natural := 7;

  constant WRITE_MASK             : std_logic_vector(NUMBER_OF_REG - 1 downto 0) := (
    WRITE_START_IDX           => '1',
    WRITE_ADDRESS_L_IDX       => '1',
    WRITE_ADDRESS_H_IDX       => '1',
    WRITE_NUM_OF_WORDS_IDX    => '1',
    READ_START_IDX            => '1',
    READ_ADDRESS_L_IDX        => '1',
    READ_ADDRESS_H_IDX        => '1',
    READ_NUM_OF_WORDS_IDX     => '1',
    others                    => '0'
  );
  
end package;