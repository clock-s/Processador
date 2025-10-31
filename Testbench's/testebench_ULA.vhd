library IEEE;
use IEEE.std_logic_1164.all;

entity testbench_ULA is
end testbench_ULA; 

architecture tb_ULA of testbench_ULA is


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

signal A_in, B_in, output, reg: std_logic_vector (7 downto 0);
signal flag, overflow, clk, p : std_logic;
signal instruction : std_logic_vector (3 downto 0);

constant clk_period : time := 10 ns;

begin
    -- Connect DUT
    DUT: ULA port map(output, flag, overflow, A_in, B_in, p, instruction, clk);
    
    -- --- PROCESSO DE GERAÇÃO DE CLOCK ---
    -- É uma prática melhor ter um processo separado para o clock
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- --- PROCESSO DE ESTÍMULO ---
    stimulus_process : process
    begin
        reg <= "00000000";
        A_in <= (others => '0');
        B_in <= (others => '0');
        instruction <= (others => '0');

        
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        -- --- TESTE 1: 11 * 3  ---
        report "--- Iniciando Teste 1: (11 e 3) ---";
        A_in <= "00001011";
        B_in <= "00000011";
        instruction <= "1000";
        p <= '1';
        
        wait until rising_edge(clk); 
        
        
        report "Aguardando flag da operação...";
        wait until flag = '1';
        wait for 1 ns;
        
        -- No momento em que a flag sobe, o 'output' tem o resultado.
        -- Capturamos o resultado NESTE instante.
        reg <= output;
        p <= '0';
        
        -- Espera o próximo ciclo para o report
        wait until rising_edge(clk);
        report "Flag recebida! Resultado capturado.";
        report "REG: " & std_logic_vector'image(reg);    -- Deve ser "00100001" (33)
        report "Output (agora): " & std_logic_vector'image(output);
        report "Flag (agora): "   & std_logic'image(flag);
        
        
        -- --- TESTE 1: 11 e 3 
        report "--- Iniciando Teste 1: (11 e 3) ---";
        A_in <= "00001011";
        B_in <= "00000011";
        instruction <= "1001";
        p <= '1';
        
        -- Espera um ciclo para a ULA entrar no estado 'load'
        wait until rising_edge(clk); 
        
        -- AGORA, FICA EM LOOP ATÉ A FLAG SUBIR
        report "Aguardando flag de operação...";
        wait until flag = '1';
        wait for 1 ns;
        
        -- No momento em que a flag sobe, o 'output' tem o resultado.
        -- Capturamos o resultado NESTE instante.
        reg <= output;
        p<= '0';
        -- Espera o próximo ciclo para o report
        wait until rising_edge(clk);
        report "Flag recebida! Resultado capturado.";
        report "REG: " & std_logic_vector'image(reg);    -- Deve ser "00100001" (33)
        report "Output (agora): " & std_logic_vector'image(output);
        report "Flag (agora): "   & std_logic'image(flag);
        
        
        -- --- TESTE 2: MULT (57 * 17 = 969, deve dar overflow) ---
        report "--- Iniciando Teste 2: (57 e 17) ---";
        A_in <= "00111001";
        B_in <= "00010001";
        instruction <= "1000";
        p<='1';
        wait until rising_edge(clk);
        
        report "Aguardando flag da operação...";
        wait until flag = '1';
        
        wait for 1 ns;
        
        reg <= output;
        p <= '0';
        
        wait until rising_edge(clk);
        report "Flag recebida! Resultado capturado.";
        report "REG : " & std_logic_vector'image(reg);    -- Deve ser "11001001" (overflow de 969)
        report "Output (agora): " & std_logic_vector'image(output);
        report "Flag (agora): "   & std_logic'image(flag);

        
        -- --- TESTE 3:  ---
        report "--- Iniciando Teste 3: ---";
        instruction <= "1001";
        p <= '1';
        
        wait until rising_edge(clk); -- Espera um ciclo para a FSM da ULA (idle->load->in_process->complete)
        wait until rising_edge(clk); -- Espera mais um ciclo para garantir
        
        wait until flag = '1'; -- Espera a flag (deve ser rápida)
        
        wait for 1 ns;
        reg <= output;
        p <= '0';
        
        wait until rising_edge(clk);
        report "Flag recebida! Resultado capturado.";
        report "REG (AND): " & std_logic_vector'image(reg); -- Deve ser o resultado do AND

        -- ... (pode adicionar mais testes)
        
        wait;
  end process;
end tb_ULA;

