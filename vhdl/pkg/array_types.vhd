
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package array_types is
    type array_unsigned_t is array (natural range <>) of unsigned;
    type array_signed_t is array (natural range <>) of signed;
    type array_slv_t is array (natural range <>) of std_logic_vector;

    function to_array_slv(input_array : array_unsigned_t) return array_slv_t;
    function to_array_slv(input_array : array_signed_t) return array_slv_t;

    function to_array_unsigned(input_array : array_slv_t) return array_unsigned_t;
    function to_array_unsigned(input_array : array_signed_t) return array_unsigned_t;

    function to_array_signed(input_array : array_slv_t) return array_signed_t;
    function to_array_signed(input_array : array_unsigned_t) return array_signed_t;
end package;



package body array_types is

    function to_array_slv(input_array : array_unsigned_t) return array_slv_t is
      variable result_array  : array_slv_t(input_array'range)(input_array(input_array'left)'range);
    begin
        for i in input_array'range loop
            result_array(i) := std_logic_vector(input_array(i));
        end loop;
        return result_array;
    end;
    function to_array_slv(input_array : array_signed_t) return array_slv_t is
      variable result_array  : array_slv_t(input_array'range)(input_array(input_array'left)'range);
    begin
        for i in input_array'range loop
            result_array(i) := std_logic_vector(input_array(i));
        end loop;
        return result_array;
    end;

    
    function to_array_unsigned(input_array : array_slv_t) return array_unsigned_t is
      variable result_array  : array_unsigned_t(input_array'range)(input_array(input_array'left)'range);
      begin
        for i in input_array'range loop
            result_array(i) := unsigned(input_array(i));
        end loop;
        return result_array;
      end;
    function to_array_unsigned(input_array : array_signed_t) return array_unsigned_t is
      variable result_array  : array_unsigned_t(input_array'range)(input_array(input_array'left)'range);
    begin
        for i in input_array'range loop
            result_array(i) := unsigned(input_array(i));
        end loop;
        return result_array;
    end;
  

    function to_array_signed(input_array : array_slv_t) return array_signed_t is
        variable result_array  : array_signed_t(input_array'range)(input_array(input_array'left)'range);
        begin
          for i in input_array'range loop
              result_array(i) := signed(input_array(i));
          end loop;
          return result_array;
        end;
      function to_array_signed(input_array : array_unsigned_t) return array_signed_t is
        variable result_array  : array_signed_t(input_array'range)(input_array(input_array'left)'range);
      begin
          for i in input_array'range loop
              result_array(i) := signed(input_array(i));
          end loop;
          return result_array;
      end;
      
  end package body;
  
  