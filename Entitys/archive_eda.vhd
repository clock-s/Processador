library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity archive is port(
    data : out std_logic_vector (7 downto 0);
    addr : in integer range 0 to 255
);
end archive;

architecture ROM_ARCH of archive is
    type memory_array is array (0 to 255) of std_logic_vector(7 downto 0);
    
    -- Programa de teste completo embutido
    -- Este programa testa varias operacoes da ULA e transferencias entre registradores
    constant ROM : memory_array := (
        -- Teste 1: LOAD e transferencia basica (SUM)
        0 => x"30",   -- LOAD r1, 5
        1 => x"05",
        2 => x"35",   -- LOAD r2, 3
        3 => x"03",
        4 => x"10",   -- LOAD x, r1 (x=5)
        5 => x"15",   -- LOAD y, r2 (y=3)
        6 => x"61",   -- SUM x, y (x=5+3=8)
        
        -- Teste 2: SUB (subtracao)
        7 => x"3A",   -- LOAD r3, 10
        8 => x"0A",
        9 => x"18",   -- LOAD x, r3 (x=10)
        10 => x"B5",  -- SUB y, x (y=3-10=-7 ou 249 em unsigned)
        
        -- Teste 3: MULT (multiplicacao)
        11 => x"30",  -- LOAD r1, 4
        12 => x"04",
        13 => x"35",  -- LOAD r2, 3
        14 => x"03",
        15 => x"14",  -- LOAD x, r2 (x=3)
        16 => x"10",  -- LOAD y, r1 (y=4)
        17 => x"74",  -- MULT x, y (x=3*4=12)
        
        -- Teste 4: AND (operacao logica)
        18 => x"30",  -- LOAD r1, 15 (0x0F = 0b00001111)
        19 => x"0F",
        20 => x"35",  -- LOAD r2, 51 (0x33 = 0b00110011)
        21 => x"33",
        22 => x"10",  -- LOAD x, r1 (x=15)
        23 => x"15",  -- LOAD y, r2 (y=51)
        24 => x"85",  -- AND x, y (x=15&51=3 = 0b00000011)
        
        -- Teste 5: OR (operacao logica)
        25 => x"30",  -- LOAD r1, 12 (0x0C = 0b00001100)
        26 => x"0C",
        27 => x"35",  -- LOAD r2, 3  (0x03 = 0b00000011)
        28 => x"03",
        29 => x"10",  -- LOAD x, r1 (x=12)
        30 => x"15",  -- LOAD y, r2 (y=3)
        31 => x"99",  -- OR x, y (x=12|3=15 = 0b00001111)
        
        -- Teste 6: XOR (operacao logica)
        32 => x"30",  -- LOAD r1, 15 (0x0F)
        33 => x"0F",
        34 => x"35",  -- LOAD r2, 10 (0x0A)
        35 => x"0A",
        36 => x"10",  -- LOAD x, r1 (x=15)
        37 => x"15",  -- LOAD y, r2 (y=10)
        38 => x"A9",  -- XOR x, y (x=15^10=5)
        
        -- Teste 7: NOT (inversao)
        39 => x"30",  -- LOAD r1, 170 (0xAA = 0b10101010)
        40 => x"AA",
        41 => x"10",  -- LOAD x, r1 (x=170)
        42 => x"8D",  -- NOT x (x=~170=85 = 0x55 = 0b01010101)
        
        -- Teste 8: Transferencia entre registradores (mem <- math)
        43 => x"30",  -- LOAD r1, 99
        44 => x"63",
        45 => x"10",  -- LOAD x, r1 (x=99)
        46 => x"20",  -- LOAD r1, x (r1=x=99)
        
        -- Teste 9: SUM com valores imediatos
        47 => x"6E",  -- SUM V1, V2 (x = next + next)
        48 => x"0A",  -- V1 = 10
        49 => x"14",  -- V2 = 20 (x=10+20=30)
        
        -- Teste 10: MULT com valor imediato
        50 => x"30",  -- LOAD r1, 5
        51 => x"05",
        52 => x"10",  -- LOAD x, r1 (x=5)
        53 => x"7D",  -- MULT x, V (x = x * next)
        54 => x"06",  -- V = 6 (x=5*6=30)
        
        -- Teste 11: SUB com registrador e imediato
        55 => x"3A",  -- LOAD r3, 50
        56 => x"32",
        57 => x"18",  -- LOAD x, r3 (x=50)
        58 => x"BD",  -- SUB x, V (x = x - next)
        59 => x"0F",  -- V = 15 (x=50-15=35)
        
        -- Teste 12: Verificar copia entre memory registers
        60 => x"30",  -- LOAD r1, 77
        61 => x"4D",
        62 => x"31",  -- LOAD r1, r2 (0x31: dest=00=r1, src=01=r2, copia r2→r1)
        63 => x"36",  -- LOAD r2, r1 (0x36: dest=01=r2, src=10=r1+1, copia r1→r2)
        
        -- Final: NOP para encerrar
        64 => x"00",  -- NOP (halt when PC > 64)
        
        others => x"00"
    );
    
begin
    data <= ROM(addr);
end ROM_ARCH;
