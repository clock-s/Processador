library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

entity archive is port(
        data : out std_logic_vector (7 downto 0);
        addr : in integer range 0 to 255
    );
end archive;

architecture archive_function of archive is

    type memory_array is array (0 to 255) of std_logic_vector (7 downto 0);
    signal memory : memory_array := (others => (others => '0'));

    file prog_file : text open read_mode is "teste.bin";

begin

    process
        variable l : line;
        variable temp_slv : std_logic_vector(7 downto 0);
        variable i : integer := 0;
    begin
        -- Lê cada linha e converte o valor hexadecimal para vetor
        while not endfile(prog_file) loop
            readline(prog_file, l);
            hread(l, temp_slv);  -- Lê direto em formato HEXA
            memory(i) <= temp_slv;
            i := i + 1;
        end loop;

        wait;  -- termina o processo
    end process;

    data <= memory(addr);

end archive_function;

