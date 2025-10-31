# Correção Crítica: Leitura de Valores Imediatos

## Problema Identificado

O processador estava carregando o **OPCODE** em vez do **VALOR IMEDIATO**!

### Exemplo do Bug:
```
Programa: LOAD r1, 2  (0x30 0x02)

Resultado ERRADO:
- DECODE: inst=48 (0x30)
- GET_VALUE1: Lendo valor imediato 48  ← ERRADO!
- LOAD mem_regs[0] = 48  ← r1 = 48 em vez de 2!
```

## Causa Raiz

No VHDL, quando atualizamos `rom_addr`, o sinal `instruction` da ROM só é atualizado **no próximo ciclo de clock**!

### Fluxo com Bug:
```
Clock 1 (DECODE):
  - instruction = 0x30 (opcode)
  - PC = 0
  - Detecta needs_value1
  - rom_addr <= PC (1)  ← Atualiza endereço
  - Vai para GET_VALUE1

Clock 2 (GET_VALUE1):
  - instruction = AINDA 0x30!  ← ROM não atualizou ainda!
  - operand1 <= instruction (0x30)  ← ERRADO!
```

## Solução Implementada

Adicionado sinal `waiting_rom` para fazer GET_VALUE1 **aguardar 1 ciclo** para ROM atualizar:

### Novo Fluxo:
```
Clock 1 (DECODE):
  - instruction = 0x30
  - PC = 0
  - Detecta needs_value1
  - NÃO atualiza rom_addr aqui
  - Vai para GET_VALUE1

Clock 2 (GET_VALUE1 - primeira vez):
  - waiting_rom = 0
  - rom_addr <= PC (1)  ← Atualiza endereço AGORA
  - waiting_rom <= 1
  - FICA em GET_VALUE1  ← Espera!

Clock 3 (GET_VALUE1 - segunda vez):
  - waiting_rom = 1
  - instruction = 0x02  ← ROM atualizada!
  - operand1 <= instruction (0x02)  ← CORRETO!
  - waiting_rom <= 0
  - Vai para EXECUTE
```

## Mudanças no Código

### 1. Adicionado sinal de controle:
```vhdl
signal waiting_rom : std_logic := '0';
```

### 2. No DECODE (0x3X - LOAD mem_reg <- imm):
**Antes:**
```vhdl
rom_addr <= PC;  -- Atualizava aqui
current_state <= GET_VALUE1;
```

**Depois:**
```vhdl
-- NÃO atualiza rom_addr, deixa GET_VALUE1 fazer
current_state <= GET_VALUE1;
```

### 3. No GET_VALUE1:
**Antes:**
```vhdl
operand1 <= instruction;  -- Lia imediatamente (ERRADO!)
```

**Depois:**
```vhdl
if waiting_rom = '0' then
    rom_addr <= PC;         -- Atualiza endereço
    waiting_rom <= '1';     -- Marca que está esperando
    -- Fica em GET_VALUE1
else
    operand1 <= instruction;  -- Agora ROM está atualizada!
    waiting_rom <= '0';
    -- Continua...
end if;
```

## Resultado Esperado

Agora o programa deve funcionar corretamente:

```
LOAD r1, 2  (0x30 0x02)
- DECODE: inst=48 (0x30)
- GET_VALUE1 (ciclo 1): Aguardando ROM...
- GET_VALUE1 (ciclo 2): Lendo valor imediato 2  ← CORRETO!
- LOAD mem_regs[0] = 2  ← r1 = 2 ✅

LOAD r2, 3  (0x35 0x03)
- DECODE: inst=53 (0x35)
- GET_VALUE1 (ciclo 1): Aguardando ROM...
- GET_VALUE1 (ciclo 2): Lendo valor imediato 3  ← CORRETO!
- LOAD mem_regs[1] = 3  ← r2 = 3 ✅

SUM x, y (0x61)
- x = 2 + 3 = 5 ✅
```

## Próximos Passos

1. Carregar C_UNIT.vhd atualizado no EDA Playground
2. Rodar simulação
3. Verificar que agora r1=2, r2=3, x=5

A correção garante que valores imediatos são lidos corretamente da ROM! 🎯
