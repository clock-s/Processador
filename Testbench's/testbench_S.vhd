-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity testbench_S is
-- empty
end testbench_S; 

architecture tb_S of testbench_S is


component  L_SHIFT_PORTS is port (
	output: out std_logic_vector (7 downto 0);
    carry : out std_logic;
    flag : out std_logic;
    
    input : in std_logic_vector (7 downto 0);
    num_shift : in std_logic_vector (2 downto 0);
    clock : in std_logic;
    
    reset : in std_logic

);
end component;

component R_SHIFT_PORTS is port (
	output: out std_logic_vector (7 downto 0);
    carry : out std_logic;
    flag : out std_logic;
    
    
    input : in std_logic_vector (7 downto 0);
    num_shift : in std_logic_vector (2 downto 0);
    clock : in std_logic;
	reset : in std_logic
);
end component;

signal input, output_L, output_R : std_logic_vector(7 downto 0);
signal num_shift : std_logic_vector(2 downto 0);
signal clk, carry_R, carry_L, flag_L, flag_R, reset : std_logic;
constant clk_period : time := 10 ns;


begin

  -- Connect DUT
  L_SHIFT:  L_SHIFT_PORTS port map(output_L, carry_L, flag_L, input, num_shift, clk, reset);
  R_SHIFT:  R_SHIFT_PORTS port map(output_R, carry_R, flag_R, input, num_shift, clk, reset);
	
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
  	
    input     <= "01010101";
    num_shift <= "011";
    
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
    
    
  	report std_logic_vector'image(output_L);
    report std_logic_vector'image(output_R);
    --report std_logic'image(carry);

    
    wait;
  end process;
end tb_S;

