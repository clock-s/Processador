library ieee;
use ieee.std_logic_1164.all;
use work.functions.all;

-- A / B   |    A % B
entity MOD_DIV_PORTS is port(
	div_output : out std_logic_vector (7 downto 0);
    mod_output : out std_logic_vector (7 downto 0);
    flag 	   : out std_logic;
    
    input_A : in std_logic_vector (7 downto 0);
    input_B : in std_logic_vector (7 downto 0);
    clock   : in std_logic;
    reset   : in std_logic
); 
end MOD_DIV_PORTS;




architecture MOD_DIV of MOD_DIV_PORTS is
	signal flag_box : std_logic_vector (1 downto 0);
    signal A, B, R, Q : std_logic_vector (7 downto 0);
    signal N_A, N_B, N_R, N_Q : std_logic_vector (7 downto 0);
    signal R_aux : std_logic_vector (7 downto 0);
    signal signal_bit : std_logic;
    
    
    
    
    
    component COMPLEMENT_2_8_BITS_PORTS is port(
        output : out std_logic_vector(7 downto 0);
        input  : in  std_logic_vector(7 downto 0)
    );  
    end component;
    
	
    component SUBTRACTION_8_BITS_PORTS is port(
        S : out std_logic_vector (7 downto 0);
        carry : out std_logic;

        A : in std_logic_vector (7 downto 0);
        B : in std_logic_vector (7 downto 0)

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
    C2_R : COMPLEMENT_2_8_BITS_PORTS port map (N_R, R);
    C2_Q : COMPLEMENT_2_8_BITS_PORTS port map (N_Q, Q);
    
    SUBTRACTOR : SUBTRACTION_8_BITS_PORTS port map(R_aux, signal_bit, R(6 downto 0) & A(7), B);
    
    

	flag <= flag_box(1);
    
    div_output <= Q when (input_A(7) xor input_B(7)) = '0' else N_Q;
    mod_output <= R when (input_A(7) xor input_B(7)) = '0' else N_R;
    
    process(clock, reset)
       variable i : integer range 0 to 7;
       variable R_temp : std_logic_vector(7 downto 0);
    begin
    
    	if reset = '1' then
        	flag_box <= "00";
            i := 7;
        
        elsif rising_edge(clock) then
        	
            if flag_box(0) = '0' then
                flag_box(0) <= '1';
                i := 7;
                R <= "00000000";
                if input_A(7) = '0' then A <= input_A; else A <= N_A; end if;
                if input_B(7) = '0' then B <= input_B; else B <= N_B; end if;
                
            elsif flag_box(0) = '1' and flag_box(1) = '0' then
           		
                if i = 0 then
                	flag_box(1) <= '1';
                end if;
            	
              	if signal_bit = '1' then
                	R_temp := R_aux;
                else
                	R_temp := R(6 downto 0) & A(7);
                end if;
               
                Q(i) <= signal_bit;
                R <= R_temp;
                A <= A(6 downto 0) & '0';
    			if i /= 0 then  i := i - 1; end if;
                
            end if;
            
        end if;
   
    end process;


end MOD_DIV;
