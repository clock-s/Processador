# Lógica do Program Counter (PC)

## Problema Identificado

O PC não estava sendo incrementado corretamente quando instruções tinham valores imediatos. O problema era que:
- No DECODE, incrementávamos PC
- No GET_VALUE1/GET_VALUE2, incrementávamos PC novamente
- Resultado: **PC pulava bytes** e não lia os valores imediatos corretamente

## Solução Implementada

### Regra Principal
**O PC sempre é incrementado no DECODE** para apontar para o próximo byte (que pode ser outra instrução OU um valor imediato).

### Fluxo Correto

#### Exemplo 1: LOAD r1, 2 (0x30 0x02)

```
Endereço | Conteúdo | Estado       | PC | rom_addr | Action
---------|----------|--------------|----|-----------|-----------------------
0x00     | 0x30     | FETCH        | 0  | 0         | Lê instrução 0x30
0x00     | 0x30     | DECODE       | 0  | 0         | PC <= 1, needs_value1='1'
0x01     | 0x02     | GET_VALUE1   | 1  | 1         | Lê valor 0x02, operand1=0x02
0x01     | 0x02     | EXECUTE      | 1  | 1         | mem_regs[0] = 0x02
0x01     | 0x02     | FETCH        | 1  | 1         | rom_addr <= PC (1)
0x01     | 0x02     | DECODE       | 1  | 1         | PC <= 2
```

**Resultado:** Próxima instrução será lida do endereço 0x02 ✅

#### Exemplo 2: LOAD x, r1 (0x10)

```
Endereço | Conteúdo | Estado       | PC | rom_addr | Action
---------|----------|--------------|----|-----------|-----------------------
0x02     | 0x10     | FETCH        | 2  | 2         | Lê instrução 0x10
0x02     | 0x10     | DECODE       | 2  | 2         | PC <= 3, needs_value1='0'
0x02     | 0x10     | EXECUTE      | 3  | 2         | math_regs[0] = mem_regs[0]
0x03     | ???      | FETCH        | 3  | 3         | rom_addr <= PC (3)
```

**Resultado:** Próxima instrução será lida do endereço 0x03 ✅

#### Exemplo 3: SUM V1, V2 (0x6E 0x05 0x03) - Dois valores imediatos

```
Endereço | Conteúdo | Estado       | PC | rom_addr | Action
---------|----------|--------------|----|-----------|-----------------------
0x10     | 0x6E     | FETCH        | 16 | 16        | Lê instrução 0x6E
0x10     | 0x6E     | DECODE       | 16 | 16        | PC <= 17, needs_value1='1', needs_value2='1'
0x11     | 0x05     | GET_VALUE1   | 17 | 17        | operand1=0x05, PC <= 18, rom_addr <= 18
0x12     | 0x03     | GET_VALUE2   | 18 | 18        | operand2=0x03
0x12     | 0x03     | EXECUTE      | 18 | 18        | ULA: 0x05 + 0x03
0x12     | 0x03     | WRITE_BACK   | 18 | 18        | math_regs[0] = 0x08
0x12     | 0x03     | FETCH        | 18 | 18        | rom_addr <= PC (18)
0x12     | 0x03     | DECODE       | 18 | 18        | PC <= 19
```

**Resultado:** Próxima instrução será lida do endereço 0x13 (19) ✅

#### Exemplo 4: SUM x, y (0x61) - Registradores

```
Endereço | Conteúdo | Estado       | PC | rom_addr | Action
---------|----------|--------------|----|-----------|-----------------------
0x06     | 0x61     | FETCH        | 6  | 6         | Lê instrução 0x61
0x06     | 0x61     | DECODE       | 6  | 6         | PC <= 7, needs_value1='0', needs_value2='0'
0x06     | 0x61     | GET_VALUE1   | 7  | 6         | operand1=math_regs[0], operand2=math_regs[1]
0x06     | 0x61     | EXECUTE      | 7  | 6         | ULA: math_regs[0] + math_regs[1]
0x06     | 0x61     | WRITE_BACK   | 7  | 6         | math_regs[0] = resultado
0x07     | ???      | FETCH        | 7  | 7         | rom_addr <= PC (7)
```

**Resultado:** Próxima instrução será lida do endereço 0x07 ✅

## Regras de Incremento do PC

### No Estado DECODE
```vhdl
PC <= PC + 1;  -- SEMPRE incrementa
```

### No Estado GET_VALUE1
```vhdl
if needs_value1 = '1' then
    -- PC já aponta para o valor imediato (incrementado no DECODE)
    -- Não incrementa PC aqui!
    if needs_value2 = '1' then
        -- Vai precisar de outro valor imediato
        PC <= PC + 1;  -- Incrementa para próximo byte
        rom_addr <= PC + 1;
    end if;
else
    -- Lendo de registradores, não precisa incrementar PC
    if needs_value2 = '1' then
        rom_addr <= PC;  -- PC já aponta para valor imediato
    end if;
end if;
```

### No Estado GET_VALUE2
```vhdl
-- PC já foi incrementado no GET_VALUE1
-- Não incrementa aqui!
```

## Resumo

| Situação | Bytes | PC no DECODE | PC após GET_VALUE1 | PC após EXECUTE |
|----------|-------|--------------|-------------------|-----------------|
| LOAD r1,2 (0x30 0x02) | 2 | 0→1 | 1 | 1 |
| LOAD x,r1 (0x10) | 1 | 2→3 | 3 | 3 |
| SUM x,y (0x61) | 1 | 6→7 | 7 | 7 |
| SUM x,V (0x6D 0x05) | 2 | 10→11 | 11 | 11 |
| SUM V1,V2 (0x6E 0x05 0x03) | 3 | 15→16 | 17 | 18 |

## Verificação

Para testar se está correto, o programa:
```assembly
LOAD r1,2;    # PC: 0 → 1 (após DECODE) → próximo em 2
LOAD r2,3;    # PC: 2 → 3 (após DECODE) → próximo em 4
LOAD x,r1;    # PC: 4 → 5 (após DECODE) → próximo em 5
LOAD y,r2;    # PC: 5 → 6 (após DECODE) → próximo em 6
SUM x,y;      # PC: 6 → 7 (após DECODE) → próximo em 7
NOP;          # PC: 7 → 8 (após DECODE) → próximo em 8
```

Deve ter os seguintes bytes na ROM:
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

E o PC deve seguir: 0→1→2→3→4→5→6→7→8
