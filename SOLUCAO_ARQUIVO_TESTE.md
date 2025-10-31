# SOLUÇÃO: Erro "Cannot open file teste.bin"

## Problema

```
RUNTIME: Fatal Error: RUNTIME_0048 archive.vhd (28): Cannot open file "teste.bin"
```

O EDA Playground não permite ler arquivos externos durante a simulação.

## Solução

Use o arquivo **archive_eda.vhd** que tem o programa embutido no código.

## Passo a Passo

### 1. No EDA Playground, DELETE o arquivo `archive.vhd` antigo

### 2. Adicione o novo arquivo `archive_eda.vhd`

Copie este conteúdo:

```vhdl
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
    
    -- Programa de teste embutido
    -- LOAD r1,2     -> 0x30 0x02
    -- LOAD r2,3     -> 0x35 0x03
    -- LOAD x,r1     -> 0x10
    -- LOAD y,r2     -> 0x15
    -- SUM x,y       -> 0x61
    -- NOP           -> 0x00
    constant ROM : memory_array := (
        0 => x"30",   -- LOAD r1, (next byte)
        1 => x"02",   -- value 2
        2 => x"35",   -- LOAD r2, (next byte)
        3 => x"03",   -- value 3
        4 => x"10",   -- LOAD x, r1
        5 => x"15",   -- LOAD y, r2
        6 => x"61",   -- SUM x, y
        7 => x"00",   -- NOP
        others => x"00"
    );
    
begin
    data <= ROM(addr);
end ROM_ARCH;
```

### 3. Renomeie no EDA Playground

- O arquivo deve se chamar **`archive.vhd`** (sem o _eda)
- Ou renomeie o arquivo local e carregue como `archive.vhd`

### 4. Rode novamente

Clique em "Run" e agora deve funcionar!

## Resultado Esperado

Após a correção, você verá:

```
# KERNEL: === INICIANDO TESTE DO PROCESSADOR (CLOCK INTERNO) ===
# KERNEL: Reset liberado. Processador executando programa...
# KERNEL: PC=0 Estado: FETCH      
# KERNEL: PC=1 Estado: DECODE     
# KERNEL: PC=1 Estado: GET_VALUE1 
# KERNEL: PC=1 Estado: EXECUTE    
# KERNEL: PC=1 Estado: WRITE_BACK 
# KERNEL: PC=1 Estado: FETCH      
# KERNEL: PC=2 Estado: DECODE     
...
# KERNEL: PC=7 Estado: FETCH      
# KERNEL: === TESTE CONCLUIDO ===
```

## Verificação dos Resultados

No waveform (EPWave), você deve ver:

- **r1** (mem_regs[0]) = 0x02
- **r2** (mem_regs[1]) = 0x03
- **x** (math_regs[0]) = 0x05 (resultado de 2+3)
- **y** (math_regs[1]) = 0x03

## Programa Carregado

O programa embutido é:
```assembly
LOAD r1,2;    # Carrega 2 em r1
LOAD r2,3;    # Carrega 3 em r2
LOAD x,r1;    # Copia r1 para x
LOAD y,r2;    # Copia r2 para y
SUM x,y;      # x = x + y (2+3=5)
NOP;          # Fim
```

Bytes na ROM:
```
0x00: 0x30  (LOAD r1,)
0x01: 0x02  (valor 2)
0x02: 0x35  (LOAD r2,)
0x03: 0x03  (valor 3)
0x04: 0x10  (LOAD x,r1)
0x05: 0x15  (LOAD y,r2)
0x06: 0x61  (SUM x,y)
0x07: 0x00  (NOP)
```

## Arquivo Local

O arquivo correto está em:
```
/Users/marcusvinicius/Documents/GitHub/Processador/Entitys/archive_eda.vhd
```

Copie este arquivo para o EDA Playground como `archive.vhd`.
