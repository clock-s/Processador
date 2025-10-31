library ieee;
use ieee.std_logic_1164.all;


entity C_UNIT is
end C_UNIT;



architecture C_UNIT_ARCH of C_UNIT is
	signal clock : std_logic;
	signal PC : integer range 0 to 255 := 0;
    signal instruction : std_logic_vector (7 downto 0);
    
    signal ULA_OUTPUT, A, B : std_logic_vector (7 downto 0);
    signal permission, finished, overflow : std_logic;
	
    type state is {idl, in_intruction, r_1, val_1, r_2, val_2, in_process, complete};
    
    component CLOCK_PORTS is port(
        clk : out std_logic
    );
    end component;
    
    component ROM is port (
        data : out std_logic_vector (7 downto 0);
        addr : in integer range 0 to 255 := 0;

    ); 
    end component;
    
    component ULA is port(
        output : out std_logic_vector (7 downto 0);
        finished : out std_logic;
        overflow : out std_logic;

        A : in std_logic_vector (7 downto 0);
        B : in std_logic_vector (7 downto 0);
        permission : in std_logic;
        instruction : in std_logic_vector (3 downto 0);
        clock : in std_logic   
    );
    
end CLOCK_PORTS;
    
begin

	clock_process : CLOCK_PORTS port map (clock);
    
    
    INTERNAL_MEMORY : ROM port map (instruction, PC);

	
    CONTROL_UNIT : process(clock)
    	variable PC_reg : integer range 0 to 255 := 0;
    	variable instruction_reg : std_logic_vector (7 downto 0);
        variable c_tate : state := idl;
        
    begin
    	
        
    	if rising_edge(clock) then
        	
            case c_state is
            
            	when idle =>
                	instruction_reg <= instruction;
                    PC_reg <= PC;
                
                when in_instruction =>
                	
            	
                when r_1 =>
                
                when val_1 => 
                
                when r_2 =>
                
                when val_2 =>
                
                when in_process =>
                
                when complete =>
                
                
            
            
            end case;
        
        
        end if;
    
    
    
    end process CONTROL_UNIT;
    
    
    
    
    
	


end C_UNIT_ARCH;
