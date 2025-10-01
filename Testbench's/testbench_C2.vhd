-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench_C2 is
-- empty
end testbench_C2; 

architecture tb_C2 of testbench_C2 is


component COMPLEMENT_2_8_BITS_PORTS is port(
	output : out std_logic_vector(7 downto 0);
    input  : in  std_logic_vector(7 downto 0)
);  
end component;

signal input, output : std_logic_vector(7 downto 0);

begin

  -- Connect DUT
  DUT: COMPLEMENT_2_8_BITS_PORTS port map(output, input);
	
  process
  begin
  	
  	input <= "11111111";
    

	wait for 1 ns;
    
    
  	report std_logic_vector'image(output);
   
  
    
    wait;
  end process;
end tb_C2;

