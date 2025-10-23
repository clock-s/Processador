library ieee;
use ieee.std_logic_1164.all;



entity BIT_WISE_PORTS is port(
	output : out std_logic_vector (7 downto 0);
    
	A   : in std_logic_vector (7 downto 0);
    B   : in std_logic_vector (7 downto 0);
	sel : in std_logic_vector (1 downto 0)
    
); end BIT_WISE_PORTS;


architecture BIT_WISE of BIT_WISE_PORTS is
begin

	output <=  	not A when sel = "00" else
    			A and B when sel = "01" else
                A or B when sel = "10" else
                A xor B when sel = "11" else "ZZZZZZZZ";


end BIT_WISE;
