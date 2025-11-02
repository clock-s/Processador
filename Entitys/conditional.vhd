library ieee;
use ieee.std_logic_1164.all;


entity CONDITIONAL is port (
	flag : out std_logic;
    
	A : in std_logic_vector (7 downto 0);
    B : in std_logic_vector (7 downto 0)
);
end CONDITIONAL;



architecture CONDITIONAL_COMPORTAMENT of CONDITIONAL is

begin
	
	flag <= (A(7) and B(7)) or (A(6) and B(6)) or (A(5) and B(5)) or (A(4) and B(4)) or (A(3) and B(3)) or (A(2) and B(2)) or (A(1) and B(1)) or (A(0) and B(0));

end CONDITIONAL_COMPORTAMENT;
