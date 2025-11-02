library ieee;
use ieee.std_logic_1164.all;
use work.functions.all;

--GRANDE MULTIPLEXADOR

entity PAR_L_SHIFT_PORTS is port (
	output: out std_logic_vector (7 downto 0);
    carry : out std_logic;
    
    input : in std_logic_vector (7 downto 0);
    num_shift : in std_logic_vector (7 downto 0)

);
end PAR_L_SHIFT_PORTS;


architecture PAR_L_SHIFT of PAR_L_SHIFT_PORTS is
begin


	output(0) <= input(0) when to_integer(num_shift) = 0 else '0';
                    
    output(1) <= input(1) when to_integer(num_shift) = 0 else
    			input(0) when to_integer(num_shift) = 1 else '0';
                
    output(2) <= input(2) when to_integer(num_shift) = 0 else
    			input(1) when to_integer(num_shift) = 1 else 
                input(0) when to_integer(num_shift) = 2 else '0';
                
    output(3) <= input(3) when to_integer(num_shift) = 0 else
    			input(2) when to_integer(num_shift) = 1 else 
                input(1) when to_integer(num_shift) = 2 else
                input(0) when to_integer(num_shift) = 3 else '0';
	
    output(4) <= input(4) when to_integer(num_shift) = 0 else
    			input(3) when to_integer(num_shift) = 1 else 
                input(2) when to_integer(num_shift) = 2 else
                input(1) when to_integer(num_shift) = 3 else
                input(0) when to_integer(num_shift) = 4 else '0';

	output(5) <= input(5) when to_integer(num_shift) = 0 else
    			input(4) when to_integer(num_shift) = 1 else 
                input(3) when to_integer(num_shift) = 2 else
                input(2) when to_integer(num_shift) = 3 else
                input(1) when to_integer(num_shift) = 4 else
                input(0) when to_integer(num_shift) = 5 else '0';

	output(6) <= input(6) when to_integer(num_shift) = 0 else
    			input(5) when to_integer(num_shift) = 1 else 
                input(4) when to_integer(num_shift) = 2 else
                input(3) when to_integer(num_shift) = 3 else
                input(2) when to_integer(num_shift) = 4 else
                input(1) when to_integer(num_shift) = 5 else
                input(0) when to_integer(num_shift) = 6 else '0';
               
	output(7) <= input(7) when to_integer(num_shift) = 0 else
    			input(6) when to_integer(num_shift) = 1 else 
                input(5) when to_integer(num_shift) = 2 else
                input(4) when to_integer(num_shift) = 3 else
                input(3) when to_integer(num_shift) = 4 else
                input(2) when to_integer(num_shift) = 5 else
                input(1) when to_integer(num_shift) = 6 else
                input(0) when to_integer(num_shift) = 7 else '0';   
                
    
    carry <=    input(7) when to_integer(num_shift) = 1 else
    			input(6) when to_integer(num_shift) = 2 else 
                input(5) when to_integer(num_shift) = 3 else
                input(4) when to_integer(num_shift) = 4 else
                input(3) when to_integer(num_shift) = 5 else
                input(2) when to_integer(num_shift) = 6 else
                input(1) when to_integer(num_shift) = 7 else
                input(0) when to_integer(num_shift) = 8 else '0';             
                
end PAR_L_SHIFT;










