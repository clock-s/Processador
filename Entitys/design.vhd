library IEEE;
use ieee.std_logic_1164.all;




entity ALU_PORTS is port(
	output : out std_logic_vector (16 downto 0);
    A	   : in  std_logic_vector(8 downto 0);
    B 	   : in  std_logic_vector(8 downto 0);
    sel    : in  std_logic_vector(8 downto 0)
);
end ALU;


architecture ALU of ALU_PORTS is
begin

	



end ALU;




