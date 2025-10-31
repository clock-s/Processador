library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use ieee.numeric_std.all;

-- ROM que lê de arquivo .bin gerado pelo compilador
-- Formato: cada linha contém 2 caracteres hex (00-FF)

entity archive is port(
        data : out std_logic_vector (7 downto 0);
        addr : in integer range 0 to 255
    );
end archive;

architecture archive_function of archive is

    type memory_array is array (0 to 255) of std_logic_vector (7 downto 0);
    signal memory : memory_array := (others => (others => '0'));

    -- IMPORTANTE: Este arquivo deve estar na mesma pasta do testbench
    -- ou no caminho de execução do simulador
    file prog_file : text open read_mode is "teste.bin";

begin

    process
        variable l : line;
        variable temp_slv : std_logic_vector(7 downto 0);
        variable i : integer := 0;
    begin
        -- Lê cada linha do arquivo .bin
        -- Cada linha deve conter exatamente 2 caracteres hexadecimais (00-FF)
        while not endfile(prog_file) loop
            readline(prog_file, l);
            
            -- Verifica se a linha não está vazia
            if l'length > 0 then
                hread(l, temp_slv);  -- Lê formato hexadecimal (2 chars ASCII -> 1 byte)
                memory(i) <= temp_slv;
                
                -- Debug: mostra o byte lido em decimal e hex
                report "ROM[" & integer'image(i) & "] = " & 
                       integer'image(to_integer(unsigned(temp_slv))) & 
                       " (0x" & integer'image(to_integer(unsigned(temp_slv))) & ")";
                
                i := i + 1;
            end if;
        end loop;
        
        report "ROM carregada com " & integer'image(i) & " bytes do arquivo teste.bin";
        
        wait;  -- Termina o processo de inicialização
    end process;

    -- Saída assíncrona
    data <= memory(addr);

end archive_function;
