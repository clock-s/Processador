# Programa de Teste Completo do Processador

Este documento descreve o programa de teste implementado em `archive_eda.vhd` para validar todas as funcionalidades do processador 8-bit.

## Estrutura dos Testes

O programa contém 12 testes diferentes cobrindo todas as operações principais da ULA e transferências de dados.

---

## Teste 1: Operação Básica de SOMA
**Endereços:** 0-6  
**Objetivo:** Validar LOAD de valores imediatos, transferência entre registradores e operação SUM

```assembly
LOAD r1, 5      ; r1 = 5
LOAD r2, 3      ; r2 = 3
LOAD x, r1      ; x = 5
LOAD y, r2      ; y = 3
SUM x, y        ; x = 5 + 3 = 8
```

**Resultado Esperado:** `x = 8`

---

## Teste 2: Operação de SUBTRAÇÃO
**Endereços:** 7-10  
**Objetivo:** Validar operação SUB entre registradores

```assembly
LOAD r3, 10     ; r3 = 10
LOAD x, r3      ; x = 10
SUB y, x        ; y = 3 - 10 = -7 (249 em unsigned 8-bit)
```

**Resultado Esperado:** `y = 249` (complemento de 2 de -7)

---

## Teste 3: Operação de MULTIPLICAÇÃO
**Endereços:** 11-17  
**Objetivo:** Validar operação MULT entre registradores

```assembly
LOAD r1, 4      ; r1 = 4
LOAD r2, 3      ; r2 = 3
LOAD x, r2      ; x = 3
LOAD y, r1      ; y = 4
MULT x, y       ; x = 3 * 4 = 12
```

**Resultado Esperado:** `x = 12`

---

## Teste 4: Operação Lógica AND
**Endereços:** 18-24  
**Objetivo:** Validar operação AND bit-a-bit

```assembly
LOAD r1, 15     ; r1 = 15  (0b00001111)
LOAD r2, 51     ; r2 = 51  (0b00110011)
LOAD x, r1      ; x = 15
LOAD y, r2      ; y = 51
AND x, y        ; x = 15 & 51 = 3 (0b00000011)
```

**Resultado Esperado:** `x = 3`

**Explicação:**
```
  00001111  (15)
& 00110011  (51)
----------
  00000011  (3)
```

---

## Teste 5: Operação Lógica OR
**Endereços:** 25-31  
**Objetivo:** Validar operação OR bit-a-bit

```assembly
LOAD r1, 12     ; r1 = 12  (0b00001100)
LOAD r2, 3      ; r2 = 3   (0b00000011)
LOAD x, r1      ; x = 12
LOAD y, r2      ; y = 3
OR x, y         ; x = 12 | 3 = 15 (0b00001111)
```

**Resultado Esperado:** `x = 15`

**Explicação:**
```
  00001100  (12)
| 00000011  (3)
----------
  00001111  (15)
```

---

## Teste 6: Operação Lógica XOR
**Endereços:** 32-38  
**Objetivo:** Validar operação XOR bit-a-bit

```assembly
LOAD r1, 15     ; r1 = 15  (0b00001111)
LOAD r2, 10     ; r2 = 10  (0b00001010)
LOAD x, r1      ; x = 15
LOAD y, r2      ; y = 10
XOR x, y        ; x = 15 ^ 10 = 5 (0b00000101)
```

**Resultado Esperado:** `x = 5`

**Explicação:**
```
  00001111  (15)
^ 00001010  (10)
----------
  00000101  (5)
```

---

## Teste 7: Operação de INVERSÃO (NOT)
**Endereços:** 39-42  
**Objetivo:** Validar operação NOT (inversão de bits)

```assembly
LOAD r1, 170    ; r1 = 170 (0xAA = 0b10101010)
LOAD x, r1      ; x = 170
NOT x           ; x = ~170 = 85 (0x55 = 0b01010101)
```

**Resultado Esperado:** `x = 85`

**Explicação:**
```
Original: 10101010  (170)
NOT:      01010101  (85)
```

---

## Teste 8: Transferência Memória ← Matemática
**Endereços:** 43-46  
**Objetivo:** Validar cópia de registrador matemático para registrador de memória (0x2X)

```assembly
LOAD r1, 99     ; r1 = 99
LOAD x, r1      ; x = 99
LOAD r1, x      ; r1 = x = 99 (copia x de volta para r1)
```

**Resultado Esperado:** `r1 = 99`, `x = 99`

---

## Teste 9: SOMA com Valores Imediatos
**Endereços:** 47-49  
**Objetivo:** Validar SUM com dois valores imediatos (0x6E)

```assembly
SUM V1, V2      ; x = 10 + 20 = 30
  .byte 10      ; V1 = 10
  .byte 20      ; V2 = 20
```

**Resultado Esperado:** `x = 30`

---

## Teste 10: MULTIPLICAÇÃO com Valor Imediato
**Endereços:** 50-54  
**Objetivo:** Validar MULT com registrador e valor imediato (0x7D)

```assembly
LOAD r1, 5      ; r1 = 5
LOAD x, r1      ; x = 5
MULT x, V       ; x = 5 * 6 = 30
  .byte 6       ; V = 6
```

**Resultado Esperado:** `x = 30`

---

## Teste 11: SUBTRAÇÃO com Valor Imediato
**Endereços:** 55-59  
**Objetivo:** Validar SUB com registrador e valor imediato (0xBD)

```assembly
LOAD r3, 50     ; r3 = 50
LOAD x, r3      ; x = 50
SUB x, V        ; x = 50 - 15 = 35
  .byte 15      ; V = 15
```

**Resultado Esperado:** `x = 35`

---

## Teste 12: Cópia Entre Registradores de Memória
**Endereços:** 60-63  
**Objetivo:** Validar cópia entre registradores de memória (0x3X com src≠dest)

```assembly
LOAD r1, 77     ; r1 = 77
LOAD r1, r1     ; r1 = r1 (autocopia, mantém 77)
LOAD r2, r1     ; r2 = r1 = 77 (copia r1 para r2)
```

**Resultado Esperado:** `r1 = 77`, `r2 = 77`

---

## Resumo de Resultados Esperados

| Teste | Operação | Resultado Final |
|-------|----------|----------------|
| 1  | SUM      | x = 8          |
| 2  | SUB      | y = 249 (-7)   |
| 3  | MULT     | x = 12         |
| 4  | AND      | x = 3          |
| 5  | OR       | x = 15         |
| 6  | XOR      | x = 5          |
| 7  | NOT      | x = 85         |
| 8  | LOAD     | r1 = 99, x = 99|
| 9  | SUM imm  | x = 30         |
| 10 | MULT imm | x = 30         |
| 11 | SUB imm  | x = 35         |
| 12 | Cópia    | r1 = 77, r2 = 77|

---

## Cobertura de Instruções

Este programa testa:

### Operações Aritméticas:
- ✅ SUM (registrador-registrador e imediato-imediato)
- ✅ SUB (registrador-registrador e registrador-imediato)
- ✅ MULT (registrador-registrador e registrador-imediato)

### Operações Lógicas:
- ✅ AND (registrador-registrador)
- ✅ OR (registrador-registrador)
- ✅ XOR (registrador-registrador)
- ✅ NOT (registrador único)

### Transferências de Dados:
- ✅ LOAD mem_reg ← valor imediato (0x3X)
- ✅ LOAD math_reg ← mem_reg (0x1X)
- ✅ LOAD mem_reg ← math_reg (0x2X)
- ✅ LOAD mem_reg ← mem_reg (0x3X com src≠dest)

### Instruções de Controle:
- ✅ NOP com halt automático

---

## Como Executar no EDA Playground

1. Compile todos os arquivos na ordem:
   - `archive_eda.vhd`
   - `pack_register_mem.vhd`
   - `pack_register_math.vhd`
   - `ULA.vhd` (e todas suas dependências)
   - `C_UNIT.vhd`
   - `testbench_C_UNIT_standalone.vhd`

2. Execute a simulação por pelo menos **2000 ns** para permitir que todos os testes executem

3. Observe os reports no console para validar cada operação

4. Verifique os valores finais dos registradores:
   - `mem_regs[0]` (r1) = 77
   - `mem_regs[1]` (r2) = 77
   - `mem_regs[2]` (r3) = 50
   - `math_regs[0]` (x) = 35
   - `math_regs[1]` (y) = 249

---

## Debug e Validação

Para cada teste, o processador emite reports detalhados:
- `FETCH: PC=X` - Mostra o contador de programa
- `DECODE: inst=Y` - Mostra a instrução sendo decodificada
- `GET_VALUE1/2: Lendo valor imediato Z` - Mostra valores lidos da ROM
- `EXECUTE: opcode=W` - Confirma execução
- `ULA: A=X B=Y OP=Z` - Mostra operandos e operação da ULA
- `WRITE_BACK: resultado=R escrito em math_regs[N]` - Mostra resultado final

Compare os valores reportados com os esperados neste documento! 🎯
