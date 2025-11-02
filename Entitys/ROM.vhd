library ieee;
use ieee.std_logic_1164.all;


entity ROM is port (
	data : out std_logic_vector (7 downto 0);
	addr : in integer range 0 to 255

); 
end ROM;




architecture ROM_OUT of ROM is
	
    component archive is port(
        data : out std_logic_vector (7 downto 0);
        addr : in integer range 0 to 255
    );
	end component;

    
begin

	
    
    ARCH_OUT : archive port map (data, addr);
	


end ROM_OUT;

