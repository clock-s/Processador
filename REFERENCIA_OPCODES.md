# Referência Rápida de Opcodes - Processador 8-bit

## Formato de Instruções

Cada instrução tem 1 a 3 bytes:
- **Byte 1:** Opcode (define operação e registradores)
- **Byte 2:** Valor imediato 1 (opcional)
- **Byte 3:** Valor imediato 2 (opcional)

---

## Convenções de Nomenclatura

### Registradores de Memória (r1-r4):
- `r1` = mem_regs[0]
- `r2` = mem_regs[1]
- `r3` = mem_regs[2]
- `r4` = mem_regs[3]

### Registradores Matemáticos (x,y,z,w):
- `x` = math_regs[0]
- `y` = math_regs[1]
- `z` = math_regs[2]
- `w` = math_regs[3]

---

## Instruções de Transferência de Dados

### LOAD mem_reg ← valor imediato (0x3X)
**Formato:** `0x3[dest][dest]` `[valor]`  
**Exemplo:** `0x30 0x05` = LOAD r1, 5

| Opcode | Instrução | Descrição |
|--------|-----------|-----------|
| 0x30   | LOAD r1, V | r1 = próximo byte |
| 0x35   | LOAD r2, V | r2 = próximo byte |
| 0x3A   | LOAD r3, V | r3 = próximo byte |
| 0x3F   | LOAD r4, V | r4 = próximo byte |

### LOAD math_reg ← mem_reg (0x1X)
**Formato:** `0x1[dest][src]`  
**Exemplo:** `0x10` = LOAD x, r1

| Opcode | Instrução | Descrição |
|--------|-----------|-----------|
| 0x10   | LOAD x, r1 | x = r1 |
| 0x14   | LOAD x, r2 | x = r2 |
| 0x15   | LOAD y, r2 | y = r2 |
| 0x18   | LOAD x, r3 | x = r3 |
| 0x1C   | LOAD x, r4 | x = r4 |

### LOAD mem_reg ← math_reg (0x2X)
**Formato:** `0x2[src][dest]`  
**Exemplo:** `0x20` = LOAD r1, x

| Opcode | Instrução | Descrição |
|--------|-----------|-----------|
| 0x20   | LOAD r1, x | r1 = x |
| 0x25   | LOAD r2, y | r2 = y |
| 0x2A   | LOAD r3, z | r3 = z |
| 0x2F   | LOAD r4, w | r4 = w |

### LOAD mem_reg ← mem_reg (0x3X)
**Formato:** `0x3[dest][src]` (quando dest ≠ src)  
**Exemplo:** `0x36` = LOAD r2, r1

| Opcode | Instrução | Descrição |
|--------|-----------|-----------|
| 0x31   | LOAD r1, r1 | r1 = r1 (autocopia) |
| 0x36   | LOAD r2, r1 | r2 = r1 |
| 0x34   | LOAD r1, r2 | r1 = r2 |

---

## Operações Aritméticas

### SOMA (0x6X)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0x61   | SUM x, y  | x = x + y | 1 |
| 0x64   | SUM x, z  | x = x + z | 1 |
| 0x65   | SUM y, z  | y = y + z | 1 |
| 0x6D   | SUM x, V  | x = x + próximo byte | 2 |
| 0x6E   | SUM V1, V2| x = V1 + V2 | 3 |

**Exemplo 3 bytes:**
```
0x6E 0x0A 0x14  = SUM 10, 20  → x = 30
```

### SUBTRAÇÃO (0xBX)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0xB5   | SUB y, x  | y = y - x | 1 |
| 0xB9   | SUB z, x  | z = z - x | 1 |
| 0xBD   | SUB x, V  | x = x - próximo byte | 2 |
| 0xBE   | SUB V1, V2| x = V1 - V2 | 3 |

**Exemplo:**
```
0xBD 0x0F  = SUB x, 15  → x = x - 15
```

### MULTIPLICAÇÃO (0x7X)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0x74   | MULT x, y | x = x * y | 1 |
| 0x78   | MULT x, z | x = x * z | 1 |
| 0x7D   | MULT x, V | x = x * próximo byte | 2 |
| 0x7E   | MULT V1, V2| x = V1 * V2 | 3 |

**Exemplo:**
```
0x7D 0x06  = MULT x, 6  → x = x * 6
```

### DIVISÃO (0xCX)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0xCC   | DIV x, y  | x = x / y | 1 |
| 0xCD   | DIV x, V  | x = x / próximo byte | 2 |

### MÓDULO (0xDX)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0xDC   | MOD x, y  | x = x % y | 1 |
| 0xDD   | MOD x, V  | x = x % próximo byte | 2 |

---

## Operações Lógicas

### AND (0x8X)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0x85   | AND x, y  | x = x & y | 1 |
| 0x89   | AND x, z  | x = x & z | 1 |
| 0x8D   | AND x, V  | x = x & próximo byte | 2 |
| 0x8E   | AND V1, V2| x = V1 & V2 | 3 |

### OR (0x9X)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0x99   | OR x, y   | x = x \| y | 1 |
| 0x9D   | OR x, V   | x = x \| próximo byte | 2 |
| 0x9E   | OR V1, V2 | x = V1 \| V2 | 3 |

### XOR (0xAX)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0xA9   | XOR x, y  | x = x ^ y | 1 |
| 0xAD   | XOR x, V  | x = x ^ próximo byte | 2 |
| 0xAE   | XOR V1, V2| x = V1 ^ V2 | 3 |

### NOT (0x8X)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0x8D   | NOT x     | x = ~x    | 1 |
| 0x89   | NOT V     | x = ~próximo byte | 2 |

---

## Operações de Shift

### LEFT SHIFT (0xCX, 0xDX, 0xFX)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0xC0   | LSHIFT x, V | x = x << próximo byte | 2 |
| 0xF4   | LSHIFT x, y | x = x << y | 1 |

### RIGHT SHIFT (0x5X, 0x9X, 0xAX)

| Opcode | Instrução | Descrição | Bytes |
|--------|-----------|-----------|-------|
| 0x50   | RSHIFT wx, V | wx = wx >> próximo byte | 2 |
| 0x94   | RSHIFT x, y  | x = x >> y | 1 |

---

## Instruções de Controle

### NOP (0x00)
**Opcode:** `0x00`  
**Descrição:** Nenhuma operação (halt quando PC > tamanho do programa)

### RES (0x01)
**Opcode:** `0x01`  
**Descrição:** Reset dos registradores (através do sinal global reset)

### RESF (0x02)
**Opcode:** `0x02`  
**Descrição:** Reset das flags (Z, N, C, P, K = 0)

### JUMP (0x5X)
**Formato:** `0x5[cond]` `[endereço]` `[flags]` (opcional)  
**Exemplo:** `0x54 0x10` = JUMP 16 (incondicional)

---

## Formato de Opcode (Estrutura de Bits)

```
Bit:  7  6  5  4  3  2  1  0
      [  Tipo  ][Dest/Op][Src]

Tipo (bits 7-4): Define a categoria da operação
Dest (bits 3-2): Registrador destino (0=x/r1, 1=y/r2, 2=z/r3, 3=w/r4)
Src  (bits 1-0): Registrador fonte ou modo
```

---

## Exemplos de Programas

### Exemplo 1: Calcular (5 + 3) * 2
```assembly
0x30 0x05    ; LOAD r1, 5
0x35 0x03    ; LOAD r2, 3
0x10         ; LOAD x, r1      (x=5)
0x15         ; LOAD y, r2      (y=3)
0x61         ; SUM x, y        (x=8)
0x7D 0x02    ; MULT x, 2       (x=16)
```

### Exemplo 2: Operação Lógica (15 AND 51)
```assembly
0x30 0x0F    ; LOAD r1, 15
0x35 0x33    ; LOAD r2, 51
0x10         ; LOAD x, r1
0x15         ; LOAD y, r2
0x85         ; AND x, y        (x=3)
```

### Exemplo 3: Divisão e Módulo
```assembly
0x30 0x0A    ; LOAD r1, 10
0x35 0x03    ; LOAD r2, 3
0x10         ; LOAD x, r1      (x=10)
0x15         ; LOAD y, r2      (y=3)
0xCC         ; DIV x, y        (x=3)
0x10         ; LOAD x, r1      (x=10 novamente)
0xDC         ; MOD x, y        (x=1)
```

---

## Flags de Estado

Após operações, flags são atualizadas:

| Flag | Bit | Descrição |
|------|-----|-----------|
| Z    | 0   | Zero: resultado = 0 |
| N    | 1   | Negative: bit 7 = 1 |
| C    | 2   | Carry: overflow da operação |
| P    | 3   | Parity: número par de bits 1 |
| K    | 7   | Overflow da ULA |

---

## Notas Importantes

1. **Todas as operações matemáticas/lógicas escrevem em math_regs (x,y,z,w)**
2. **Valores imediatos podem ter 1 ou 2 bytes extras**
3. **PC incrementa automaticamente após ler cada byte**
4. **HALT ocorre quando PC > tamanho do programa em um NOP**
5. **Componentes síncronos precisam de 1 ciclo para atualizar**

---

## Quick Reference Card

```
┌─────────────────────────────────────────┐
│  LOAD: 0x3X (imm), 0x1X (m→m), 0x2X (m→r)
│  SUM:  0x6X                           │
│  SUB:  0xBX                           │
│  MULT: 0x7X                           │
│  DIV:  0xCX                           │
│  MOD:  0xDX                           │
│  AND:  0x8X                           │
│  OR:   0x9X                           │
│  XOR:  0xAX                           │
│  NOT:  0x8D                           │
│  NOP:  0x00                           │
└─────────────────────────────────────────┘
```

🎯 **Pronto para programar!**
