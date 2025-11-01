library ieee;
use ieee.std_logic_1164.all;


entity ULA is port(
	output : out std_logic_vector (7 downto 0);
    finished : out std_logic;
    overflow : out std_logic;
    
    A : in std_logic_vector (7 downto 0);
    B : in std_logic_vector (7 downto 0);
    permission : in std_logic;
	instruction : in std_logic_vector (3 downto 0);
    clock : in std_logic   
);
end ULA;


architecture ULA_COMPORTAMENT of ULA is
	signal flags, inst_reg : std_logic_vector(3 downto 0);
	signal A_reg, B_reg : std_logic_vector(7 downto 0);
    signal out_sum, out_sub, out_mult, out_div, out_mod,
    out_comp, out_bitwise, out_lshift, out_rshift : std_logic_vector (7 downto 0);
    
    signal sum_carry, mult_carry, sub_carry, carry_lshift, carry_rshift : std_logic;
    
    
    
    signal reset : std_logic;
    signal bitwise_sel : std_logic_vector (1 downto 0);
    
    
    type state is (idle, load, sample, in_process, complete, save);
    
    
    
    component SUM_8_BITS_PORTS is port(
        cout : out std_logic;
        S    : out std_logic_vector (7 downto 0);

        A 	 : in  std_logic_vector (7 downto 0);
        B 	 : in  std_logic_vector (7 downto 0);
        cin  : in  std_logic
    );
    end component;
    
    component SUBTRACTION_8_BITS_PORTS is port(
        S : out std_logic_vector (7 downto 0);
        carry : out std_logic;

        A : in std_logic_vector (7 downto 0);
        B : in std_logic_vector (7 downto 0)

    );
    end component;
    
    component MULT_PORTS is port (
        output : out std_logic_vector (7 downto 0);
        carry : out std_logic;
        flag : out std_logic;

        input_A : in std_logic_vector (7 downto 0);
        input_B : in std_logic_vector (7 downto 0);
        clock : in std_logic;
        reset : in std_logic
    ); 
    end component;
    
    component MOD_DIV_PORTS is port(
        div_output : out std_logic_vector (7 downto 0);
        mod_output : out std_logic_vector (7 downto 0);
        flag 	   : out std_logic;

        input_A : in std_logic_vector (7 downto 0);
        input_B : in std_logic_vector (7 downto 0);
        clock   : in std_logic;
        reset   : in std_logic
    ); 
    end component;
    
    component COMPARE is port (
        flag : out std_logic_vector(3 downto 0);

        A : in std_logic_vector (7 downto 0);
        B : in std_logic_vector (7 downto 0)
    );
    end component;
    
    component BIT_WISE_PORTS is port(
        output : out std_logic_vector (7 downto 0);

        A   : in std_logic_vector (7 downto 0);
        B   : in std_logic_vector (7 downto 0);
        sel : in std_logic_vector (1 downto 0)

    ); 
    end component;
    
    component L_SHIFT_PORTS is port (
        output: out std_logic_vector (7 downto 0);
        carry : out std_logic;
        flag : out std_logic;


        input : in std_logic_vector (7 downto 0);
        num_shift : in std_logic_vector (7 downto 0);
        clock : in std_logic;
        reset : in std_logic
    );
    end component;
    
    component R_SHIFT_PORTS is port (
        output: out std_logic_vector (7 downto 0);
        carry : out std_logic;
        flag : out std_logic;


        input : in std_logic_vector (7 downto 0);
        num_shift : in std_logic_vector (7 downto 0);
        clock : in std_logic;
        reset : in std_logic
    );
    end component;



begin
	
    SUM  : SUM_8_BITS_PORTS port map(sum_carry, out_sum, A_reg, B_reg, '0');
    SUB  : SUBTRACTION_8_BITS_PORTS port map(out_sub, sub_carry, A_reg, B_reg);
    MULT : MULT_PORTS port map(out_mult, mult_carry, flags(3), A_reg, B_reg, clock, reset);
    DIV_MOD : MOD_DIV_PORTS port map(out_div, out_mod, flags(2), A_reg, B_reg, clock, reset);
    COMP : COMPARE port map (out_comp(3 downto 0), A_reg, B_reg);
    BIT_WISE : BIT_WISE_PORTS port map(out_bitwise, A_reg, B_reg, bitwise_sel);
    LSHIFT : L_SHIFT_PORTS port map(out_lshift, carry_lshift, flags(1), A_reg, B_reg, clock, reset);
    RSHIFT : R_SHIFT_PORTS port map(out_rshift, carry_rshift, flags(0), A_reg, B_reg, clock, reset);
	
    ULA_DECODER : process(clock)
    	variable ula_state : state := idle;
        variable temp_out : std_logic_vector (7 downto 0);
        variable temp_carry : std_logic;
        variable temp_flag : std_logic := '0';
    begin
    
    
    	if rising_edge(clock) then
            case ula_state is
                when idle =>
                    reset <= '1';
                    finished <= '0';
                    temp_out := "00000000";
                    temp_carry := '0';
                    ula_state := load;

                when load =>
                	if permission = '1' then ula_state := sample; end if;
                    A_reg <= A;
                    B_reg <= B;
                    inst_reg <= instruction;
                    
               	when sample =>
                	reset <= '0';
                    ula_state := in_process;
                    
                    case inst_reg is
                    	when "0111" | "1000" | "1001" | "1010" | "1011"  =>
                    		reset <= '0';
                        when others =>
                        	null;
                    end case;
                
                    
                when in_process =>
                	
                    case inst_reg is
                        when "0000" | "0001" | "0010" | "0011" | "0100" | "0101" | "0110" =>
                            ula_state := complete;

                        when "0111" => -- MULT
                            if flags(3) = '1' then
                                ula_state := complete;
                            end if;
                        when "1000" => -- DIV 
                            if flags(2) = '1' then
                                ula_state := complete;
                            end if;
                        when "1001" => -- MOD
                            if flags(2) = '1' then
                                ula_state := complete;
                            end if;
                            
                        when "1010" => -- LSHIFT
                            if flags(1) = '1' then
                                ula_state := complete;
                            end if;
                            
                        when "1011" => -- RSHIFT 
                            if flags(0) = '1' then
                                ula_state := complete;
                            end if;

                        when others =>
                            ula_state := complete;
                    
                    end case;
                
                
                	if temp_flag = '1' then
                    	ula_state := complete;
                    end if;
                    
                when complete =>
                    finished <= '1';
                    ula_state := save;

                when save =>
                    ula_state := idle;
                    finished <= '0';
                    reset <= '1';

            end case;



   			if ula_state = in_process or ula_state = complete then
                case instruction is
                    when "0000" => --SUM
                        temp_out := out_sum;
                        temp_carry := sum_carry;
                    
                    when "0001" => --SUB
                        temp_out := out_sub;
                        temp_carry := sub_carry;
                    
                    when "0010" => --COMP
                        temp_out := out_comp;
                        temp_carry := '0';
                    
                    when "0011" => --XOR
                        bitwise_sel <= instruction(1 downto 0);
                        temp_out := out_bitwise;
                        temp_carry := '0';
                    
                    when "0100" => --NOT
                        bitwise_sel <= instruction(1 downto 0);
                        temp_out := out_bitwise;
                        temp_carry := '0';
                    
                    when "0101" => --AND
                        bitwise_sel <= instruction(1 downto 0);
                        temp_out := out_bitwise;
                        temp_carry := '0';
                    
                    when "0110" => --OR
                        bitwise_sel <= instruction(1 downto 0);
                        temp_out := out_bitwise;
                        temp_carry := '0';
                    
                    when "0111" => --MULT
                        temp_out := out_mult;
                        temp_carry := mult_carry;
                    
                    when "1000" => --DIV
                    	temp_out := out_div;
                        temp_carry := '0';
                        
                    when "1001" => --MOD
                    	temp_out := out_mod;
                        temp_carry := '0';
                        
                    when "1010" => --LSHIFT
                    	temp_out := out_lshift;
                        temp_carry := '0';
                    
                    when "1011" => --rshift
                    	temp_out := out_rshift;
                        temp_carry := '0';
                    
                    when others =>
                        temp_out := (others => 'X');
                        temp_carry := 'X';
                end case;
            end if;
        
        
        end if;
        
        
        
        output <= temp_out;
        overflow <= temp_carry;
 
    	
    
    end process ULA_DECODER;
	



end ULA_COMPORTAMENT;

