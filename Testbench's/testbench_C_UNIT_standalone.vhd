library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_C_UNIT_standalone is
end testbench_C_UNIT_standalone;

architecture TB of testbench_C_UNIT_standalone is
    -- Signals
    signal reset : std_logic := '0';
    signal use_internal_clock : std_logic := '1';  -- Usar clock interno
    signal debug_pc : integer range 0 to 255;
    signal debug_state : std_logic_vector(2 downto 0);
    
    -- Component declaration
    component C_UNIT is port(
        clock : in std_logic := '0';
        reset : in std_logic := '0';
        use_internal_clock : in std_logic := '1';
        debug_pc : out integer range 0 to 255;
        debug_state : out std_logic_vector(2 downto 0)
    );
    end component;
    
    -- State names for display
    type state_name_type is (FETCH, DECODE, GET_VALUE1, GET_VALUE2, EXECUTE, WRITE_BACK, HALT);
    signal current_state_name : state_name_type;
    
begin
    
    -- Instantiate C_UNIT with internal clock
    DUT: C_UNIT port map (
        clock => '0',  -- Not used when use_internal_clock = '1'
        reset => reset,
        use_internal_clock => use_internal_clock,
        debug_pc => debug_pc,
        debug_state => debug_state
    );
    
    -- Convert state vector to name for easier reading
    current_state_name <= FETCH when debug_state = "000" else
                          DECODE when debug_state = "001" else
                          GET_VALUE1 when debug_state = "010" else
                          GET_VALUE2 when debug_state = "011" else
                          EXECUTE when debug_state = "100" else
                          WRITE_BACK when debug_state = "101" else
                          HALT;
    
    -- Test process
    TEST_PROC: process
    begin
        -- Reset inicial
        report "=== INICIANDO TESTE DO PROCESSADOR (CLOCK INTERNO) ===";
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        
        report "Reset liberado. Processador executando programa...";
        
        -- Deixa executar por um tempo
        wait for 1000 ns;
        
        report "=== TESTE CONCLUÍDO ===";
        report "Programa executado. Verifique os valores dos registradores.";
        
        -- Finaliza simulação
        wait;
    end process TEST_PROC;
    
    -- Monitor process - exibe informações a cada mudança de estado
    MONITOR: process(debug_state, debug_pc)
    begin
        report "PC=" & integer'image(debug_pc) & 
               " Estado=" & state_name_type'image(current_state_name);
    end process MONITOR;
    
end TB;
