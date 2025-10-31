-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench_COMP is
-- empty
end testbench_COMP; 

architecture tb_COMP of testbench_COMP is


component COMPARE is port (
	flag : out std_logic_vector(3 downto 0);
    
	A : in std_logic_vector (7 downto 0);
    B : in std_logic_vector (7 downto 0)
);
end component;

signal A_in, B_in, s: std_logic_vector(7 downto 0);
signal flag : std_logic_vector (3 downto 0);

begin

  -- Connect DUT
  DUT: COMPARE port map(flag, s,A_in, B_in);
	
  process
  begin
  	
    A_in <= "10000001";
  	B_in <= "00010001";

	wait for 1 ns;
    
    
  	report std_logic_vector'image(flag);
    report std_logic_vector'image(s);
    
    wait;
  end process;
end tb_COMP;

