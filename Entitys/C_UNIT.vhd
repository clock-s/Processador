library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity C_UNIT is
end C_UNIT;



architecture C_UNIT_ARCH of C_UNIT is
	signal clock : std_logic;
	signal PC : integer range 0 to 255 := 0;
    signal instruction : std_logic_vector (7 downto 0);
    signal RAM_memory : std_logic_vector (7 downto 0);
    signal MA : integer range 0 to 255;
    signal RAM_write : std_logic;
    
    signal ULA_OUTPUT, ULA_A, ULA_B : std_logic_vector (7 downto 0);
    signal ULA_permission, ULA_finished, overflow : std_logic;
    signal ULA_instruction : std_logic_vector (3 downto 0);
    
    signal conditional_flag : std_logic;
    signal flags, compare_statement : std_logic_vector (7 downto 0);
    
    
   	signal math_registers, memory_registers : std_logic_vector (7 downto 0);
    signal math_write, memory_write, reset: std_logic;
    signal math_addr, memory_addr : std_logic_vector (1 downto 0);
    
	
    type state is (idl, in_instruction, get_1, get_2, perm, load_save, in_process, complete);
    type inst is (none, load, sum, mult, and_i, or_i, xor_i, not_i, sub, comp, div, mod_i, lshift, rshift, nop, res, resf, jump, par);
    
   
    
    component CLOCK_PORTS is port(
        clk : out std_logic
    );
    end component;
    
    component ROM is port (
        data : out std_logic_vector (7 downto 0);
        addr : in integer range 0 to 255 := 0

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
    end component;
    
    
    component PACK_REGISTERS_PORTS is port(
        clock      : in std_logic;
        reset 	   : in std_logic;
        write_read : in std_logic; -- 0 to read and 1 to write

        addr  : in std_logic_vector (1 downto 0) := "00";

        data : inout std_logic_vector (7 downto 0)

        --debug : out register_array(3 downto 0);

    );
    end component;
    
    component CONDITIONAL is port (
        flag : out std_logic;

        A : in std_logic_vector (7 downto 0);
        B : in std_logic_vector (7 downto 0)
    );
    end component;
begin

	CLOCK_PROCESS : CLOCK_PORTS port map (clock);
    
    COND : CONDITIONAL port map (conditional_flag, flags, compare_statement);
    
    
    INTERNAL_MEMORY : ROM port map (instruction, PC);
    MATH_REGISTER_PACK : PACK_REGISTERS_PORTS port map (clock, reset, math_write, math_addr, math_registers);
	MEMORY_REGISTERS_PACK : PACK_REGISTERS_PORTS port map (clock, reset, memory_write, memory_addr, memory_registers);
    
    
    ULA_COMPONENT : ULA port map (ULA_output, ULA_finished, overflow, ULA_A, ULA_B, ULA_permission, ULA_instruction, clock);
    
	
    CONTROL_UNIT : process(clock)
    	variable instruction_reg : std_logic_vector (7 downto 0);
        variable A, B : std_logic_vector ( 7 downto 0);
        variable addr_1, addr_2 : std_logic_vector (1 downto 0);
        
        variable instruction_state : inst := none;
        variable c_state : state := idl;
        
        
        variable extern_A, extern_B, extern_ram : std_logic;
        variable math, memory : std_logic_vector (1 downto 0);
        
       	variable ULA_output_reg, acummulator : std_logic_vector (7 downto 0);
        
    begin
    	
        
    	if rising_edge(clock) then
        	
            case c_state is
            
            	when idl =>
                	report "=== Iniciando ciclo ===";
                    
                	instruction_reg := instruction;
                    math := "00";
                    memory := "00";
                    ULA_permission <= '0';
                    math_write <= '0';
                    memory_write <= '0';
                    RAM_write <= '0';
                    extern_A := '0';
                    extern_B := '0';
                    extern_ram := '0';
                    instruction_state := none;
                    reset <= '0';
                    
                	c_state := in_instruction;
                    
                when in_instruction =>
                	--report "== Capturando instrucao ==";
                    
                    if  instruction_reg = x"5D" or
                    	instruction_reg = x"5E" or
                        instruction_reg = x"5F" or
                        instruction_reg = x"69" or
                        instruction_reg = x"79" or
                        instruction_reg = x"8E" or
                        instruction_reg = x"94" or
                        instruction_reg = x"98" or
                        instruction_reg = x"99" or
                        instruction_reg = x"9C" or
                        instruction_reg = x"9D" or
                        instruction_reg = x"9E" or
                        instruction_reg = x"A4" or
                        instruction_reg = x"A8" or
                        instruction_reg = x"A9" or
                        instruction_reg = x"AC" or
                        instruction_reg = x"AD" or
                        instruction_reg = x"AE" or
                        instruction_reg = x"CD" or
                        instruction_reg = x"CE" then
                        
                        	instruction_state := rshift;
                        	
                        
                        else
                        
                        	case instruction_reg(7 downto 4) is
                            	
                                when x"0" => 
                                	case instruction_reg (3 downto 0) is
                                    	when x"0" => instruction_state := nop;
                                        when x"1" => instruction_state := res;
                                        when x"2" => instruction_state := resf;
                                        when others => null;
                                    end case;
                                	
                                when x"1" | x"2" | x"3" | x"4" => instruction_state := load;
                                when x"5" =>
                                	case instruction_reg (3 downto 0) is
                                    	when x"8" | x"9" | x"A" | x"B" => instruction_state := par;
                                        when x"0" | x"1" | x"2" | x"3" => instruction_state := load;
                                        when x"4" | x"5" => instruction_state := jump;
                                        when others => null;
                                    end case;
                                when x"6" => instruction_state := sum;
                                when x"7" => instruction_state := mult;
                                when x"8" => 
                                	case instruction_reg (3 downto 0) is
                                    	when x"4" | x"8" | x"9" | x"C" | x"D" => instruction_state := not_i;
                                        when others => instruction_state := and_i;
                                    end case;
                                when x"9" => instruction_state := or_i;
                                when x"A" => instruction_state := xor_i;
                                when x"B" => instruction_state := sub;
                                when x"C" => 
                                	case instruction_reg (3 downto 0) is
                                    	when x"4" | x"9" | x"C" => instruction_state := lshift;
                                        when others => instruction_state := comp;
                                    end case;
                                when x"D" => instruction_state := div;
                                when x"E" => instruction_state := mod_i;
                                when x"F" => instruction_state := lshift;
                                when others => null;
                                	
                            
                            
                        	end case;
                        
                        
                        end if;
                	
                    --(none, load, sum, mult, and_i, or_i, xor_i, not_i, sub, comp, div, mod_i, lshift, rshift, nop, res, resf, jump, par);
                    case instruction_state is
                   		when load => report "LOAD:";
                        when sum => report "SUM";
                        when mult => report "MULT";
                        when and_i => report "AND";
                        when or_i => report "OR";
                        when xor_i => report "XOR";
                        when not_i => report "NOT";
                        when sub => report "SUB";
                        when comp => report "COMP";
                        when div => report "DIV";
                        when mod_i => report "MOD";
                        when lshift => report "LSHIFT";
                        when rshift => report "RSHIFT";
                        when nop => report "NOP";
                        when res => report "RES";
                        when resf => report "RESF";
                        when jump => report "JUMP";
                        when par => report "PAR";
                        when none => report "ERROR!";   
                    end case;
                    
                    
                    case instruction_state is 
                    	when nop | res => c_state := complete;
                        when resf => extern_A := '1' ;
                        when and_i | or_i | xor_i | comp | div | mod_i =>
                        	if instruction_reg(3 downto 2) = instruction(1 downto 0) then
                            	math(1) := '1'; extern_B := '1';
                                addr_1 := instruction_reg(3 downto 2);
                            else
                            	math(1) := '1'; math(0) := '1';
                                addr_1 := instruction_reg(3 downto 2);
                                addr_2 := instruction_reg(1 downto 0);
                            end if;
                    	when not_i =>
                        	case instruction_reg(3 downto 0) is
                            	when x"4" => math(1) := '1'; addr_1 := "01";
                            	when x"8" => math(1) := '1'; addr_1 := "10";
                                when x"9" => extern_A := '1';
                                when x"C" => math(1) := '1'; addr_1 := "11";
                                when x"D" => math(1) := '1'; addr_1 := "00";
                                when others => null;
                            end case;
                        	
                        when sub => 
                        	if instruction(3 downto 2) = instruction(1 downto 0) then
                            	math(0) := '1'; extern_A := '1';
                                addr_2 := instruction_reg(1 downto 0);
                            else
                            	math(1) := '1'; math(0) := '1';
                                addr_1 := instruction_reg(3 downto 2);
                                addr_2 := instruction_reg(1 downto 0);
                            end if;
                            
                        when lshift =>
                        	if instruction_reg(7 downto 4) = x"F" then
                            	math(1) := '1'; math(0) := '1';
                                addr_1 := instruction_reg(3 downto 2);
                                addr_2 := instruction_reg(1 downto 0);
                                
                            elsif instruction_reg(3 downto 0) = x"4" then
                            	math(1) := '1'; extern_B := '1';
                                addr_1 := "00";
                            
                            elsif instruction_reg(3 downto 0) = x"8" then
                            	math(1) := '1'; extern_B := '1';
                                addr_1 := "01";
                                
                            elsif instruction_reg(3 downto 0) = x"9" then
                            	math(1) := '1'; extern_B := '1';
                                addr_1 := "10";
                                
                            elsif instruction_reg(3 downto 0) = x"C" then
                            	math(1) := '1'; extern_B := '1';
                                addr_1 := "11";
                            
                            end if;
                            
                        when sum | mult =>
                        	case instruction_reg (3 downto 0) is
                            	when x"E" => extern_A := '1'; extern_B := '1';
                                when x"D" =>
                                	math(1) := '1'; addr_1 := "00";
                                    extern_B := '1';
                                when x"4" | x"8" | x"C" =>
                                	math(1) := '1'; addr_1 := instruction_reg(3 downto 2);
                                    extern_B := '1';
                                when others =>
                                	math(1) := '1'; math(0) := '1';
                                    addr_1 := instruction_reg(3 downto 2);
                                    addr_2 := instruction_reg(1 downto 0);
                                
                            end case;
                            
                            -- 100 para MA 101 para a RAM
                        when load =>
                        	case instruction_reg(7 downto 4) is
                            	
                                when x"1" =>
                                	A := "000000" & instruction_reg(3 downto 2);
                                    memory(0) := '1'; addr_2 := instruction_reg(1 downto 0);
                                    
                                when x"2" =>
                                	A := "000000" & instruction_reg(3 downto 2);
                                    math(0) := '1'; addr_2 := instruction_reg(1 downto 0);
                                    
                                when x"3" =>
                                	A := "000000" & instruction_reg(3 downto 2);
                                   	
                                    if instruction_reg(3 downto 2) = instruction_reg(1 downto 0) then
                                    	extern_B := '1';
                                    else
                                    	memory(0) := '1'; addr_2 := instruction_reg(1 downto 0);
                                    end if;
                                   
                                    
                                when x"4" =>
                                	if(instruction_reg(1 downto 0) /= "11") then
                                		A := "000000" & instruction_reg(3 downto 2);
                                    else
                                    	A := "00000" & "100";
                                    end if;
                                    
                                    case instruction_reg(1 downto 0) is
                                    	when "00" => B := acummulator;
                                        when "01" => B := std_logic_vector(to_unsigned(MA, 8));
                                        when "10" => B := RAM_memory;
                                        when "11" =>
                                        	memory(0) := '1'; addr_2 := instruction_reg(3 downto 2);
                                        when others => null;
                                    end case;
                                    
                            	when x"5" =>
                                	A := "00000" & "101";
                                    memory(0) := '1'; addr_2 := instruction_reg(1 downto 0);
                                    
                                    
                                when others => null;
                            
                            end case;
                            
                            
                        when jump =>
                        	extern_A := '1';
                            
                            if instruction_reg(3 downto 0) = x"5" then
                            	extern_B := '1';
                            end if;
                            
                        when rshift => 
                        
                        	case instruction_reg is
                                when x"5D" => 
                                	math(1) := '1'; addr_1 := "11";
                                    math(0) := '1'; addr_2 := "10";
                                    
                                when x"5E" =>
                                	math(1) := '1'; addr_1 := "11";
                                    math(0) := '1'; addr_2 := "11";
                                    
                                when x"5F" =>
                                	math(1) := '1'; addr_1 := "11";
                                    extern_B := '1';
                                    
                                when x"69" =>
                                	math(1) := '1'; addr_1 := "11";
                                    math(0) := '1'; addr_2 := "00";
                                    
                                when x"79" =>
                                	math(1) := '1'; addr_1 := "11";
                                    math(0) := '1'; addr_2 := "01";
                                    
                                when x"8E" =>
                                	math(1) := '1'; addr_1 := "10";
                                    extern_B := '1';
                                    
                                when x"94" =>
                                	math(1) := '1'; addr_1 := "00";
                                    math(0) := '1'; addr_2 := "00";
                                
                                when x"98" =>
                                	math(1) := '1'; addr_1 := "00";
                                    math(0) := '1'; addr_2 := "01";
                                    
                                when x"99" =>
                                	math(1) := '1'; addr_1 := "00";
                                    math(0) := '1'; addr_2 := "10";
                                    
                                when x"9C" =>
                                	math(1) := '1'; addr_1 := "00";
                                    math(0) := '1'; addr_2 := "11";
                                    
                                when x"9D" =>
                                	math(1) := '1'; addr_1 := "00";
                                    extern_B := '1';
                                    
                                when x"9E" =>
                                	math(1) := '1'; addr_1 := "01";
                                    math(0) := '1'; addr_2 := "00";
                                	
                                when x"A4" =>
                                	math(1) := '1'; addr_1 := "01";
                                    math(0) := '1'; addr_2 := "01";
                                    
                                when x"A8" =>
                                	math(1) := '1'; addr_1 := "01";
                                    math(0) := '1'; addr_2 := "10";
                                    
                                when x"A9" =>
                                	math(1) := '1'; addr_1 := "01";
                                    math(0) := '1'; addr_2 := "11";
                                    
                                when x"AC" =>
                                	math(1) := '1'; addr_1 := "01";
                                    extern_B := '1';
                                    
                                when x"AD" =>
                                	math(1) := '1'; addr_1 := "10";
                                    math(0) := '1'; addr_2 := "00";
                                    
                                when x"AE" =>
                                	math(1) := '1'; addr_1 := "10";
                                    math(0) := '1'; addr_2 := "01";
                                    
                                when x"CD" =>
                                	math(1) := '1'; addr_1 := "10";
                                    math(0) := '1'; addr_2 := "10";
                                    
                                when x"CE" =>
                                	math(1) := '1'; addr_1 := "10";
                                    math(0) := '1'; addr_2 := "11";
                                    
                                when others => null;
                            end case;
                        
                        
                        when others => null;
                    end case;
                    
                    
                    case instruction_state is
                    	when sum => ULA_instruction <= "0000";
                        when sub => ULA_instruction <= "0001";
                        when comp => ULA_instruction <= "0010";
                        when xor_i => ULA_instruction <= "0011";
                        when not_i => ULA_instruction <= "0100";
                        when and_i => ULA_instruction <= "0101";
                        when or_i => ULA_instruction <= "0110";
                        when mult => ULA_instruction <= "0111";
                        when div => ULA_instruction <= "1000";
                        when mod_i => ULA_instruction <= "1001";
                        when lshift => ULA_instruction <= "1010";
                        when rshift => ULA_instruction <= "1011";
                        when others => null;
                    
                    end case;
                    
                    
                    if math(1) = '1' then
                    	math_addr <= addr_1;
                    	math_write <= '0';
                        math_registers <= "ZZZZZZZZ";
              		
                    elsif math(0) = '1' then
                    	math_addr <= addr_2;
                        math_write <= '0';
                        math_registers <= "ZZZZZZZZ";
                        
                    end if;
                    
                    if memory(1) = '1' then
                    	memory_addr <= addr_1;
                    	memory_write <= '0';
                        memory_registers <= "ZZZZZZZZ";
                    
                    elsif memory(0) = '1' then
                    	memory_addr <= addr_2;
                        memory_write <= '0';
                        memory_registers <= "ZZZZZZZZ";
                        
                    end if;
                    
                    if extern_A = '1' or extern_B = '1' then PC <= PC + 1; end if;
                    
                    if extern_A = '1' or math(1) = '1' or memory(1) = '1' then
                    	c_state := get_1;
                    
                    elsif extern_B = '1' or math(0) = '1' or memory(0) = '1' then
                    	c_state := get_2;
                        
                    end if;
                    
                    if not (c_state = get_1 or c_state = get_2) then c_state := perm; end if;
                    
                	if instruction_state = nop or instruction_state = res then c_state := complete; end if;
                
                when get_1 => 
                	--report "== Guardando valor em A ==";
                
                	if math(1) = '1' then
                    	A := math_registers;
                    	
                    elsif memory(1) = '1' then
                    	A  := memory_registers;
                        
                    elsif extern_A = '1' then
                    	A := instruction;
                        
                    end if;
                    
                    	
               		
                    if math(0) = '1' then
                    	math_addr <= addr_2;
                        math_write <= '0';
                        math_registers <= "ZZZZZZZZ";
                        
                    end if;
                    
                    if memory(0) = '1' then
                    	memory_addr <= addr_2;
                        memory_write <= '0';
                        memory_registers <= "ZZZZZZZZ";
                        
                    end if;
                    
                    --report "A: " & std_logic_vector'image(A);
               
               		if extern_B = '1' and extern_A = '1' then PC <= PC + 1; end if;
                
                
                    if extern_B = '1' or math(0) = '1' or memory(0) = '1' then
                    	c_state := get_2;
                     
                     end if;
                     
                     if c_state /= get_2 then c_state := perm; end if;
                    
                
                when get_2 =>
                	--report "== Guardando valor em B ==";
                    
                	if math(0) = '1' then
                    	B := math_registers;
                    
                    elsif memory(0) = '1' then
                    	B  := memory_registers;
                        
                    elsif extern_B = '1' then
                    	B := instruction;
                        
                    end if;
                    
                    --report "B: " & std_logic_vector'image(B);
                    
               		c_state := perm;
                    
                when perm => 
                	--report "== Aguardando Permissoes ==";
                    
                    case instruction_state is
                    	when sum | sub | comp | xor_i | not_i | and_i | or_i | mult | div | mod_i | lshift | rshift =>
                        ULA_A <= A; ULA_B <= B;
                    	ULA_permission <= '1';
                        c_state := in_process;
                        
                        report "Operacao com A: " & std_logic_vector'image(A) & " B: " & std_logic_vector'image(B);
                        
                        when load => 
                        	c_state := load_save;
                            
                        	case instruction_reg(7 downto 4) is
                            	when x"1" => math_write <= '1'; math_addr <= A(1 downto 0);
                                when x"2" | x"3" | x"4" => memory_write <= '1'; memory_addr <= A(1 downto 0);
                                when x"5" => RAM_write <= '1';
                            	when others => null;
                            end case;
                            
                        when jump | resf =>
                        	compare_statement <= B;
                        	c_state := complete;
                            
                        when others => report "Error in perm!";
                    
                    end case;
                
                when load_save => 
                	--report "== Salvando valores ==";
                    
                	case instruction_reg(7 downto 4) is
                    	when x"1" => math_registers <= B;
                        when x"2" | x"3" | x"4" => memory_registers <= B;
                        when x"5" => RAM_memory <= B;
                    	when others => null;
                    end case;
                    
                    c_state := in_process;
                
                when in_process => 
                	--report "== Esperando término da instrucao ==";
                
                	case instruction_state is
                    	when sum | sub | comp | xor_i | not_i | and_i | or_i | mult | div | mod_i | lshift | rshift =>
                    	if ULA_finished = '1' then
                        	c_state := complete;
                            report "Teste" & std_logic_vector'image(ULA_output) & " codigo " & std_logic_vector'image(ULA_instruction);
                            report "VALORES: " & std_logic_vector'image(ULA_A) & " " & std_logic_vector'image(ULA_B);
                            
                        end if;
                        	
                        when load => c_state := complete;
                            
                        when others => report "Error in process";
                    
                    end case;
                    
                    
                	
                
                when complete => 
                	--report "== Terminando a instrucao ==";
                
                	case instruction_state is
                    	when sum | sub | xor_i | not_i | and_i | or_i | mult | div | mod_i | lshift | rshift =>
                        	acummulator := ULA_output;
                            flags(4) <= overflow;
                            
                            report "Resultado: " & std_logic_vector'image(ULA_output) & " Flag: " & std_logic'image(overflow);
                        when comp =>
                        	flags(3 downto 0) <= ULA_output(3 downto 0);
                            report "Flag atualizada" & std_logic_vector'image(ULA_output(3 downto 0));
                            
                        when res =>
                        	reset <= '1';
                            report "Todos os registradores foram resetados!";
                            
                        when resf =>
                        	if conditional_flag = '1' then reset <= '1'; end if;
                            
                        when jump =>
                        	case instruction_reg(0) is
                            	when '0' => PC <= to_integer(unsigned(A));
                                when '1' =>
                                	report "Condicional: " & std_logic'image(conditional_flag);
                                	if conditional_flag = '1' then
                                    	PC <= to_integer(unsigned(A)); 
                                    else
                                    	PC <= PC + 1;
                                    end if;
                                when others => null;
                            end case;
                        
                        when load =>
                        	report "Novo valor armazenado: " & std_logic_vector'image(B);
                            
                        when nop => null;
                        when others => null;
                        
                        
                    end case;
                   
                if instruction_state /= jump then
                  PC <= PC + 1;
                end if;

                c_state := idl;
				
				report "== Termino do ciclo ==";
            end case;
        
        
        end if;
    
    
    
    end process CONTROL_UNIT;
    
    
    
    
    
	


end C_UNIT_ARCH;

