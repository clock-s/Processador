library ieee;
use ieee.std_logic_1164.all;


entity MULT_PORTS is port (
	output : out std_logic_vector (7 downto 0);
    carry : out std_logic;
    flag : out std_logic;
    
	input_A : in std_logic_vector (7 downto 0);
    input_B : in std_logic_vector (7 downto 0);
    clock : in std_logic;
    reset : in std_logic
); 
end MULT_PORTS;


architecture MULT of MULT_PORTS is
	signal flag_box : std_logic_vector (1 downto 0);
    signal A, B, C, aux : std_logic_vector (7 downto 0);
	signal N_A, N_B, N_C : std_logic_vector (7 downto 0);
    signal i : integer range 0 to 7;
    signal carry_sum, carry_sum_temp : std_logic;
    
  
    
    component COMPLEMENT_2_8_BITS_PORTS is port(
        output : out std_logic_vector(7 downto 0);
        input  : in  std_logic_vector(7 downto 0)
    );  
    end component;
    
    component SUM_8_BITS_PORTS is port(
        cout : out std_logic;
        S    : out std_logic_vector (7 downto 0);

        A 	 : in  std_logic_vector (7 downto 0);
        B 	 : in  std_logic_vector (7 downto 0);
        cin  : in  std_logic
    );
    end component;

    
begin

	C2_A : COMPLEMENT_2_8_BITS_PORTS port map (N_A, input_A);
    C2_B : COMPLEMENT_2_8_BITS_PORTS port map (N_B, input_B);
    C2_C : COMPLEMENT_2_8_BITS_PORTS port map (N_C, C);
    SUMMATION : SUM_8_BITS_PORTS port map(carry_sum_temp, aux, A, C, '0');

    flag <= flag_box(1);
    carry <= carry_sum;
    
    
    output <= C when (input_A(7) xor input_B(7)) = '0' else N_C;
    
    
    process(clock, reset)
    begin
    	if reset = '1' then
        	flag_box <= "00";
           	carry_sum <= '0';
        	i <= 0;
        elsif rising_edge(clock) then
        
        	if flag_box(0) = '0' then
                flag_box(0) <= '1';
				i <= 0; -- Precaução
                if input_A(7) = '0' then A <= input_A; else A <= N_A; end if;
                if input_B(7) = '0' then B <= input_B; else B <= N_B; end if;
              	
            	C <= "00000000";
            end if;
        	
            if i >= 7 then
            	flag_box(1) <= '1';
            
            else
            	if flag_box(1) = '0' and flag_box(0) = '1' then
                    if B(i) = '1' then C <= aux; end if;
                    
                    A <= A(6 downto 0) & '0';
                	
                	if carry_sum = '1' or carry_sum_temp = '1' then
                    	carry_sum <= '1';
                    end if;
                    
                    i <= i + 1;
                end if;
                
                
                
            end if;
        
        
        end if;
    
    
    
    end process;
    
    


end MULT;
