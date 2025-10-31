library ieee;
use ieee.std_logic_1164.all;


entity COMPARE is port (
	flag : out std_logic_vector(3 downto 0);
    
	A : in std_logic_vector (7 downto 0);
    B : in std_logic_vector (7 downto 0)
);
end COMPARE;



architecture COMPARE_COMPORTAMENT of COMPARE is
	signal c, k, n, o : std_logic;
    signal r : std_logic_vector (7 downto 0);
    
    component SUBTRACTION_8_BITS_PORTS is port(
        S : out std_logic_vector (7 downto 0);
        carry : out std_logic;

        A : in std_logic_vector (7 downto 0);
        B : in std_logic_vector (7 downto 0)

    ); 
    end component;

begin
	
    COMP : SUBTRACTION_8_BITS_PORTS port map (r, c, A, B);
     
    o <= not(r(7) or r(6) or r(5) or r(4) or r(3) or r(2) or r(1) or r(0));
    n <= A(7);
    k <= (n xor c) and not o;
    
    
    flag(0) <= o;
    flag(1) <= n;
    flag(2) <= c and not o;
    flag(3) <= k; 

end COMPARE_COMPORTAMENT;
