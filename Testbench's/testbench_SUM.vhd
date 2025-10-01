-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench_SUM is
-- empty
end testbench_SUM; 

architecture tb_SUM of testbench_SUM is


component SUM_8_BITS_PORTS is port(
	cout : out std_logic;
    S    : out std_logic_vector (7 downto 0);
    
    A 	 : in  std_logic_vector (7 downto 0);
    B 	 : in  std_logic_vector (7 downto 0);
	cin  : in  std_logic
);
end component;

signal A_in, B_in, S_out : std_logic_vector(7 downto 0);
signal cout, cin : std_logic;


begin

  -- Connect DUT
  DUT: SUM_8_BITS_PORTS port map(cout, S_out, A_in, B_in, cin);
	
  process
  begin
  	
    cin <= '0';
  	A_in <= "00010001";
    B_in <= "10000001";

	wait for 1 ns;
    
    
  	report std_logic_vector'image(S_out);
    report std_logic'image(cout);
    
    wait;
  end process;
end tb_SUM;

