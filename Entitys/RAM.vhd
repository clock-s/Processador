library IEEE;
use ieee.std_logic_1164.all;
use work.PACK_ARRAY.all;
use work.functions.all;




entity RAM is port(
	clock      : in std_logic;
    reset 	   : in std_logic;
    write_read : in std_logic; -- 0 to read and 1 to write
    
    addr  : in std_logic_vector (7 downto 0) := "00000000";
    
    data : inout std_logic_vector (7 downto 0)
            
);
end RAM;


architecture RAM_ARCH of RAM is

	constant RAM_SIZE : integer := 256;

    signal write_enable : std_logic_vector (RAM_SIZE - 1 downto 0);
    signal read_enable : std_logic_vector (RAM_SIZE-1 downto 0);
    
    component U_REGISTER_PORT is port(
      clock      : in std_logic;
      reset 	   : in std_logic;
      write_enable : in std_logic; 
      read_enable : in std_logic;

      gate : inout std_logic_vector (7 downto 0)

    );
    end component;

    
begin

    -- DECODER TO CHOOSE WHICH REGISTER WILL ACT
    DECODER : process (addr, write_read)
    begin
    	write_enable <= (others => '0');
        read_enable <= (others => '0');
       
        if write_read = '1' then
            write_enable(to_integer(addr)) <= '1';
        
        elsif write_read = '0' then
            read_enable(to_integer(addr)) <= '1';
            
        end if;
        
    end process DECODER;
    
    
    RAM_MEM : for i in 0 to RAM_SIZE -1 generate
    	R_I : U_REGISTER_PORT port map (clock, reset, write_enable(i), read_enable(i), data);
    end generate RAM_MEM;


end RAM_ARCH;
