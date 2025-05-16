
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package array_types is
    type array_unsigned_t is array (natural range <>) of unsigned;
    type array_signed_t is array (natural range <>) of signed;
    type array_slv_t is array (natural range <>) of std_logic_vector;

    function to_array_slv(unsigned_array : array_unsigned_t) return array_slv_t;
    function to_array_slv(signed_array : array_signed_t) return array_slv_t;
end package;



package body array_types is
    function to_array_slv(unsigned_array : array_unsigned_t) return array_slv_t is
      variable slv_array  : array_slv_t(unsigned_array'range)(unsigned_array(unsigned_array'left)'range);
    begin
        for i in unsigned_array'range loop
            slv_array(i) := std_logic_vector(unsigned_array(i));
        end loop;
        return slv_array;
    end;

    function to_array_slv(signed_array : array_signed_t) return array_slv_t is
      variable slv_array  : array_slv_t(signed_array'range)(signed_array'left'high downto 0);
    begin
        for i in signed_array'range loop
            slv_array(i) := std_logic_vector(signed_array(i));
        end loop;
        return slv_array;
    end;
  end package body;
  
  