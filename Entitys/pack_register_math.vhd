library ieee;
use ieee.std_logic_1164.all;

-- PACK_REGISTER_MATH: Banco de registradores matemáticos (x, y, z, w)
entity PACK_REGISTER_MATH is port(
    clock : in std_logic;
    reset : in std_logic;
    
    -- Interface de escrita
    write_enable : in std_logic;
    write_addr : in integer range 0 to 3;
    write_data : in std_logic_vector(7 downto 0);
    
    -- Interface de leitura (2 portas para ler simultaneamente)
    read_addr_a : in integer range 0 to 3;
    read_addr_b : in integer range 0 to 3;
    read_data_a : out std_logic_vector(7 downto 0);
    read_data_b : out std_logic_vector(7 downto 0)
);
end PACK_REGISTER_MATH;

architecture PACK_REGISTER_MATH_ARCH of PACK_REGISTER_MATH is
    type reg_array is array (0 to 3) of std_logic_vector(7 downto 0);
    signal registers : reg_array := (others => (others => '0'));
begin
    
    -- Processo de escrita
    WRITE_PROC: process(clock, reset)
    begin
        if reset = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clock) then
            if write_enable = '1' then
                registers(write_addr) <= write_data;
            end if;
        end if;
    end process WRITE_PROC;
    
    -- Leitura assíncrona (combinacional)
    read_data_a <= registers(read_addr_a);
    read_data_b <= registers(read_addr_b);
    
end PACK_REGISTER_MATH_ARCH;
