library IEEE;
use ieee.std_logic_1164.all;


entity CLOCK_PORTS is port(
	clk : out std_logic
);
end CLOCK_PORTS;



architecture CLOCK of CLOCK_ports is
	
    constant clk_period : time := 10 ns;
	
begin

clk_process : process
    begin
        
      clk <= '0';
   	 wait for clk_period/2;
   	 clk <= '1';
  	wait for clk_period/2;
        
    end process;

end CLOCK;
