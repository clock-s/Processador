library IEEE;
use ieee.std_logic_1164.all;
use work.PACK_ARRAY.all;
use work.functions.all;




entity PACK_REGISTERS_PORTS is port(
	clock      : in std_logic;
    reset 	   : in std_logic;
    write_read : in std_logic; -- 0 to read and 1 to write
    
    addr  : in std_logic_vector (1 downto 0) := "00";
    
    data : inout std_logic_vector (7 downto 0);
    
    --debug : out register_array(3 downto 0);
        
);
end PACK_REGISTERS_PORTS;


architecture PACK_REGISTERS of PACK_REGISTERS_PORTS is
    signal write_enable : std_logic_vector (3 downto 0);
    signal read_enable : std_logic_vector (3 downto 0);
    
    component U_REGISTER_PORT is port(
      clock      : in std_logic;
      reset 	   : in std_logic;
      write_enable : in std_logic; 
      read_enable : in std_logic;

      gate : inout std_logic_vector (7 downto 0);
      --debug: out std_logic_vector (7 downto 0);

    );
    end component;

    
begin

    -- DECODER TO CHOOSE WHICH REGISTER WILL ACT
    DECODER : process (addr, write_read)
    begin
    	write_enable <= "0000";
        read_enable <= "0000";
       
        if write_read = '1' then
            write_enable(to_integer(addr)) <= '1';
        
        elsif write_read = '0' then
            read_enable(to_integer(addr)) <= '1';
            
        end if;
        
    end process DECODER;
    
	--LINK DATA INOUT WITH REGISTERS INOUT
    Q_0 : U_REGISTER_PORT port map(clock, reset, write_enable(0), read_enable(0), data);
	--Q_0 : U_REGISTER_PORT port map(clock, reset, write_enable(0), read_enable(0), data, debug(0));
    
	Q_1 : U_REGISTER_PORT port map(clock, reset, write_enable(1), read_enable(1), data);
    --Q_1 : U_REGISTER_PORT port map(clock, reset, write_enable(1), read_enable(1), data, debug(1));
    
    Q_2 : U_REGISTER_PORT port map(clock, reset, write_enable(2), read_enable(2), data);
    --Q_2 : U_REGISTER_PORT port map(clock, reset, write_enable(2), read_enable(2), data, debug(2));
    
	Q_3 : U_REGISTER_PORT port map(clock, reset, write_enable(3), read_enable(3), data);
    --Q_3 : U_REGISTER_PORT port map(clock, reset, write_enable(3), read_enable(3), data, debug(3));


end PACK_REGISTERS;
