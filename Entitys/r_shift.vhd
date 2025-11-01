library ieee;
use ieee.std_logic_1164.all;
use work.functions.all;




entity R_SHIFT_PORTS is port (
	output: out std_logic_vector (7 downto 0);
    carry : out std_logic;
    flag : out std_logic;
    
    
    input : in std_logic_vector (7 downto 0);
    num_shift : in std_logic_vector (7 downto 0);
    clock : in std_logic;
	reset : in std_logic
);
end R_SHIFT_PORTS;




architecture R_SHIFT of R_SHIFT_PORTS is
	signal temp_out : std_logic_vector (7 downto 0);
    signal temp_carry : std_logic;
	signal flag_box : std_logic_vector (1 downto 0) := "00";
	signal contador : integer range 0 to 8;
begin
    
    output <= temp_out when flag_box(1) = '1' else "ZZZZZZZZ";
    carry <= temp_carry when flag_box(1) = '1' else 'Z';
    --output <= temp_out;
    
   	process(clock, reset)
    begin
        
        if reset = '1' then
        	flag_box <= "00";
        	contador <= 0; -- Precaução
        elsif rising_edge(clock) then
        
        	if flag_box(0) = '0' then
            	temp_out <= input;
                contador <= 0;
            	flag_box(0) <= '1';
            end if;
            
            
            if flag_box(0) = '1' and flag_box(1) = '0' then
            
            	
                if contador >= to_integer(num_shift) or contador = 8 then
            		flag_box(1) <= '1';
            	
                else
            	
                  temp_out <= '0' & temp_out(7 downto 1);

                  temp_carry <= temp_out(0);

                  if contador /= 8 then  contador <= contador + 1; end if;
            
            	end if;
            
            end if;
            
            
        
       end if;
       
       
       
    end process;



end R_SHIFT;
