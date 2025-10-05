-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;
use work.PACK_ARRAY.all;
use work.functions.all;


entity testbenchREG is
-- empty
end testbenchREG; 

architecture tbREG of testbenchREG is


  component PACK_REGISTERS_PORTS is port(
	clock      : in std_logic;
    reset 	   : in std_logic;
    write_read : in std_logic; -- 0 to read and 1 to write
    
    addr  : in std_logic_vector (1 downto 0) := "00";
    
    data : inout std_logic_vector (7 downto 0);
    
    --debug : out register_array(3 downto 0);
        
);
  end component;

  component CLOCK_PORTS is port(
      clk : out std_logic
  );
  end component;

  signal data : std_logic_vector (7 downto 0);
  signal addr : std_logic_vector(1 downto 0);
  
  signal q : register_array(3 downto 0); -- WITHOUT DEBUG'S, WILL BE UUUUUUUU
  
  signal clk, reset, wr : std_logic := '0';
  
  constant clk_period : time := 10 ns;


begin

  -- Connect DUT
 	--CLOCK : CLOCK_PORTS port map(clk);
    --REGISTERS : PACK_REGISTERS_PORTS port map(clk, reset, wr, addr, data, q);
 	REGISTERS : PACK_REGISTERS_PORTS port map(clk, reset, wr, addr, data);
    
    CLOCK_P : process
    begin
    	clk <= '0'; wait for clk_period/2;
    	clk <= '1'; wait for clk_period/2;
    
    end process CLOCK_P;
    
	
 
  ESTIMULOS : process
  begin
    --RESETANDO
    reset <= '1';
    wait for clk_period *2;
    reset <= '0';
    wait for clk_period;
    
    
    --ESCREVENDO EM Q_0
    wr <= '1';
    addr <= "00";
    data <= "10001000";
    
    wait until rising_edge(clk);
    
    report "Primeira escrtia:      " & "q's: " & std_logic_vector'image(q(0)) & std_logic_vector'image(q(1)) & std_logic_vector'image(q(2)) & std_logic_vector'image(q(3)) & "<===>  data: " & std_logic_vector'image(data);
    
    
    --ESCREVENDO EM Q_1
    data <= "00011000";
    wr <= '1';
    addr <= "01";
    
    wait until rising_edge(clk);
    
    report "Segunda escrtia:      " & "q's: " & std_logic_vector'image(q(0)) & std_logic_vector'image(q(1)) & std_logic_vector'image(q(2)) & std_logic_vector'image(q(3)) & "<===>  data: " & std_logic_vector'image(data);
    
    
    --ESCREVENDO EM Q_2
    data <= "00100100";
    wr <= '1';
    addr <= "10";
    
    wait until rising_edge(clk);
    
    report "Terceira escrtia:      " & "q's: " & std_logic_vector'image(q(0)) & std_logic_vector'image(q(1)) & std_logic_vector'image(q(2)) & std_logic_vector'image(q(3)) & "<===>  data: " & std_logic_vector'image(data);

    
    
    --LENDO EM Q_0
    wr <= '0';
    data <= "ZZZZZZZZ";
    addr <= "00";
    
    wait until rising_edge(clk);
    
    report "Primeira Leitura:      " & "q's: " & std_logic_vector'image(q(0)) & std_logic_vector'image(q(1)) & std_logic_vector'image(q(2)) & std_logic_vector'image(q(3)) & "<===>  data: " & std_logic_vector'image(data);
    
    
    
    --LENDO EM Q_1
    wr <= '0';
    data <= "ZZZZZZZZ";
    addr <= "01";
    
    wait until rising_edge(clk);
    
    report "Segunda Leitura:      " & "q's: " & std_logic_vector'image(q(0)) & std_logic_vector'image(q(1)) & std_logic_vector'image(q(2)) & std_logic_vector'image(q(3)) & "<===>  data: " & std_logic_vector'image(data);
    
    
    
    
    --LENDO EM Q_2
    wr <= '0';
    data <= "ZZZZZZZZ";
    addr <= "10";
    
    wait until rising_edge(clk);
    
    report "Terceira Leitura:      " & "q's: " & std_logic_vector'image(q(0)) & std_logic_vector'image(q(1)) & std_logic_vector'image(q(2)) & std_logic_vector'image(q(3)) & "<===>  data: " & std_logic_vector'image(data);
    
    
    
    --SOBRESCREVENDO EM Q_1
    wr <= '1';
    data <= "11111111";
    addr <= "01";
    
    wait until rising_edge(clk);
    
    report "Terceira Leitura:      " & "q's: " & std_logic_vector'image(q(0)) & std_logic_vector'image(q(1)) & std_logic_vector'image(q(2)) & std_logic_vector'image(q(3)) & "<===>  data: " & std_logic_vector'image(data);
    
    
    --LENDO EM Q_1
    wr <= '0';
    data <= "ZZZZZZZZ";
    addr <= "01";
    
    wait until rising_edge(clk);
    
    report "Segunda Leitura:      " & "q's: " & std_logic_vector'image(q(0)) & std_logic_vector'image(q(1)) & std_logic_vector'image(q(2)) & std_logic_vector'image(q(3)) & "<===>  data: " & std_logic_vector'image(data);
    
    
    
    wait;
  end process ESTIMULOS;
end tbREG;

