library IEEE;
use ieee.std_logic_1164.all;



entity U_REGISTER_PORT is port(
	clock      : in std_logic;
    reset 	   : in std_logic;
    write_enable : in std_logic; 
    read_enable : in std_logic;
    
	gate : inout std_logic_vector (7 downto 0);
    
    --debug : out std_logic_vector(7 downto 0); --Coloque para receber o valor da box
);
end U_REGISTER_PORT;



architecture U_REGISTER of U_REGISTER_PORT is
	signal box : std_logic_vector (7 downto 0) := "00000000";

begin

	gate <= box when read_enable = '1' else "ZZZZZZZZ";
    --debug <= box;
    
    process(clock, reset)
    begin
    	if reset = '1' then
        	box <= "00000000";
        end if;
    
    	if rising_edge(clock) then
        	if write_enable = '1' then
            	box <= gate;
        	end if;
        end if;
        
    end process;

end U_REGISTER;
