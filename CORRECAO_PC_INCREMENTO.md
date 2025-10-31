# Correção: Incremento de PC após Leitura de Imediatos

## Problema Identificado

Após corrigir os bugs de timing, apareceu outro problema: **PC não estava sendo incrementado** após ler valores imediatos!

### Execução com Bug:
```
PC=0: FETCH → DECODE: inst=48 (0x30 = LOAD r1,)
      DECODE incrementa PC para 1
      
PC=1: GET_VALUE1 lê valor 2 (0x02)
      GET_VALUE1 NÃO incrementa PC!  ❌
      
PC=1: FETCH lê endereço 1 novamente!
      DECODE: inst=3 (0x02 em decimal)  ❌ ERRADO!
      
Deveria ter lido endereço 2 (0x35 = LOAD r2,)
```

### Consequência:
O processador pulava instruções ou relia valores imediatos como opcodes!

## Causa Raiz

No estado GET_VALUE1, após ler um valor imediato da ROM, o código só incrementava PC quando `needs_value2='1'` (caso de duas imediatas consecutivas).

Quando havia apenas **um** valor imediato (`needs_value2='0'`), o PC **não era incrementado**, fazendo o próximo FETCH reler o mesmo byte!

### Fluxo com Bug:
```
DECODE (0x30 = LOAD r1, imm):
  - PC = 0
  - PC <= PC + 1  (PC = 1, aponta para valor imediato)
  - Vai para GET_VALUE1

GET_VALUE1 (fase 1):
  - rom_addr <= PC (1)
  - waiting_rom <= '1'

GET_VALUE1 (fase 2):
  - operand1 <= instruction (0x02)
  - needs_value2 = '0'
  - PC NÃO É INCREMENTADO!  ❌
  - Vai para EXECUTE

FETCH:
  - rom_addr <= PC (ainda 1!)  ❌
  - Lê 0x02 novamente
```

## Solução Implementada

**Sempre incrementar PC** após ler um valor imediato em GET_VALUE1, independente de needs_value2!

### Código Corrigido:
```vhdl
-- ROM updated, now read the value
operand1 <= instruction;
needs_value1 <= '0';
waiting_rom <= '0';
report "GET_VALUE1: Lendo valor imediato " & integer'image(...);

-- ✅ SEMPRE incrementa PC após ler imediato
if PC < 255 then
    PC <= PC + 1;  -- Move past the immediate value we just read
end if;

if needs_value2 = '1' then
    -- Precisa ler outro imediato
    if PC < 254 then
        rom_addr <= PC + 1;  -- Aponta para próximo imediato
        current_state <= GET_VALUE2;
    else
        current_state <= HALT;
    end if;
else
    -- Não precisa de value2
    current_state <= EXECUTE;
end if;
```

### Novo Fluxo (Correto):
```
DECODE (0x30 = LOAD r1, imm):
  - PC = 0
  - PC <= 1  (aponta para valor imediato)
  - Vai para GET_VALUE1

GET_VALUE1 (fase 1):
  - rom_addr <= 1
  - waiting_rom <= '1'

GET_VALUE1 (fase 2):
  - operand1 <= 0x02
  - PC <= 2  ✅ INCREMENTADO!
  - Vai para EXECUTE

EXECUTE:
  - Executa LOAD r1, 2

FETCH:
  - rom_addr <= PC (2)  ✅ CORRETO!
  - Lê 0x35 (LOAD r2,)  ✅
```

## Resultado Esperado

Agora a sequência de PCs deve ser:
```
PC=0: LOAD r1, 2   (0x30 0x02)  → PC incrementa para 2
PC=2: LOAD r2, 3   (0x35 0x03)  → PC incrementa para 4
PC=4: LOAD x, r1   (0x10)       → PC incrementa para 5
PC=5: LOAD y, r2   (0x15)       → PC incrementa para 6
PC=6: SUM x, y     (0x61)       → PC incrementa para 7
PC=7: NOP          (0x00)       → HALT
```

## Lição Aprendida

Em processadores com instruções de **tamanho variável**, é **crítico** incrementar PC corretamente após ler cada byte:

1. **DECODE**: Incrementa PC para apontar para primeiro byte extra (se houver)
2. **GET_VALUE1**: Incrementa PC para apontar para segundo byte extra (se houver) ou próxima instrução
3. **GET_VALUE2**: Incrementa PC para próxima instrução (se houver terceiro byte)

**Nunca esquecer** de incrementar PC após consumir um byte, mesmo que não precise de mais bytes! 🎯
