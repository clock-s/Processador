library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity C_UNIT is port(
    clock : in std_logic;
    reset : in std_logic;
    
    -- Debug outputs (opcional)
    debug_pc : out integer range 0 to 255;
    debug_state : out std_logic_vector(2 downto 0)
);
end C_UNIT;


architecture C_UNIT_ARCH of C_UNIT is
    -- Program Counter
    signal PC : integer range 0 to 255 := 0;
    
    -- Instruction memory interface
    signal instruction : std_logic_vector (7 downto 0);
    signal rom_addr : integer range 0 to 255 := 0;
    
    -- ULA interface
    signal ULA_OUTPUT, ULA_A, ULA_B : std_logic_vector (7 downto 0);
    signal ULA_permission, ULA_finished, ULA_overflow : std_logic;
    signal ULA_instruction : std_logic_vector (3 downto 0);
    
    -- Memory registers (r1, r2, r3, r4) - Implementados internamente
    type mem_reg_array is array (0 to 3) of std_logic_vector(7 downto 0);
    signal mem_regs : mem_reg_array := (others => (others => '0'));
    
    -- Math registers (x=0, y=1, z=2, w=3) - Separados dos memory registers
    type math_reg_array is array (0 to 3) of std_logic_vector(7 downto 0);
    signal math_regs : math_reg_array := (others => (others => '0'));
    
    -- Flags register for COMP instruction
    signal flags_reg : std_logic_vector(7 downto 0) := (others => '0');
    -- Bit 0: Zero (Z), Bit 1: Negative (N), Bit 2: Carry (C), Bit 3: Parity (P)
    -- Bit 7: K (overflow from ULA)
    
    -- Accumulator register
    signal acc_reg : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Memory Address register
    signal ma_reg : integer range 0 to 255 := 0;
    
    -- Control state machine
    type state_type is (FETCH, DECODE, GET_VALUE1, GET_VALUE2, EXECUTE, WRITE_BACK, HALT);
    signal current_state : state_type := FETCH;
    
    -- Decoded instruction fields
    signal opcode : std_logic_vector(7 downto 0);
    signal decoded_operation : std_logic_vector(3 downto 0);
    signal operand1 : std_logic_vector(7 downto 0);
    signal operand2 : std_logic_vector(7 downto 0);
    signal dest_reg : integer range 0 to 3;
    signal src_reg : integer range 0 to 3;
    signal needs_value1 : std_logic;
    signal needs_value2 : std_logic;
    signal is_jump : std_logic;
    signal jump_addr : integer range 0 to 255;
    
    -- Components
    component archive is port(
        data : out std_logic_vector (7 downto 0);
        addr : in integer range 0 to 255
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

begin
    
    -- Component instantiation
    INTERNAL_MEMORY : archive port map (instruction, rom_addr);
    
    ALU_UNIT : ULA port map (
        output => ULA_OUTPUT,
        finished => ULA_finished,
        overflow => ULA_overflow,
        A => ULA_A,
        B => ULA_B,
        permission => ULA_permission,
        instruction => ULA_instruction,
        clock => clock
    );
    
    -- Debug outputs
    debug_pc <= PC;
    debug_state <= "000" when current_state = FETCH else
                   "001" when current_state = DECODE else
                   "010" when current_state = GET_VALUE1 else
                   "011" when current_state = GET_VALUE2 else
                   "100" when current_state = EXECUTE else
                   "101" when current_state = WRITE_BACK else
                   "111";
    
    -- Main control process
    CONTROL_UNIT : process(clock, reset)
        variable fetch_count : integer := 0;
        variable wait_ula : std_logic := '0';
        variable temp_value : std_logic_vector(7 downto 0);
    begin
        if reset = '1' then
            PC <= 0;
            current_state <= FETCH;
            math_regs <= (others => (others => '0'));
            mem_regs <= (others => (others => '0'));  -- Reset memory registers
            flags_reg <= (others => '0');
            acc_reg <= (others => '0');
            ma_reg <= 0;
            ULA_permission <= '0';
            rom_addr <= 0;
            
        elsif rising_edge(clock) then
            
            case current_state is
                
                -- FETCH: Buscar instrução da memória
                when FETCH =>
                    rom_addr <= PC;
                    ULA_permission <= '0';
                    current_state <= DECODE;
                    needs_value1 <= '0';
                    needs_value2 <= '0';
                    is_jump <= '0';
                
                -- DECODE: Decodificar instrução
                when DECODE =>
                    opcode <= instruction;
                    PC <= PC + 1;
                    
                    -- Decode based on opcode nibbles
                    -- Upper nibble determines instruction type
                    case instruction(7 downto 4) is
                        
                        -- 0x00: NOP
                        when "0000" =>
                            if instruction = "00000000" then
                                current_state <= FETCH;
                            -- 0x01: RES (reset registers)
                            elsif instruction = "00000001" then
                                math_regs <= (others => (others => '0'));
                                current_state <= FETCH;
                            -- 0x02: RESF (reset flags)
                            elsif instruction = "00000010" then
                                flags_reg <= (others => '0');
                                current_state <= FETCH;
                            -- 0x0C: COMP instruction (various comparisons)
                            else
                                decoded_operation <= "0010"; -- COMP operation in ULA
                                current_state <= EXECUTE;
                            end if;
                        
                        -- 0x1X: LOAD math_reg <- memory_reg
                        when "0001" =>
                            dest_reg <= to_integer(unsigned(instruction(3 downto 2)));
                            src_reg <= to_integer(unsigned(instruction(1 downto 0)));
                            -- Read from internal memory register array
                            operand1 <= mem_regs(src_reg);
                            current_state <= EXECUTE;
                        
                        -- 0x2X: LOAD memory_reg <- math_reg
                        when "0010" =>
                            src_reg <= to_integer(unsigned(instruction(3 downto 2)));
                            dest_reg <= to_integer(unsigned(instruction(1 downto 0)));
                            -- Write to internal memory register array
                            mem_regs(dest_reg) <= math_regs(src_reg);
                            current_state <= FETCH;
                        
                        -- 0x3X: LOAD memory_reg <- memory_reg or value
                        when "0011" =>
                            dest_reg <= to_integer(unsigned(instruction(3 downto 2)));
                            if instruction(1 downto 0) = instruction(3 downto 2) then
                                -- Load immediate value
                                needs_value1 <= '1';
                                current_state <= GET_VALUE1;
                            else
                                -- Copy between memory registers (interno)
                                src_reg <= to_integer(unsigned(instruction(1 downto 0)));
                                mem_regs(dest_reg) <= mem_regs(src_reg);
                                current_state <= FETCH;
                            end if;
                        
                        -- 0x4X: LOAD with special registers (a, ma, [ma])
                        when "0100" =>
                            -- Handle accumulator and memory address operations
                            current_state <= EXECUTE;
                        
                        -- 0x5X: JUMP and RSHIFT (wx, wy, wz, ww, w,V)
                        when "0101" =>
                            if instruction(7 downto 4) = "0101" and instruction(3 downto 2) = "01" then
                                -- JUMP instruction
                                is_jump <= '1';
                                needs_value1 <= '1';
                                current_state <= GET_VALUE1;
                            else
                                -- RSHIFT operations
                                decoded_operation <= "1011"; -- RSHIFT
                                current_state <= EXECUTE;
                            end if;
                        
                        -- 0x6X: SUM
                        when "0110" =>
                            decoded_operation <= "0000"; -- SUM operation
                            -- Check if needs immediate values
                            if instruction(3 downto 0) = "1110" then
                                needs_value1 <= '1';
                                needs_value2 <= '1';
                            elsif instruction(3 downto 0) = "1101" or 
                                  (instruction(3 downto 2) = "00" and instruction(1 downto 0) /= "00") or
                                  (instruction(3 downto 2) = "01" and instruction(1 downto 0) /= "01") or
                                  (instruction(3 downto 2) = "10" and instruction(1 downto 0) /= "10") or
                                  (instruction(3 downto 2) = "11" and instruction(1 downto 0) /= "11") then
                                needs_value2 <= '1';
                            end if;
                            current_state <= GET_VALUE1;
                        
                        -- 0x7X: MULT
                        when "0111" =>
                            decoded_operation <= "0111"; -- MULT operation
                            if instruction(3 downto 0) = "1110" then
                                needs_value1 <= '1';
                                needs_value2 <= '1';
                            elsif instruction(3 downto 0) = "1101" or 
                                  (instruction(3 downto 2) /= "00" and instruction(1 downto 0) = "00") or
                                  (instruction(3 downto 2) /= "01" and instruction(1 downto 0) = "01") or
                                  (instruction(3 downto 2) /= "10" and instruction(1 downto 0) = "10") or
                                  (instruction(3 downto 2) /= "11" and instruction(1 downto 0) = "11") then
                                needs_value2 <= '1';
                            end if;
                            current_state <= GET_VALUE1;
                        
                        -- 0x8X: AND or NOT
                        when "1000" =>
                            if instruction(3 downto 0) = "1001" or instruction(3 downto 0) = "1101" then
                                -- NOT with value or NOT register
                                decoded_operation <= "0100"; -- NOT
                                if instruction(3 downto 0) = "1001" then
                                    needs_value1 <= '1';
                                end if;
                            else
                                -- AND operation
                                decoded_operation <= "0101"; -- AND
                                if instruction(3 downto 0) = "1110" then
                                    needs_value1 <= '1';
                                    needs_value2 <= '1';
                                elsif instruction(1) = '1' then
                                    needs_value2 <= '1';
                                end if;
                            end if;
                            current_state <= GET_VALUE1;
                        
                        -- 0x9X: OR or RSHIFT
                        when "1001" =>
                            if instruction(3 downto 2) = "00" or instruction(3 downto 2) = "01" then
                                -- RSHIFT operations
                                decoded_operation <= "1011"; -- RSHIFT
                            else
                                -- OR operation
                                decoded_operation <= "0110"; -- OR
                                if instruction(1) = '1' then
                                    needs_value2 <= '1';
                                end if;
                            end if;
                            current_state <= GET_VALUE1;
                        
                        -- 0xAX: XOR or RSHIFT
                        when "1010" =>
                            if instruction(3 downto 2) = "10" or instruction(3 downto 2) = "11" then
                                -- XOR operation
                                decoded_operation <= "0011"; -- XOR
                                if instruction(1) = '1' then
                                    needs_value2 <= '1';
                                end if;
                            else
                                -- RSHIFT operations
                                decoded_operation <= "1011"; -- RSHIFT
                            end if;
                            current_state <= GET_VALUE1;
                        
                        -- 0xBX: SUB
                        when "1011" =>
                            decoded_operation <= "0001"; -- SUB operation
                            if instruction(3 downto 2) /= instruction(1 downto 0) then
                                -- Normal subtraction between registers
                                current_state <= GET_VALUE1;
                            else
                                -- Subtraction with immediate value
                                needs_value2 <= '1';
                                current_state <= GET_VALUE1;
                            end if;
                        
                        -- 0xCX: DIV/MOD or LSHIFT
                        when "1100" =>
                            if instruction(3 downto 2) = "00" then
                                -- LSHIFT with immediate value
                                decoded_operation <= "1010"; -- LSHIFT
                                needs_value2 <= '1';
                            elsif instruction(3 downto 2) = "11" then
                                -- DIV operation
                                decoded_operation <= "1000"; -- DIV
                            else
                                -- LSHIFT
                                decoded_operation <= "1010"; -- LSHIFT
                            end if;
                            current_state <= GET_VALUE1;
                        
                        -- 0xDX: MOD or LSHIFT
                        when "1101" =>
                            if instruction(3 downto 2) = "11" then
                                -- MOD operation
                                decoded_operation <= "1001"; -- MOD
                            else
                                -- LSHIFT or other operations
                                decoded_operation <= "1010"; -- LSHIFT
                            end if;
                            current_state <= GET_VALUE1;
                        
                        -- 0xEX, 0xFX: Various operations
                        when others =>
                            if instruction(7 downto 4) = "1110" then
                                -- DIV/MOD or RSHIFT
                                decoded_operation <= "1000"; -- Default DIV
                            else
                                -- 0xFX: LSHIFT register-register
                                decoded_operation <= "1010"; -- LSHIFT
                            end if;
                            current_state <= GET_VALUE1;
                    
                    end case;
                
                -- GET_VALUE1: Obter primeiro operando se necessário
                when GET_VALUE1 =>
                    if needs_value1 = '1' then
                        rom_addr <= PC;
                        PC <= PC + 1;
                        operand1 <= instruction;
                        needs_value1 <= '0';
                        if needs_value2 = '1' then
                            current_state <= GET_VALUE2;
                        else
                            current_state <= EXECUTE;
                        end if;
                    else
                        -- Get value from math registers (x, y, z, w)
                        operand1 <= math_regs(to_integer(unsigned(opcode(3 downto 2))));
                        
                        if needs_value2 = '1' then
                            current_state <= GET_VALUE2;
                        else
                            current_state <= EXECUTE;
                        end if;
                    end if;
                
                -- GET_VALUE2: Obter segundo operando se necessário
                when GET_VALUE2 =>
                    rom_addr <= PC;
                    PC <= PC + 1;
                    operand2 <= instruction;
                    needs_value2 <= '0';
                    current_state <= EXECUTE;
                
                -- EXECUTE: Executar operação
                when EXECUTE =>
                    if is_jump = '1' then
                        -- Handle jump
                        jump_addr <= to_integer(unsigned(operand1));
                        if needs_value2 = '1' then
                            -- Conditional jump - check flags
                            -- operand2 contains condition flags
                            if (operand2(0) = '1' and flags_reg(0) = '1') or  -- Z
                               (operand2(1) = '1' and flags_reg(1) = '1') or  -- N
                               (operand2(2) = '1' and flags_reg(2) = '1') or  -- C
                               (operand2(3) = '1' and flags_reg(3) = '1') or  -- K
                               (operand2(7) = '1' and flags_reg(7) = '1') then -- P
                                PC <= jump_addr;
                            end if;
                        else
                            -- Unconditional jump
                            PC <= jump_addr;
                        end if;
                        current_state <= FETCH;
                    elsif opcode(7 downto 4) = "0001" then
                        -- LOAD math_reg <- memory_reg (0x1X)
                        -- operand1 already has the value from mem_regs
                        math_regs(dest_reg) <= operand1;
                        current_state <= FETCH;
                    elsif opcode(7 downto 4) = "0011" and needs_value1 = '0' then
                        -- LOAD memory_reg <- immediate value (0x3X)
                        mem_regs(dest_reg) <= operand1;
                        current_state <= FETCH;
                    else
                        -- Setup ULA inputs for arithmetic/logic operations
                        ULA_A <= operand1;
                        if needs_value2 = '1' or opcode(1 downto 0) /= opcode(3 downto 2) then
                            ULA_B <= operand2;
                        else
                            ULA_B <= math_regs(to_integer(unsigned(opcode(1 downto 0))));
                        end if;
                        ULA_instruction <= decoded_operation;
                        ULA_permission <= '1';
                        wait_ula := '1';
                        current_state <= WRITE_BACK;
                    end if;
                
                -- WRITE_BACK: Escrever resultado
                when WRITE_BACK =>
                    if wait_ula = '1' then
                        if ULA_finished = '1' then
                            -- Store result
                            acc_reg <= ULA_OUTPUT;
                            
                            -- Update destination register based on instruction type
                            -- Most operations write to math registers (x, y, z, w)
                            math_regs(to_integer(unsigned(opcode(3 downto 2)))) <= ULA_OUTPUT;
                            
                            -- Update flags
                            if ULA_OUTPUT = "00000000" then
                                flags_reg(0) <= '1'; -- Zero
                            else
                                flags_reg(0) <= '0';
                            end if;
                            
                            if ULA_OUTPUT(7) = '1' then
                                flags_reg(1) <= '1'; -- Negative
                            else
                                flags_reg(1) <= '0';
                            end if;
                            
                            flags_reg(2) <= ULA_overflow; -- Carry
                            flags_reg(7) <= ULA_overflow; -- K flag
                            
                            wait_ula := '0';
                            ULA_permission <= '0';
                            current_state <= FETCH;
                        end if;
                    else
                        -- Direct write without ULA
                        current_state <= FETCH;
                    end if;
                
                -- HALT: Estado de parada
                when HALT =>
                    null;
                
                when others =>
                    current_state <= FETCH;
                    
            end case;
            
        end if;
    end process CONTROL_UNIT;

end C_UNIT_ARCH;
