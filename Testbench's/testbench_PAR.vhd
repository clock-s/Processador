-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbenchPAR is
-- empty
end testbenchPAR; 

architecture tbPAR of testbenchPAR is


component PARITY is port(
	flag : out std_logic;
    
    A : in std_logic_vector(7 downto 0);
); 
end component;

signal input : std_logic_vector (7 downto 0);
signal output : std_logic;

begin

  -- Connect DUT
  DUT: PARITY port map(output, input);
	
  process
  begin
  	
  	input <= "00010110";

	wait for 1 ns;
    
   
  	report std_logic'image(output);    
    
    wait;
  end process;
end tbPAR;

