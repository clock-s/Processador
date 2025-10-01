-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench_SUB is
-- empty
end testbench_SUB; 

architecture tb_SUB of testbench_SUB is


component SUBTRACTION_8_BITS_PORTS is port(
	S : out std_logic_vector (7 downto 0);
    
    A : in std_logic_vector (7 downto 0);
    B : in std_logic_vector (7 downto 0)

); 
end component;

signal A_in, B_in, S_out : std_logic_vector(7 downto 0);


begin

  -- Connect DUT
  DUT: SUBTRACTION_8_BITS_PORTS port map(S_out, A_in, B_in);
	
  process
  begin
  	
    A_in <= "10000001";
  	B_in <= "00010001";

	wait for 1 ns;
    
    
  	report std_logic_vector'image(S_out);
    
    wait;
  end process;
end tb_SUB;

