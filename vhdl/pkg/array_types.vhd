
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package array_types is
    type array_unsigned_t is array (natural range <>) of unsigned;
    type array_signed_t is array (natural range <>) of signed;
    type array_slv_t is array (natural range <>) of std_logic_vector;
end package;