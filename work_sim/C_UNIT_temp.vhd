library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity C_UNIT is port(
    clock : in std_logic := '0';  -- Clock externo (opcional)
    reset : in std_logic := '0';
    use_internal_clock : in std_logic := '1';  -- '1' = usar clock interno, '0' = usar clock externo
    
    -- Debug outputs (opcional)
    debug_pc : out integer range 0 to 255;
    debug_state : out std_logic_vector(2 downto 0)
);
end C_UNIT;


architecture C_UNIT_ARCH of C_UNIT is
    -- Internal clock signal
    signal internal_clock : std_logic := '0';
    signal active_clock : std_logic;
    
    -- Program Counter
    signal PC : integer range 0 to 255 := 0;
    
    -- Instruction memory interface
    signal instruction : std_logic_vector (7 downto 0);
    signal rom_addr : integer range 0 to 255 := 0;
    
    -- ULA interface
    signal ULA_OUTPUT, ULA_A, ULA_B : std_logic_vector (7 downto 0);
    signal ULA_permission, ULA_finished, ULA_overflow : std_logic;
    signal ULA_instruction : std_logic_vector (3 downto 0);
    
    -- Memory registers interface (r1, r2, r3, r4)
    signal mem_write_enable : std_logic := '0';
    signal mem_write_addr : integer range 0 to 3 := 0;
    signal mem_write_data : std_logic_vector(7 downto 0) := (others => '0');
    signal mem_read_addr_a : integer range 0 to 3 := 0;
    signal mem_read_addr_b : integer range 0 to 3 := 0;
    signal mem_read_data_a : std_logic_vector(7 downto 0);
    signal mem_read_data_b : std_logic_vector(7 downto 0);
    
    -- Math registers interface (x, y, z, w)
    signal math_write_enable : std_logic := '0';
    signal math_write_addr : integer range 0 to 3 := 0;
    signal math_write_data : std_logic_vector(7 downto 0) := (others => '0');
    signal math_read_addr_a : integer range 0 to 3 := 0;
    signal math_read_addr_b : integer range 0 to 3 := 0;
    signal math_read_data_a : std_logic_vector(7 downto 0);
    signal math_read_data_b : std_logic_vector(7 downto 0);
    
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
    
    -- Wait flag for ROM read
    signal waiting_rom : std_logic := '0';
    
    -- Decoded instruction fields
    signal opcode : std_logic_vector(7 downto 0);
    signal current_instruction : std_logic_vector(7 downto 0);  -- Save current instruction
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
    
    component PACK_REGISTER_MEM is port(
        clock : in std_logic;
        reset : in std_logic;
        write_enable : in std_logic;
        write_addr : in integer range 0 to 3;
        write_data : in std_logic_vector(7 downto 0);
        read_addr_a : in integer range 0 to 3;
        read_addr_b : in integer range 0 to 3;
        read_data_a : out std_logic_vector(7 downto 0);
        read_data_b : out std_logic_vector(7 downto 0)
    );
    end component;
    
    component PACK_REGISTER_MATH is port(
        clock : in std_logic;
        reset : in std_logic;
        write_enable : in std_logic;
        write_addr : in integer range 0 to 3;
        write_data : in std_logic_vector(7 downto 0);
        read_addr_a : in integer range 0 to 3;
        read_addr_b : in integer range 0 to 3;
        read_data_a : out std_logic_vector(7 downto 0);
        read_data_b : out std_logic_vector(7 downto 0)
    );
    end component;

begin
    
    -- Internal clock generator process
    CLOCK_GEN: process
    begin
        if use_internal_clock = '1' then
            internal_clock <= '0';
            wait for 10 ns;
            internal_clock <= '1';
            wait for 10 ns;
        else
            wait;
        end if;
    end process CLOCK_GEN;
    
    -- Clock multiplexer: choose between internal and external clock
    active_clock <= internal_clock when use_internal_clock = '1' else clock;
    
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
        clock => active_clock  -- Use active_clock instead of clock
    );
    
    -- Memory registers bank (r1, r2, r3, r4)
    MEM_REGS : PACK_REGISTER_MEM port map (
        clock => active_clock,
        reset => reset,
        write_enable => mem_write_enable,
        write_addr => mem_write_addr,
        write_data => mem_write_data,
        read_addr_a => mem_read_addr_a,
        read_addr_b => mem_read_addr_b,
        read_data_a => mem_read_data_a,
        read_data_b => mem_read_data_b
    );
    
    -- Math registers bank (x, y, z, w)
    MATH_REGS : PACK_REGISTER_MATH port map (
        clock => active_clock,
        reset => reset,
        write_enable => math_write_enable,
        write_addr => math_write_addr,
        write_data => math_write_data,
        read_addr_a => math_read_addr_a,
        read_addr_b => math_read_addr_b,
        read_data_a => math_read_data_a,
        read_data_b => math_read_data_b
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
    CONTROL_UNIT : process(active_clock, reset)
        variable fetch_count : integer := 0;
        variable wait_ula : std_logic := '0';
        variable temp_value : std_logic_vector(7 downto 0);
    begin
        if reset = '1' then
            PC <= 0;
            current_state <= FETCH;
            flags_reg <= (others => '0');
            acc_reg <= (others => '0');
            ma_reg <= 0;
            ULA_permission <= '0';
            rom_addr <= 0;
            mem_write_enable <= '0';
            math_write_enable <= '0';
            waiting_rom <= '0';
            
        elsif rising_edge(active_clock) then
            
            -- Reset write enables at the start of each cycle
            mem_write_enable <= '0';
            math_write_enable <= '0';
            
            case current_state is
                
                -- FETCH: Buscar instrucao da memoria
                when FETCH =>
                    rom_addr <= PC;
                    ULA_permission <= '0';
                    current_state <= DECODE;
                    needs_value1 <= '0';
                    needs_value2 <= '0';
                    is_jump <= '0';
                    report "=== FETCH: PC=" & integer'image(PC) & " ===";
                
                -- DECODE: Decodifica instrucao
                when DECODE =>
                    -- Check if we would overflow before incrementing
                    if PC >= 255 then
                        -- Reached end of memory, halt
                        current_state <= HALT;
                    else
                        opcode <= instruction;
                        current_instruction <= instruction;  -- Save instruction for later use
                        report "DECODE: inst=" & integer'image(to_integer(unsigned(instruction)));
                        
                        -- Increment PC here (will point to next byte)
                        -- If instruction needs immediate value, PC will point to it
                        PC <= PC + 1;
                    
                        -- Decode based on opcode nibbles
                        -- Upper nibble determines instruction type
                        case instruction(7 downto 4) is
                        
                        -- 0x00: NOP
                        when "0000" =>
                            if instruction = "00000000" then
                                -- NOP: Check if we should halt (PC > program size)
                                if PC > 64 then
                                    current_state <= HALT;
                                else
                                    current_state <= FETCH;
                                end if;
                            -- 0x01: RES (reset registers) - handled by pack registers reset
                            elsif instruction = "00000001" then
                                -- Note: Cannot directly reset pack registers from here
                                -- They reset with global reset signal
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
                            -- Setup read from memory register
                            mem_read_addr_a <= to_integer(unsigned(instruction(1 downto 0)));
                            -- DON'T read operand1 yet, need to wait 1 cycle for register read
                            -- Will read in EXECUTE state
                            current_state <= EXECUTE;
                        
                        -- 0x2X: LOAD memory_reg <- math_reg
                        when "0010" =>
                            -- Setup write to memory register
                            math_read_addr_a <= to_integer(unsigned(instruction(3 downto 2)));
                            mem_write_enable <= '1';
                            mem_write_addr <= to_integer(unsigned(instruction(1 downto 0)));
                            mem_write_data <= math_read_data_a;
                            current_state <= FETCH;
                        
                        -- 0x3X: LOAD memory_reg <- memory_reg or value
                        when "0011" =>
                            dest_reg <= to_integer(unsigned(instruction(3 downto 2)));
                            src_reg <= to_integer(unsigned(instruction(1 downto 0)));
                            if instruction(1 downto 0) = instruction(3 downto 2) then
                                -- Load immediate value
                                needs_value1 <= '1';
                                -- DON'T update rom_addr here, let GET_VALUE1 do it
                                current_state <= GET_VALUE1;
                            else
                                -- Copy between memory registers
                                mem_read_addr_a <= to_integer(unsigned(instruction(1 downto 0)));
                                -- DON'T write yet, need to wait 1 cycle for register read
                                -- Will write in EXECUTE state
                                current_state <= EXECUTE;
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
                                -- SUM V1, V2 (both immediate)
                                needs_value1 <= '1';
                                needs_value2 <= '1';
                            elsif instruction(3 downto 0) = "1101" then
                                -- SUM x, V2 (x register, immediate)
                                needs_value2 <= '1';
                            elsif (instruction(3 downto 2) = instruction(1 downto 0)) then
                                -- SUM x, x or SUM y, y etc (same register - uses only operand1)
                                needs_value2 <= '0';
                            else
                                -- SUM x, y or SUM x, z etc (different registers - no immediate)
                                needs_value2 <= '0';
                            end if;
                            current_state <= GET_VALUE1;
                        
                        -- 0x7X: MULT
                        when "0111" =>
                            decoded_operation <= "0111"; -- MULT operation
                            if instruction(3 downto 0) = "1110" then
                                -- MULT V1, V2 (both immediate)
                                needs_value1 <= '1';
                                needs_value2 <= '1';
                            elsif instruction(3 downto 0) = "1101" then
                                -- MULT x, V2 (x register, immediate)
                                needs_value2 <= '1';
                            elsif (instruction(3 downto 2) = instruction(1 downto 0)) then
                                -- MULT x, x (same register)
                                needs_value2 <= '0';
                            else
                                -- MULT x, y (different registers)
                                needs_value2 <= '0';
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
                            if instruction(3 downto 0) = "1110" then
                                -- SUB V1, V2 (both immediate)
                                needs_value1 <= '1';
                                needs_value2 <= '1';
                            elsif instruction(3 downto 0) = "1101" then
                                -- SUB x, V2 (register, immediate)
                                needs_value2 <= '1';
                            elsif (instruction(3 downto 2) = instruction(1 downto 0)) then
                                -- SUB x, x (same register)
                                needs_value2 <= '0';
                            else
                                -- SUB x, y (different registers)
                                needs_value2 <= '0';
                            end if;
                            current_state <= GET_VALUE1;
                        
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
                    end if;  -- End of PC < 255 check
                
                -- GET_VALUE1: Obter primeiro operando se necessario
                when GET_VALUE1 =>
                    if needs_value1 = '1' then
                        -- First time here? Update rom_addr and wait
                        if waiting_rom = '0' then
                            rom_addr <= PC;  -- Point to immediate value
                            waiting_rom <= '1';
                            -- Stay in GET_VALUE1 to wait for ROM
                        else
                            -- ROM updated, now read the value
                            operand1 <= instruction;
                            needs_value1 <= '0';
                            waiting_rom <= '0';
                            report "GET_VALUE1: Lendo valor imediato " & integer'image(to_integer(unsigned(instruction)));
                            -- Increment PC after reading immediate value
                            if PC < 255 then
                                PC <= PC + 1;  -- Move past the immediate value we just read
                            end if;
                            
                            if needs_value2 = '1' then
                                -- Need to read another immediate value
                                if PC < 254 then
                                    rom_addr <= PC + 1;  -- Point to next immediate value
                                    current_state <= GET_VALUE2;
                                else
                                    current_state <= HALT;  -- Prevent overflow
                                end if;
                            else
                                -- No more immediate values needed
                                current_state <= EXECUTE;
                            end if;
                        end if;
                    else
                        -- Get value from math registers (x, y, z, w)
                        -- Use current_instruction (saved in DECODE), not instruction from ROM
                        math_read_addr_a <= to_integer(unsigned(current_instruction(3 downto 2)));
                        math_read_addr_b <= to_integer(unsigned(current_instruction(1 downto 0)));
                        -- DON'T read operand1/operand2 yet, need to wait 1 cycle for register read
                        -- Will read in EXECUTE state
                        
                        if needs_value2 = '1' then
                            -- Need to read immediate value for operand2
                            rom_addr <= PC;  -- PC already points to immediate value
                            report "GET_VALUE1: Lendo de registrador, aguardando valor imediato";
                            current_state <= GET_VALUE2;
                        else
                            -- Both operands from registers
                            report "GET_VALUE1: Ambos operandos de registradores";
                            current_state <= EXECUTE;
                        end if;
                    end if;
                
                -- GET_VALUE2: Obter segundo operando se necessario
                when GET_VALUE2 =>
                    operand2 <= instruction;
                    needs_value2 <= '0';
                    report "GET_VALUE2: Lendo valor imediato " & integer'image(to_integer(unsigned(instruction)));
                    current_state <= EXECUTE;
                
                -- EXECUTE: Executa operacao
                when EXECUTE =>
                    report ">>> EXECUTE: opcode=" & integer'image(to_integer(unsigned(opcode)));
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
                        -- Now mem_read_data_a has the correct value (after 1 cycle delay)
                        math_write_enable <= '1';
                        math_write_addr <= dest_reg;
                        math_write_data <= mem_read_data_a;  -- Read NOW, after 1 cycle
                        report "  -> LOAD math_regs[" & integer'image(dest_reg) & "] = " & integer'image(to_integer(unsigned(mem_read_data_a)));
                        current_state <= FETCH;
                    elsif opcode(7 downto 4) = "0011" and needs_value1 = '1' then
                        -- LOAD memory_reg <- immediate value (0x3X with immediate)
                        mem_write_enable <= '1';
                        mem_write_addr <= dest_reg;
                        mem_write_data <= operand1;
                        report "  -> LOAD mem_regs[" & integer'image(dest_reg) & "] = " & integer'image(to_integer(unsigned(operand1)));
                        current_state <= FETCH;
                    elsif opcode(7 downto 4) = "0011" and needs_value1 = '0' then
                        -- LOAD memory_reg <- memory_reg (0x3X copy between mem_regs)
                        -- Now mem_read_data_a has the correct value (after 1 cycle delay)
                        mem_write_enable <= '1';
                        mem_write_addr <= dest_reg;
                        mem_write_data <= mem_read_data_a;  -- Read NOW, after 1 cycle
                        report "  -> LOAD mem_regs[" & integer'image(dest_reg) & "] = mem_regs[" & integer'image(src_reg) & "] = " & integer'image(to_integer(unsigned(mem_read_data_a)));
                        current_state <= FETCH;
                    else
                        -- Setup ULA inputs for arithmetic/logic operations
                        -- Check if operands need to be read from math registers
                        -- (happens when GET_VALUE1 configured read addresses but didn't read data)
                        if needs_value1 = '0' and needs_value2 = '0' then
                            -- Both operands from math registers (read NOW, after 1 cycle delay)
                            ULA_A <= math_read_data_a;
                            ULA_B <= math_read_data_b;
                        elsif needs_value1 = '0' and needs_value2 = '1' then
                            -- A from register, B from immediate
                            ULA_A <= math_read_data_a;
                            ULA_B <= operand2;
                        else
                            -- Operands already loaded from immediate values
                            ULA_A <= operand1;
                            ULA_B <= operand2;
                        end if;
                        
                        ULA_instruction <= decoded_operation;
                        ULA_permission <= '1';
                        wait_ula := '1';
                        
                        if needs_value1 = '0' and needs_value2 = '0' then
                            report "  -> ULA: A=" & integer'image(to_integer(unsigned(math_read_data_a))) & 
                                   " B=" & integer'image(to_integer(unsigned(math_read_data_b))) &
                                   " OP=" & integer'image(to_integer(unsigned(decoded_operation)));
                        elsif needs_value1 = '0' and needs_value2 = '1' then
                            report "  -> ULA: A=" & integer'image(to_integer(unsigned(math_read_data_a))) & 
                                   " B=" & integer'image(to_integer(unsigned(operand2))) &
                                   " OP=" & integer'image(to_integer(unsigned(decoded_operation)));
                        else
                            report "  -> ULA: A=" & integer'image(to_integer(unsigned(operand1))) & 
                                   " B=" & integer'image(to_integer(unsigned(operand2))) &
                                   " OP=" & integer'image(to_integer(unsigned(decoded_operation)));
                        end if;
                        
                        current_state <= WRITE_BACK;
                    end if;
                
                -- WRITE_BACK: Escrever resultado
                when WRITE_BACK =>
                    if wait_ula = '1' then
                        if ULA_finished = '1' then
                            -- Store result
                            acc_reg <= ULA_OUTPUT;
                            
                            -- Update destination register in math registers
                            math_write_enable <= '1';
                            math_write_addr <= to_integer(unsigned(opcode(3 downto 2)));
                            math_write_data <= ULA_OUTPUT;
                            
                            report "WRITE_BACK: resultado=" & integer'image(to_integer(unsigned(ULA_OUTPUT))) & 
                                   " escrito em math_regs[" & integer'image(to_integer(unsigned(opcode(3 downto 2)))) & "]";
                            
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
