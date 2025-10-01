library IEEE;
use ieee.std_logic_1164.all;

entity SUM_PORTS is port(
	cout : out std_logic;
    S    : out std_logic;
    
    A 	 : in  std_logic;
    B 	 : in  std_logic;
	cin  : in  std_logic
);
end SUM_PORTS;

architecture BIT_SUM of SUM_PORTS is
begin
	
    S <= A xor ( B xor cin );
    
    cout <= ( A and ( B or cin ) ) or (B and cin);

end BIT_SUM;


--------------------------------------------------
--------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;

entity SUM_8_BITS_PORTS is port(
	cout : out std_logic;
    S    : out std_logic_vector (7 downto 0):= "00000000";

    A 	 : in  std_logic_vector (7 downto 0);
    B 	 : in  std_logic_vector (7 downto 0);
	cin  : in  std_logic
);
end SUM_8_BITS_PORTS;


architecture SUM_8_BIT of SUM_8_BITS_PORTS is

	component SUM_PORTS is port(
      cout : out std_logic;
      S    : out std_logic;

      A    : in  std_logic;
      B    : in  std_logic;
      cin  : in  std_logic
  	);
	end component;
    
    signal cout_aux : std_logic_vector(6 downto 0);
    
begin

	S0 : SUM_PORTS port map (cout_aux(0), S(0), A(0), B(0), cin);
    S1 : SUM_PORTS port map (cout_aux(1), S(1), A(1), B(1), cout_aux(0));
    S2 : SUM_PORTS port map (cout_aux(2), S(2), A(2), B(2), cout_aux(1));
    S3 : SUM_PORTS port map (cout_aux(3), S(3), A(3), B(3), cout_aux(2));
    
    S4 : SUM_PORTS port map (cout_aux(4), S(4), A(4), B(4), cout_aux(3));
    S5 : SUM_PORTS port map (cout_aux(5), S(5), A(5), B(5), cout_aux(4));
    S6 : SUM_PORTS port map (cout_aux(6), S(6), A(6), B(6), cout_aux(5));
    S7 : SUM_PORTS port map (cout, S(7), A(7), B(7), cout_aux(6));
    

end SUM_8_BIT;















