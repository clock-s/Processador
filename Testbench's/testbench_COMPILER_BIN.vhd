library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Testbench para executar programas .bin do compilador
-- Usa o arquivo teste_debug.bin como ROM

entity testbench_COMPILER_BIN is
end testbench_COMPILER_BIN; 

architecture tb_COMPILER_BIN of testbench_COMPILER_BIN is

    -- Component declaration
    component C_UNIT is port(
        clock       : in  std_logic;
        reset       : in  std_logic;
        use_internal_clock : in std_logic := '1';
        debug_pc    : out integer range 0 to 255;
        debug_state : out std_logic_vector(2 downto 0)
    );
    end component;

    -- Test signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal use_int_clk : std_logic := '1';
    signal pc_out : integer range 0 to 255;
    signal state_out : std_logic_vector(2 downto 0);
    
    -- Clock period
    constant clk_period : time := 10 ns;
    
    -- Control signals
    signal simulation_end : boolean := false;
    
begin
    
    -- Instantiate the Unit Under Test (UUT)
    -- IMPORTANTE: Modifique C_UNIT para usar archive_bin.vhd ao invés de archive_eda.vhd
    UUT: C_UNIT port map (
        clock => clk,
        reset => rst,
        use_internal_clock => use_int_clk,
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
    
    -- Monitor process
    monitor_process : process(clk)
        variable state_str : string(1 to 11);
    begin
        if rising_edge(clk) then
            -- Decode state
            case state_out is
                when "000" => state_str := "FETCH      ";
                when "001" => state_str := "DECODE     ";
                when "010" => state_str := "GET_VALUE1 ";
                when "011" => state_str := "GET_VALUE2 ";
                when "100" => state_str := "EXECUTE    ";
                when "101" => state_str := "WRITE_BACK ";
                when others => state_str := "HALT       ";
            end case;
            
            -- Display current state and PC
            report "Clock " & integer'image(now / clk_period) & 
                   " | PC: " & integer'image(pc_out) & 
                   " | State: " & state_str;
        end if;
    end process;
    
    -- Stimulus process
    stimulus_process : process
    begin
        report "=================================================";
        report "    EXECUTANDO PROGRAMA DO COMPILADOR";
        report "    Arquivo: teste.bin";
        report "=================================================";
        report "";
        
        -- Initial reset
        rst <= '1';
        wait for clk_period * 2;
        
        report "Removendo reset - Processador iniciando...";
        rst <= '0';
        wait for clk_period;
        
        report "";
        report "=================================================";
        report "    PROGRAMA EM EXECUCAO";
        report "=================================================";
        report "";
        
        -- Let processor run
        -- Program from teste.bin (compiled from teste_basico.gbf):
        -- 0x30 0x01 : LOAD r1, 1
        -- 0x35 0x05 : LOAD r2, 5
        -- 0x14      : LOAD x, r2
        -- 0x11      : LOAD y, r1
        -- 0x61      : SUM x, y     (x = 5 + 1 = 6)
        -- 0x20      : LOAD r1, x   (r1 = 6)
        -- 0xB1      : SUB y, y     (y = 1 - 1 = 0)
        -- 0x24      : LOAD r2, x   (r2 = 6)
        -- 0x71      : MULT y, y    (y = 0 * 0 = 0)
        -- 0x28      : LOAD r3, x   (r3 = 6)
        -- 0x3C 0x1B : LOAD r4, 27  (r4 = 27 = 0x1B)
        -- 0x00      : NOP/HALT
        
        wait for clk_period * 100;
        
        report "";
        report "=================================================";
        report "    EXECUCAO CONCLUIDA";
        report "=================================================";
        report "";
        report "PC Final: " & integer'image(pc_out);
        report "";
        report "RESULTADOS ESPERADOS:";
        report "  r1 = 6";
        report "  r2 = 6";
        report "  r3 = 6";
        report "  r4 = 27 (0x1B)";
        report "  x  = 6";
        report "  y  = 0";
        report "";
        report "Verifique os valores finais dos registradores";
        report "";
        
        -- End simulation
        simulation_end <= true;
        wait;
    end process;

end tb_COMPILER_BIN;
