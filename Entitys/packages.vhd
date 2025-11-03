library IEEE;
use ieee.std_logic_1164.all;


package functions is
	function to_integer(signal vector : std_logic_vector) return integer;
end functions;



package body functions is
	
    function to_integer(signal vector : std_logic_vector) return integer is
    	variable result : integer range 0 to 2**vector'length-1;
        
    begin
    	if(vector(vector'high) = '1') then result := 1;
      	else result := 0;
        end if;
        
        for i in (vector'high-1) downto (vector'low) loop
        	result := result * 2;
            
            if(vector(i) = '1') then
            	result := result + 1;
            
            end if;
        end loop;
        
        return result;
    
    end to_integer;


end functions;



----------------------------------------
library IEEE;
use ieee.std_logic_1164.all;

package PACK_ARRAY is
	type register_array is array ( natural range<> ) of std_logic_vector (7 downto 0);
end PACK_ARRAY;
