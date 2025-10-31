library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity testbench_PROCESSOR is
end testbench_PROCESSOR; 

architecture tb_PROCESSOR of testbench_PROCESSOR is

    -- Component declaration
    component C_UNIT is port(
        clock       : in  std_logic;
        reset       : in  std_logic;
        debug_pc    : out integer range 0 to 255;
        debug_state : out std_logic_vector(2 downto 0)
    );
    end component;

    -- Test signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal pc_out : integer range 0 to 255;
    signal state_out : std_logic_vector(2 downto 0);
    
    -- Clock period
    constant clk_period : time := 10 ns;
    
    -- Control signals
    signal simulation_end : boolean := false;
    
    -- State names for display
    type state_name_type is (FETCH, DECODE, GET_VALUE1, GET_VALUE2, EXECUTE, WRITE_BACK, HALT);
    
begin
    
    -- Instantiate the Unit Under Test (UUT)
    UUT: C_UNIT port map (
        clock => clk,
        reset => rst,
        debug_pc => pc_out,
        debug_state => state_out
    );
    
    -- Clock process
    clk_process : process
    begin
        while not simulation_end loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;
    
    -- Monitor process - exibe estado do processador
    monitor_process : process(clk)
        variable current_state_name : state_name_type;
    begin
        if rising_edge(clk) then
            -- Decode state
            case state_out is
                when "000" => current_state_name := FETCH;
                when "001" => current_state_name := DECODE;
                when "010" => current_state_name := GET_VALUE1;
                when "011" => current_state_name := GET_VALUE2;
                when "100" => current_state_name := EXECUTE;
                when "101" => current_state_name := WRITE_BACK;
                when others => current_state_name := HALT;
            end case;
            
            -- Display current state and PC
            report "Clock " & integer'image(now / clk_period) & 
                   " | PC: " & integer'image(pc_out) & 
                   " | State: " & state_name_type'image(current_state_name);
        end if;
    end process;
    
    -- Stimulus process
    stimulus_process : process
    begin
        -- Initial reset
        report "=================================================";
        report "    INICIANDO TESTE DO PROCESSADOR";
        report "=================================================";
        report "";
        
        rst <= '1';
        wait for clk_period * 2;
        
        report "Removendo reset - Processador iniciando...";
        rst <= '0';
        wait for clk_period;
        
        report "";
        report "=================================================";
        report "    EXECUTANDO PROGRAMA";
        report "=================================================";
        report "";
        
        -- Let processor run for enough cycles to complete the test program
        -- Adjust this value based on your program size
        wait for clk_period * 200;
        
        report "";
        report "=================================================";
        report "    TESTE CONCLUIDO";
        report "=================================================";
        report "";
        report "Processador executou " & integer'image(pc_out) & " instrucoes";
        report "";
        report "VERIFICACAO DOS RESULTADOS:";
        report "Verifique os valores dos registradores no waveform";
        report "r1 deve conter: 15 (0x0F)";
        report "r2 deve conter: 12 (0x0C)";
        report "r3 deve conter: 42 (0x2A)";
        report "r4 deve conter: 15 (0x0F)";
        report "";
        
        -- End simulation
        simulation_end <= true;
        wait;
    end process;

end tb_PROCESSOR;
