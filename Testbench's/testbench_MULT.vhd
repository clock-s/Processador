-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench_MULT is
-- empty
end testbench_MULT;

architecture tb_MULT of testbench_MULT is


component MULT_PORTS is port (
	output : out std_logic_vector (7 downto 0);
    carry : out std_logic;
    flag : out std_logic;
    
	input_A : in std_logic_vector (7 downto 0);
    input_B : in std_logic_vector (7 downto 0);
    clock : in std_logic;
    reset : in std_logic
); 
end component;


signal A, B, output : std_logic_vector(7 downto 0);
signal clk, reset, flag, carry : std_logic;

constant clk_period : time := 10 ns;

begin

  -- Connect DUT
  MULT:  MULT_PORTS port map(output, carry, flag, A, B, clk, reset);
	
 -- CLOCK_P : process
   -- begin
    --	clk <= '0'; wait for clk_period/2;
    	--clk <= '1'; wait for clk_period/2;
    
    --end process CLOCK_P;
    
  process
  begin
  
  	reset <= '0'; wait for 1 ns;
    reset <= '1'; wait for 1 ns;
    reset <= '0'; wait for 1 ns;
  	
    A <= "11111011";
    B <= "11111011";
    
    clk <= '0'; wait for clk_period/2;
    clk <= '1'; wait for clk_period/2;
    clk <= '0'; wait for clk_period/2;
    clk <= '1'; wait for clk_period/2;
	clk <= '0'; wait for clk_period/2;
    clk <= '1'; wait for clk_period/2;
	clk <= '0'; wait for clk_period/2;
    clk <= '1'; wait for clk_period/2;
	clk <= '0'; wait for clk_period/2;
    clk <= '1'; wait for clk_period/2;
	clk <= '0'; wait for clk_period/2;
    clk <= '1'; wait for clk_period/2;
	clk <= '0'; wait for clk_period/2;
    clk <= '1'; wait for clk_period/2;
    clk <= '0'; wait for clk_period/2;
    clk <= '1'; wait for clk_period/2;
    clk <= '0'; wait for clk_period/2;
    clk <= '1'; wait for clk_period/2;


	--wait for 10*clk_period;
    
    
  	report std_logic_vector'image(output);
    report std_logic'image(carry);
    report std_logic'image(flag);

    
    wait;
  end process;
end tb_MULT;

