library IEEE;
use ieee.std_logic_1164.all;


-- S = A - B
entity SUBTRACTION_8_BITS_PORTS is port(
	S : out std_logic_vector (7 downto 0);
    carry : out std_logic;
    
    A : in std_logic_vector (7 downto 0);
    B : in std_logic_vector (7 downto 0)

); 
end SUBTRACTION_8_BITS_PORTS;


architecture SUBTRACTION_8_BITS of SUBTRACTION_8_BITS_PORTS is
	
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
    
    signal B_inverted : std_logic_vector (7 downto 0);
    
	signal cin  : std_logic := '1';
begin

	U1 : INVERTER_8_BITS_PORTS port map(B_inverted, B);
    
    U2 : SUM_8_BITS_PORTS port map(carry, S, A, B_inverted, cin);

end SUBTRACTION_8_BITS;

