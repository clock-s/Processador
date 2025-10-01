library IEEE;
use ieee.std_logic_1164.all;



entity INVERTER_8_BITS_PORTS is port(
	output : out std_logic_vector(7 downto 0);
    input  : in  std_logic_vector(7 downto 0)
); 
end INVERTER_8_BITS_PORTS;



architecture INVERTER_8_BITS of INVERTER_8_BITS_PORTS IS
begin
	output(0) <= not input(0);
    output(1) <= not input(1);
    output(2) <= not input(2);
    output(3) <= not input(3);
    
    output(4) <= not input(4);
    output(5) <= not input(5);
	output(6) <= not input(6);
    output(7) <= not input(7);
end INVERTER_8_BITS;


--------------------------------------------------


library IEEE;
use ieee.std_logic_1164.all;

-- output = not input + 1
entity COMPLEMENT_2_8_BITS_PORTS is port(
	output : out std_logic_vector(7 downto 0);
    input  : in  std_logic_vector(7 downto 0)
);  
end COMPLEMENT_2_8_BITS_PORTS;




architecture COMPLEMENT_2_8_BITS of COMPLEMENT_2_8_BITS_PORTS is
	
    component INVERTER_8_BITS_PORTS is port(
		output : out std_logic_vector(7 downto 0);
    	input  : in  std_logic_vector(7 downto 0)
	); 
	end component;
    
    component SUM_8_BITS_PORTS is port(
      cout : out std_logic;
      S    : out std_logic_vector (7 downto 0):= "00000000";

      A    : in  std_logic_vector (7 downto 0);
      B    : in  std_logic_vector (7 downto 0);
      cin  : in  std_logic
    );
    end component;

	signal inverted : std_logic_vector (7 downto 0);
    signal one      : std_logic_vector (7 downto 0) := "00000001";
    
    signal cout : std_logic;
    signal cin  : std_logic := '0';

begin
	
    --Inverte
	U1 : INVERTER_8_BITS_PORTS port map(inverted, input);
    
    --Soma 1
    U2 : SUM_8_BITS_PORTS port map(cout, output, inverted, one, cin);
	

end COMPLEMENT_2_8_BITS;



