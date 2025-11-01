library ieee;
use ieee.std_logic_1164.all;


entity PARITY is port(
	flag : out std_logic;
    
    A : in std_logic_vector(7 downto 0)
); 
end PARITY;



architecture PARITY_COMPORTAMENT of PARITY is
begin
	
    flag <= A(7) xor (A(6) xor (A(5) xor (A(4) xor (A(3) xor (A(2) xor (A(1) xor A(0)))))));

end PARITY_COMPORTAMENT;
