-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbenchBW is
-- empty
end testbenchBW; 

architecture tbBW of testbenchBW is


component BIT_WISE_PORTS is port(
	output : out std_logic_vector (7 downto 0);
    
	A   : in std_logic_vector (7 downto 0);
    B   : in std_logic_vector (7 downto 0);
	sel : in std_logic_vector (1 downto 0)
    
);
end component;

signal A, B, output : std_logic_vector (7 downto 0);
signal sel : std_logic_vector (1 downto 0);

begin

  -- Connect DUT
  DUT: BIT_WISE_PORTS port map(output, A, B, sel);
	
  process
  begin
  	
  	A <= "10111001";
    B <= "01110011";
	
	sel <= "00";
	wait for 10 ns;
    report std_logic_vector'image(output);
   	wait for 1 ns;
    
  	sel <= "01";
	wait for 10 ns;
    report std_logic_vector'image(output);
   	wait for 1 ns;
    
    sel <= "10";
	wait for 10 ns;
    report std_logic_vector'image(output);
   	wait for 1 ns;
    
    sel <= "11";
	wait for 10 ns;
    report std_logic_vector'image(output);
   	wait for 1 ns;
    
    wait;
  end process;
end tbBW;

