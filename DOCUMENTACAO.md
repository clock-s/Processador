# 📘 Documentação Completa do Processador de 8 Bits

## 🎯 Visão Geral

Este documento descreve um processador completo de 8 bits implementado em VHDL, incluindo sua arquitetura, conjunto de instruções, componentes e funcionamento interno.

### Características Principais
- **Arquitetura**: 8 bits
- **Memória ROM**: 256 posições (endereçamento de 8 bits)
- **Registradores**: 8 registradores (4 de memória + 4 matemáticos)
- **ULA Completa**: 12 operações diferentes
- **Conjunto de Instruções**: 15+ instruções
- **Pipeline**: Máquina de estados com 7 estados

---

## 🏗️ Arquitetura do Processador

### Diagrama de Blocos

```
┌─────────────────────────────────────────────────────────────┐
│                    UNIDADE DE CONTROLE                      │
│                         (C_UNIT)                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │   PC     │  │  FLAGS   │  │   ACC    │  │    MA    │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
│         │              │              │              │      │
│         └──────────────┴──────────────┴──────────────┘      │
│                          │                                  │
└──────────────────────────┼──────────────────────────────────┘
                           │
            ┌──────────────┼──────────────┐
            │              │              │
    ┌───────▼──────┐  ┌───▼────┐  ┌─────▼──────┐
    │   Memória    │  │  ULA   │  │Registradores│
    │     ROM      │  │ 8 bits │  │   (x8)      │
    │  (256x8)     │  │        │  │             │
    └──────────────┘  └────────┘  └─────────────┘
```

### Componentes Principais

#### 1. **Unidade de Controle (C_UNIT)**
- Gerencia o ciclo de busca-decodificação-execução
- Controla o fluxo de dados entre todos os componentes
- Mantém o Program Counter (PC)
- Gerencia registradores especiais
- **Implementa internamente os 8 registradores**:
  - **4 registradores de memória** (r1, r2, r3, r4) - array `mem_regs`
  - **4 registradores matemáticos** (x, y, z, w) - array `math_regs`

#### 2. **Unidade Lógica Aritmética (ULA)**
- Realiza todas as operações matemáticas e lógicas
- Suporta operações com flag de conclusão
- Overflow detection

#### 3. **Memória ROM (Archive)**
- 256 posições de 8 bits
- Carrega programas de arquivo externo (.bin)
- Leitura síncrona

#### 4. **Banco de Registradores (INTERNO)**
- **Não usa componente externo PACK_REGISTERS**
- 4 registradores de memória (r1-r4) implementados como array interno
- 4 registradores matemáticos (x-w) implementados como array interno separado
- Acesso direto via sinais internos

---

## 💾 Organização da Memória e Registradores

### Registradores de Memória (Memory Registers)
| Nome | Código | Descrição |
|------|--------|-----------|
| r1   | 00     | Registrador de uso geral 1 (armazenado internamente na C_UNIT) |
| r2   | 01     | Registrador de uso geral 2 (armazenado internamente na C_UNIT) |
| r3   | 10     | Registrador de uso geral 3 (armazenado internamente na C_UNIT) |
| r4   | 11     | Registrador de uso geral 4 (armazenado internamente na C_UNIT) |

**Nota Importante**: Os registradores r1-r4 são **implementados internamente** na Unidade de Controle como um array de 4 posições, completamente separado dos registradores matemáticos.

### Registradores Matemáticos (Math Registers)
| Nome | Código | Descrição |
|------|--------|-----------|
| x    | 00     | Registrador matemático X (usado pela ULA) |
| y    | 01     | Registrador matemático Y (usado pela ULA) |
| z    | 10     | Registrador matemático Z (usado pela ULA) |
| w    | 11     | Registrador matemático W (usado pela ULA) |

**Nota Importante**: Os registradores x, y, z, w são **implementados internamente** na Unidade de Controle como um array separado de 4 posições. Estes são os registradores principais para operações da ULA.

### Registradores Especiais

#### **Accumulator (ACC)**
- Armazena o último resultado de operação da ULA
- 8 bits

#### **Program Counter (PC)**
- Contador de programa (0-255)
- Incrementado automaticamente
- Modificado por instruções JUMP

#### **Memory Address (MA)**
- Registrador de endereço de memória
- Usado para endereçamento indireto
- 8 bits (0-255)

#### **Flags Register (FLAGS)**
| Bit | Nome | Descrição |
|-----|------|-----------|
| 0   | Z    | Zero - Resultado é zero |
| 1   | N    | Negative - Resultado é negativo (bit 7 = 1) |
| 2   | C    | Carry - Overflow/Carry da operação |
| 3   | P    | Parity - Paridade do resultado |
| 7   | K    | oVerflow - Cópia do carry para jumps condicionais |

---

## 📋 Conjunto de Instruções

### Formato das Instruções

As instruções têm tamanho variável:
- **1 byte**: Instrução básica (NOP, RES, RESF)
- **2 bytes**: Instrução + registrador/operando
- **3 bytes**: Instrução + dois operandos
- **3 bytes**: Instruções JUMP

### Codificação de Instruções

#### **Nibble Superior (bits 7-4)**: Determina o tipo de operação

| Código | Instrução | Descrição |
|--------|-----------|-----------|
| 0x0X   | NOP/RES/RESF/COMP | Controle e comparação |
| 0x1X   | LOAD Math ← Mem | Carrega registrador matemático da memória |
| 0x2X   | LOAD Mem ← Math | Carrega registrador de memória do matemático |
| 0x3X   | LOAD Mem ← Mem/Val | Carrega registrador de memória |
| 0x4X   | LOAD Special | Operações com registradores especiais |
| 0x5X   | JUMP/RSHIFT | Saltos e deslocamento à direita |
| 0x6X   | SUM | Adição |
| 0x7X   | MULT | Multiplicação |
| 0x8X   | AND/NOT | Operações lógicas |
| 0x9X   | OR/RSHIFT | OU lógico e shift |
| 0xAX   | XOR/RSHIFT | XOR e shift |
| 0xBX   | SUB | Subtração |
| 0xCX   | DIV/LSHIFT | Divisão e shift esquerda |
| 0xDX   | MOD/LSHIFT | Módulo e shift |
| 0xEX   | DIV/MOD/RSHIFT | Operações estendidas |
| 0xFX   | LSHIFT | Deslocamento à esquerda |

---

## 🔧 Instruções Detalhadas

### 1. Instruções Aritméticas

#### **SUM - Adição (0x6X)**

**Formato**: `SUM operando1, operando2`

**Variações**:
- `SUM x, y` - Soma dois registradores matemáticos
- `SUM x, 10` - Soma registrador com valor imediato
- `SUM 5, 10` - Soma dois valores imediatos

**Codificação**:
```
0x60 + código_operando1 + código_operando2
```

**Exemplos**:
```assembly
SUM x, y;      # 0x60  -> x = x + y
SUM x, 5;      # 0x6D 0x05  -> x = x + 5
SUM 10, 20;    # 0x6E 0x0A 0x14  -> resultado em ACC
```

**Flags Afetadas**: Z, N, C, K

---

#### **SUB - Subtração (0xBX)**

**Formato**: `SUB operando1, operando2`

**Descrição**: Subtrai operando2 de operando1

**Codificação**:
```
0xB0 + código_operando1 + código_operando2
```

**Exemplos**:
```assembly
SUB x, y;      # 0xB0  -> x = x - y
SUB y, 5;      # 0xB4 0x05  -> y = y - 5
SUB 100, 30;   # 0xBE 0x64 0x1E  -> resultado em ACC
```

**Flags Afetadas**: Z, N, C, K

---

#### **MULT - Multiplicação (0x7X)**

**Formato**: `MULT operando1, operando2`

**Descrição**: Multiplica dois operandos (resultado de 8 bits)

**Codificação**:
```
0x70 + código_operando1 + código_operando2
```

**Exemplos**:
```assembly
MULT x, y;     # 0x70  -> x = x * y
MULT z, 3;     # 0x78 0x03  -> z = z * 3
MULT 12, 5;    # 0x7E 0x0C 0x05  -> resultado em ACC
```

**Características**:
- Operação sequencial (múltiplos ciclos)
- Flag de conclusão indica fim da operação
- Overflow guardado no bit C

**Flags Afetadas**: Z, N, C, K

---

#### **DIV - Divisão (0xCX/0xDX)**

**Formato**: `DIV operando1, operando2`

**Descrição**: Divide operando1 por operando2 (resultado inteiro)

**Exemplos**:
```assembly
DIV x, y;      # x = x / y
DIV z, 4;      # z = z / 4
```

**Características**:
- Operação sequencial (múltiplos ciclos)
- Divisão por zero não tratada (resultado indefinido)
- Apenas parte inteira do resultado

**Flags Afetadas**: Z, N

---

#### **MOD - Módulo (0xDX)**

**Formato**: `MOD operando1, operando2`

**Descrição**: Resto da divisão de operando1 por operando2

**Exemplos**:
```assembly
MOD x, y;      # x = x % y
MOD w, 10;     # w = w % 10
```

**Flags Afetadas**: Z, N

---

### 2. Instruções Lógicas

#### **AND - E Lógico (0x8X)**

**Formato**: `AND operando1, operando2`

**Descrição**: Realiza AND bit a bit

**Exemplos**:
```assembly
AND x, y;      # 0x80  -> x = x & y
AND z, 0x0F;   # 0x88 0x0F  -> z = z & 0x0F (máscara)
```

**Uso Comum**: Máscaras de bits, isolamento de bits específicos

**Flags Afetadas**: Z, N

---

#### **OR - OU Lógico (0x9X)**

**Formato**: `OR operando1, operando2`

**Descrição**: Realiza OR bit a bit

**Exemplos**:
```assembly
OR x, y;       # 0x90  -> x = x | y
OR w, 0x80;    # 0x9C 0x80  -> w = w | 0x80 (set bit 7)
```

**Uso Comum**: Ativação de bits, combinação de flags

**Flags Afetadas**: Z, N

---

#### **XOR - OU Exclusivo (0xAX)**

**Formato**: `XOR operando1, operando2`

**Descrição**: Realiza XOR bit a bit

**Exemplos**:
```assembly
XOR x, y;      # 0xA0  -> x = x ^ y
XOR z, 0xFF;   # 0xA8 0xFF  -> z = ~z (inversão)
```

**Uso Comum**: Toggle de bits, inversão, criptografia simples

**Flags Afetadas**: Z, N

---

#### **NOT - Negação Lógica (0x8X)**

**Formato**: `NOT operando`

**Descrição**: Inverte todos os bits do operando

**Exemplos**:
```assembly
NOT x;         # 0x8D  -> x = ~x
NOT 0xAA;      # 0x89 0xAA  -> resultado = 0x55
```

**Flags Afetadas**: Z, N

---

### 3. Instruções de Deslocamento (Shift)

#### **LSHIFT - Deslocamento à Esquerda (0xCX/0xFX)**

**Formato**: `LSHIFT operando, quantidade`

**Descrição**: Desloca bits para a esquerda

**Exemplos**:
```assembly
LSHIFT x, y;   # 0xF0  -> x = x << y
LSHIFT z, 3;   # 0xC9 0x03  -> z = z << 3
```

**Características**:
- Bits à direita preenchidos com 0
- Bits perdidos à esquerda vão para carry
- Equivalente a multiplicação por 2^n

**Flags Afetadas**: Z, N, C

---

#### **RSHIFT - Deslocamento à Direita (0x5X/0x9X/0xAX)**

**Formato**: `RSHIFT operando, quantidade`

**Descrição**: Desloca bits para a direita

**Exemplos**:
```assembly
RSHIFT x, y;   # 0x94  -> x = x >> y
RSHIFT w, 2;   # 0x5F 0x02  -> w = w >> 2
```

**Características**:
- Bits à esquerda preenchidos com 0
- Bits perdidos à direita vão para carry
- Equivalente a divisão por 2^n

**Flags Afetadas**: Z, N, C

---

### 4. Instruções de Comparação

#### **COMP - Comparação (0x0C)**

**Formato**: `COMP operando1, operando2`

**Descrição**: Compara dois operandos e atualiza flags

**Exemplos**:
```assembly
COMP x, y;     # Compara x com y
COMP z, 10;    # Compara z com 10
```

**Flags Geradas**:
- **Z**: Igual (operando1 == operando2)
- **N**: Menor (operando1 < operando2)
- **C**: Maior (operando1 > operando2)
- **P**: Paridade

**Uso**: Preparação para jumps condicionais

---

### 5. Instruções de Controle de Fluxo

#### **JUMP - Salto Incondicional (0x54)**

**Formato**: `JUMP -label;`

**Descrição**: Salta para um endereço específico

**Codificação**:
```
0x54 [endereço]
```

**Exemplo**:
```assembly
-inicio;       # Define label "inicio"
LOAD x, 10;
JUMP -inicio;  # 0x54 [addr]  -> PC = addr
```

---

#### **JUMP Condicional (0x55)**

**Formato**: `JUMP -label, flags;`

**Descrição**: Salta se as condições de flag forem atendidas

**Codificação**:
```
0x55 [endereço] [máscara_flags]
```

**Flags de Condição**:
- **z**: Salta se Zero (resultado = 0)
- **n**: Salta se Negative (resultado < 0)
- **c**: Salta se Carry (overflow)
- **p**: Salta se Parity (paridade par)
- **k**: Salta se oVerflow

**Exemplos**:
```assembly
COMP x, y;
JUMP -maior, c;    # Salta se x > y
JUMP -igual, z;    # Salta se x == y
JUMP -menor, n;    # Salta se x < y
JUMP -overflow, k; # Salta se houve overflow
```

**Combinação de Flags**:
```assembly
JUMP -label, zc;   # Salta se Z=1 OU C=1
JUMP -label, nk;   # Salta se N=1 OU K=1
```

---

#### **NOP - No Operation (0x00)**

**Formato**: `NOP;`

**Descrição**: Nenhuma operação (delay de 1 ciclo)

**Exemplo**:
```assembly
NOP;           # 0x00  -> Apenas incrementa PC
```

**Uso**: Timing, alinhamento, debugging

---

### 6. Instruções de Movimentação de Dados

#### **LOAD - Carregar Dados (0x1X - 0x4X)**

**Formato**: `LOAD destino, origem`

**Variações**:

##### **a) Math_reg ← Memory_reg (0x1X)**
```assembly
LOAD x, r1;    # 0x10  -> x = r1
LOAD y, r2;    # 0x15  -> y = r2
LOAD z, r3;    # 0x1A  -> z = r3
LOAD w, r4;    # 0x1F  -> w = r4
```

##### **b) Memory_reg ← Math_reg (0x2X)**
```assembly
LOAD r1, x;    # 0x20  -> r1 = x
LOAD r2, y;    # 0x25  -> r2 = y
LOAD r3, z;    # 0x2A  -> r3 = z
LOAD r4, w;    # 0x2F  -> r4 = w
```

##### **c) Memory_reg ← Memory_reg (0x3X)**
```assembly
LOAD r1, r2;   # 0x31  -> r1 = r2
LOAD r3, r4;   # 0x3F  -> r3 = r4
```

##### **d) Memory_reg ← Valor Imediato (0x3X)**
```assembly
LOAD r1, 255;  # 0x30 0xFF  -> r1 = 255
LOAD r2, 42;   # 0x35 0x2A  -> r2 = 42
```

##### **e) Registradores Especiais (0x4X)**
```assembly
LOAD r1, a;    # r1 = accumulator
LOAD r1, ma;   # r1 = memory address register
LOAD ma, r1;   # memory address = r1
LOAD r1, [ma]; # r1 = memory[ma] (endereçamento indireto)
```

---

### 7. Instruções de Sistema

#### **RES - Reset Registers (0x01)**

**Formato**: `RES;`

**Descrição**: Zera todos os registradores matemáticos (x, y, z, w)

**Exemplo**:
```assembly
RES;           # 0x01  -> x=0, y=0, z=0, w=0
```

---

#### **RESF - Reset Flags (0x02)**

**Formato**: `RESF;`

**Descrição**: Zera todas as flags (Z, N, C, P, K)

**Exemplo**:
```assembly
RESF;          # 0x02  -> FLAGS = 0x00
```

---

## ⚙️ Unidade Lógica Aritmética (ULA)

### Operações da ULA

| Código | Operação | Descrição |
|--------|----------|-----------|
| 0000   | SUM      | Adição com carry |
| 0001   | SUB      | Subtração |
| 0010   | COMP     | Comparação |
| 0011   | XOR      | XOR bit a bit |
| 0100   | NOT      | Inversão de bits |
| 0101   | AND      | E lógico |
| 0110   | OR       | OU lógico |
| 0111   | MULT     | Multiplicação |
| 1000   | DIV      | Divisão inteira |
| 1001   | MOD      | Módulo (resto) |
| 1010   | LSHIFT   | Deslocamento esquerda |
| 1011   | RSHIFT   | Deslocamento direita |

### Características da ULA

#### **Operações Síncronas**
Todas as operações são síncronas com o clock.

#### **Sistema de Permissão**
- Sinal `permission` deve estar em '1' para iniciar operação
- ULA permanece idle enquanto `permission = '0'`

#### **Flag de Conclusão**
- Operações complexas (MULT, DIV, MOD, SHIFT) usam múltiplos ciclos
- Sinal `finished` indica quando a operação está completa
- Unidade de controle aguarda `finished = '1'` antes de prosseguir

#### **Detecção de Overflow**
- Sinal `overflow` indica carry/overflow
- Atualiza flags C e K automaticamente

---

## 🔄 Máquina de Estados da Unidade de Controle

### Estados do Processador

```
┌─────────┐
│  FETCH  │  Busca instrução da memória
└────┬────┘
     │
     ▼
┌─────────┐
│ DECODE  │  Decodifica instrução e identifica operandos
└────┬────┘
     │
     ▼
┌──────────────┐
│ GET_VALUE1   │  Busca primeiro operando (se necessário)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ GET_VALUE2   │  Busca segundo operando (se necessário)
└──────┬───────┘
       │
       ▼
┌──────────┐
│ EXECUTE  │  Executa operação na ULA ou controle
└────┬─────┘
     │
     ▼
┌────────────┐
│ WRITE_BACK │  Escreve resultado e atualiza flags
└─────┬──────┘
      │
      ▼
┌─────────┐
│  HALT   │  Estado de parada (opcional)
└─────────┘
```

### Descrição dos Estados

#### **1. FETCH**
- **Função**: Buscar próxima instrução da ROM
- **Ações**:
  - Envia PC para endereço da ROM
  - Desabilita permissão da ULA
  - Configura registradores para modo leitura
- **Próximo Estado**: DECODE

#### **2. DECODE**
- **Função**: Interpretar o opcode da instrução
- **Ações**:
  - Analisa nibble superior (bits 7-4) para tipo de instrução
  - Extrai códigos de registradores dos bits inferiores
  - Determina se precisa de valores imediatos
  - Identifica operação da ULA necessária
  - Incrementa PC
- **Próximo Estado**: 
  - GET_VALUE1 (se precisa de operandos)
  - EXECUTE (se não precisa de operandos)
  - FETCH (para NOP, RES, RESF)

#### **3. GET_VALUE1**
- **Função**: Obter primeiro operando
- **Ações**:
  - Se valor imediato: busca da ROM usando PC, incrementa PC
  - Se registrador: lê do banco de registradores ou registradores matemáticos
  - Armazena em `operand1`
- **Próximo Estado**:
  - GET_VALUE2 (se precisa de segundo operando)
  - EXECUTE (se tem todos os operandos)

#### **4. GET_VALUE2**
- **Função**: Obter segundo operando
- **Ações**:
  - Busca da ROM usando PC
  - Incrementa PC
  - Armazena em `operand2`
- **Próximo Estado**: EXECUTE

#### **5. EXECUTE**
- **Função**: Executar a operação
- **Ações para operações da ULA**:
  - Carrega `ULA_A` com operand1
  - Carrega `ULA_B` com operand2
  - Define `ULA_instruction` com código da operação
  - Ativa `ULA_permission`
  - Para MULT, DIV, MOD, SHIFT: aguarda `ULA_finished`
- **Ações para JUMP**:
  - Verifica condições de flag (se condicional)
  - Atualiza PC com endereço de destino
- **Próximo Estado**: WRITE_BACK

#### **6. WRITE_BACK**
- **Função**: Armazenar resultado da operação
- **Ações**:
  - Aguarda `ULA_finished = '1'` (se necessário)
  - Captura `ULA_OUTPUT`
  - Escreve em registrador de destino apropriado
  - Atualiza accumulator (ACC)
  - Atualiza flags:
    - Z: resultado = 0
    - N: resultado < 0 (bit 7 = 1)
    - C: carry/overflow da ULA
    - K: overflow da ULA
  - Desativa `ULA_permission`
- **Próximo Estado**: FETCH

#### **7. HALT**
- **Função**: Parar execução
- **Ações**: Nenhuma (estado de espera)
- **Próximo Estado**: HALT (permanece)

---

## 📝 Exemplos de Programas

### Exemplo 1: Soma Simples
```assembly
# Programa: Soma de dois números
# Resultado em x

LOAD x, 10;      # x = 10
LOAD y, 20;      # y = 20
SUM x, y;        # x = x + y = 30
LOAD r1, x;      # r1 = x (armazena resultado)
```

**Código de Máquina**:
```
0x6D 0x0A     # LOAD x, 10
0x64 0x14     # LOAD y, 20
0x60          # SUM x, y
0x20          # LOAD r1, x
```

---

### Exemplo 2: Loop Contador
```assembly
# Programa: Conta de 0 a 10

RES;             # Zera registradores
LOAD x, 0;       # x = 0 (contador)
LOAD y, 10;      # y = 10 (limite)

-loop;
LOAD r1, x;      # Armazena contador atual
SUM x, 1;        # x = x + 1
COMP x, y;       # Compara x com y
JUMP -loop, n;   # Se x < y, volta para loop
```

**Código de Máquina**:
```
0x01          # RES
0x6D 0x00     # LOAD x, 0
0x64 0x0A     # LOAD y, 10
0x20          # LOAD r1, x (endereço 4)
0x6D 0x01     # SUM x, 1
0x0C          # COMP x, y
0x55 0x04 0x02 # JUMP -loop, n
```

---

### Exemplo 3: Fatorial
```assembly
# Programa: Calcula fatorial de 5
# Resultado em x

LOAD x, 5;       # Número para calcular fatorial
LOAD y, 1;       # y = resultado (inicia com 1)
LOAD z, 1;       # z = contador

-loop;
MULT y, x;       # y = y * x
SUB x, z;        # x = x - 1
COMP x, z;       # Compara x com 1
JUMP -loop, c;   # Se x > 1, continua loop

LOAD r1, y;      # Armazena resultado final
```

---

### Exemplo 4: Operações Bit a Bit
```assembly
# Programa: Manipulação de bits

LOAD x, 0b10101010;  # x = 0xAA
LOAD y, 0b11110000;  # y = 0xF0

AND x, y;            # x = 0xA0 (bits comuns)
LOAD r1, x;          # Salva resultado AND

LOAD x, 0b10101010;
OR x, y;             # x = 0xFA (todos os bits)
LOAD r2, x;          # Salva resultado OR

LOAD x, 0b10101010;
XOR x, y;            # x = 0x5A (bits diferentes)
LOAD r3, x;          # Salva resultado XOR

NOT x;               # x = 0xA5 (inverte bits)
LOAD r4, x;          # Salva resultado NOT
```

---

### Exemplo 5: Divisão e Módulo
```assembly
# Programa: Divide 100 por 7
# Quociente e resto

LOAD x, 100;         # Dividendo
LOAD y, 7;           # Divisor

DIV x, y;            # x = 100 / 7 = 14
LOAD r1, x;          # r1 = quociente

LOAD x, 100;
MOD x, y;            # x = 100 % 7 = 2
LOAD r2, x;          # r2 = resto
```

---

### Exemplo 6: Deslocamento de Bits
```assembly
# Programa: Multiplicação e divisão por potências de 2

LOAD x, 5;           # x = 5 (0b00000101)

LSHIFT x, 1;         # x = 10 (multiplica por 2)
LOAD r1, x;

LSHIFT x, 2;         # x = 40 (multiplica por 4)
LOAD r2, x;

RSHIFT x, 3;         # x = 5 (divide por 8)
LOAD r3, x;
```

---

### Exemplo 7: Verificação de Paridade
```assembly
# Programa: Verifica se número tem paridade par

LOAD x, 0b10110101;  # Número a verificar
COMP x, x;           # COMP atualiza flag de paridade
JUMP -par, p;        # Salta se paridade par
JUMP -impar;

-par;
LOAD r1, 1;          # r1 = 1 (paridade par)
JUMP -fim;

-impar;
LOAD r1, 0;          # r1 = 0 (paridade ímpar)

-fim;
```

---

### Exemplo 8: Busca de Máximo
```assembly
# Programa: Encontra o maior entre 3 números

LOAD r1, 25;         # Primeiro número
LOAD r2, 42;         # Segundo número
LOAD r3, 17;         # Terceiro número

LOAD x, r1;          # x = primeiro
LOAD y, r2;
COMP x, y;
JUMP -x_maior1, c;   # Se x > y
LOAD x, r2;          # x = y (y é maior)

-x_maior1;
LOAD y, r3;
COMP x, y;
JUMP -fim, c;        # Se x > z, x é o maior
LOAD x, r3;          # x = z (z é o maior)

-fim;
LOAD r4, x;          # r4 = máximo
```

---

## 🔬 Componentes VHDL Detalhados

### 1. **C_UNIT.vhd** - Unidade de Controle

**Interface**:
```vhdl
entity C_UNIT is port(
    clock       : in  std_logic;
    reset       : in  std_logic;
    debug_pc    : out integer range 0 to 255;
    debug_state : out std_logic_vector(2 downto 0)
);
```

**Sinais Internos Principais**:
- `PC`: Program Counter (0-255)
- `current_state`: Estado atual da máquina
- `opcode`: Instrução sendo executada
- `operand1, operand2`: Operandos da instrução
- **`mem_regs`**: Array de 4 registradores de memória (r1, r2, r3, r4)
- **`math_regs`**: Array de 4 registradores matemáticos (x, y, z, w)
- `flags_reg`: Registrador de flags
- `acc_reg`: Accumulator

**Importante**: Esta unidade de controle **não usa o componente PACK_REGISTERS_PORTS**. Os registradores r1-r4 e x-w são implementados como arrays internos separados dentro da C_UNIT.

---

### 2. **ULA.vhd** - Unidade Lógica Aritmética

**Interface**:
```vhdl
entity ULA is port(
    output      : out std_logic_vector (7 downto 0);
    finished    : out std_logic;
    overflow    : out std_logic;
    
    A           : in std_logic_vector (7 downto 0);
    B           : in std_logic_vector (7 downto 0);
    permission  : in std_logic;
    instruction : in std_logic_vector (3 downto 0);
    clock       : in std_logic   
);
```

**Componentes Internos**:
- `SUM_8_BITS`: Somador completo de 8 bits
- `SUBTRACTION_8_BITS`: Subtrator de 8 bits
- `MULT`: Multiplicador sequencial
- `MOD_DIV`: Divisor e módulo sequencial
- `COMPARE`: Comparador
- `BIT_WISE`: Operações lógicas bit a bit
- `L_SHIFT`: Deslocamento à esquerda
- `R_SHIFT`: Deslocamento à direita

---

### 3. **archive.vhd** - Memória ROM

**Interface**:
```vhdl
entity archive is port(
    data : out std_logic_vector (7 downto 0);
    addr : in  integer range 0 to 255
);
```

**Características**:
- Lê arquivo "teste.bin" na inicialização
- Formato hexadecimal (2 dígitos por linha)
- 256 posições de 8 bits
- Acesso síncrono

**Formato do Arquivo .bin**:
```
6D
0A
64
14
60
20
00
```

---

### 4. **pack_register.vhd** - Banco de Registradores

**Interface**:
```vhdl
entity PACK_REGISTERS_PORTS is port(
    clock      : in    std_logic;
    reset      : in    std_logic;
    write_read : in    std_logic;  -- 0=read, 1=write
    addr       : in    std_logic_vector (1 downto 0);
    data       : inout std_logic_vector (7 downto 0)
);
```

**Características**:
- 4 registradores (endereçados por 2 bits)
- Barramento bidirecional
- Reset assíncrono
- Escritura/leitura controlada por sinal

---

### 5. Componentes Auxiliares

#### **sum.vhd** - Somador
- Somador completo de 1 bit
- Somador de 8 bits com carry in/out

#### **sub.vhd** - Subtrator
- Usa complemento de 2
- Gera flag de carry/borrow

#### **mult.vhd** - Multiplicador
- Multiplicação sequencial
- 8 ciclos de clock
- Usa soma e shift
- Suporta números negativos (complemento de 2)

#### **DIV_MOD.vhd** - Divisor/Módulo
- Divisão sequencial (algoritmo de Restoring Division)
- Gera quociente e resto
- Flag de conclusão

#### **bit_wise.vhd** - Operações Lógicas
- Selector de 2 bits para escolher operação:
  - 00: AND
  - 01: OR
  - 10: XOR
  - 11: NOT

#### **l_shift.vhd** / **r_shift.vhd** - Deslocadores
- Deslocamento sequencial
- Suporta quantidade variável de shifts
- Flag de carry para bits perdidos

#### **comp.vhd** - Comparador
- Gera 4 flags de comparação
- Suporta igual, maior, menor
- Calcula paridade

---

## 🛠️ Compilador

### **compiler.cpp** - Compilador Assembly para Binário

**Função**: Converte código assembly em binário executável

**Processo de Compilação**:

1. **Primeira Passagem**:
   - Identifica labels (jumppoints) e seus endereços
   - Conta instruções para calcular PCs corretos

2. **Segunda Passagem**:
   - Gera código de máquina
   - Resolve endereços de jumps
   - Escreve arquivo .bin

**Sintaxe do Assembly**:
```assembly
# Comentários começam com #

# Labels começam com - e terminam com ;
-meu_label;

# Instruções terminam com ;
LOAD x, 10;
SUM x, y;

# Jumps referenciam labels com -
JUMP -meu_label;
JUMP -outro_label, zn;  # Condicional
```

**Uso**:
```bash
./compiler programa.gbf programa.bin
```

**Exemplo de Arquivo .gbf**:
```assembly
# Programa de teste
RES;
LOAD x, 5;
LOAD y, 3;
SUM x, y;
LOAD r1, x;
```

**Saída .bin**:
```
01
6D
05
64
03
60
20
```

---

## 📊 Tabela Completa de Opcodes

### Instruções de 1 Byte

| Opcode | Mnemônico | Descrição |
|--------|-----------|-----------|
| 0x00   | NOP       | Nenhuma operação |
| 0x01   | RES       | Reset registradores matemáticos |
| 0x02   | RESF      | Reset flags |

### Instruções LOAD (2 bytes)

| Opcode | Mnemônico | Descrição |
|--------|-----------|-----------|
| 0x10   | LOAD x,r1 | x ← r1 |
| 0x11   | LOAD x,r2 | x ← r2 |
| 0x12   | LOAD x,r3 | x ← r3 |
| 0x13   | LOAD x,r4 | x ← r4 |
| 0x14   | LOAD y,r1 | y ← r1 |
| 0x15   | LOAD y,r2 | y ← r2 |
| ...    | ...       | ... |
| 0x20   | LOAD r1,x | r1 ← x |
| 0x21   | LOAD r1,y | r1 ← y |
| ...    | ...       | ... |

### Instruções LOAD com Imediato (2 bytes)

| Opcode | Byte 2 | Mnemônico | Descrição |
|--------|--------|-----------|-----------|
| 0x30   | val    | LOAD r1,val | r1 ← val |
| 0x35   | val    | LOAD r2,val | r2 ← val |
| 0x3A   | val    | LOAD r3,val | r3 ← val |
| 0x3F   | val    | LOAD r4,val | r4 ← val |

### Instruções Aritméticas Registrador-Registrador (1 byte)

| Opcode | Mnemônico | Descrição |
|--------|-----------|-----------|
| 0x60   | SUM x,y   | x = x + y |
| 0x61   | SUM x,z   | x = x + z |
| 0x62   | SUM x,w   | x = x + w |
| 0x64   | SUM y,x   | y = y + x |
| 0x65   | SUM y,z   | y = y + z |
| ...    | ...       | ... |
| 0x70   | MULT x,y  | x = x * y |
| ...    | ...       | ... |
| 0xB0   | SUB x,y   | x = x - y |
| ...    | ...       | ... |

### Instruções Aritméticas com Imediato (2 bytes)

| Opcode | Byte 2 | Mnemônico | Descrição |
|--------|--------|-----------|-----------|
| 0x6D   | val    | SUM x,val | x = x + val |
| 0x64   | val    | SUM y,val | y = y + val |
| 0x7D   | val    | MULT x,val| x = x * val |
| 0xB4   | val    | SUB y,val | y = y - val |

### Instruções Lógicas (1-2 bytes)

| Opcode | Byte 2 | Mnemônico | Descrição |
|--------|--------|-----------|-----------|
| 0x80   | -      | AND x,y   | x = x & y |
| 0x88   | val    | AND x,val | x = x & val |
| 0x8D   | -      | NOT x     | x = ~x |
| 0x89   | val    | NOT val   | resultado = ~val |
| 0x90   | -      | OR x,y    | x = x \| y |
| 0xA0   | -      | XOR x,y   | x = x ^ y |

### Instruções de Shift (2 bytes)

| Opcode | Byte 2 | Mnemônico | Descrição |
|--------|--------|-----------|-----------|
| 0xC4   | val    | LSHIFT x,val | x = x << val |
| 0xC8   | val    | LSHIFT y,val | y = y << val |
| 0xF0   | -      | LSHIFT x,y   | x = x << y |
| 0x9D   | val    | RSHIFT x,val | x = x >> val |
| 0x94   | -      | RSHIFT x,x   | x = x >> x |

### Instruções de Comparação (1 byte)

| Opcode | Mnemônico | Descrição |
|--------|-----------|-----------|
| 0x0C   | COMP x,y  | Compara x com y |

### Instruções de Salto (3 bytes)

| Opcode | Byte 2 | Byte 3 | Mnemônico | Descrição |
|--------|--------|--------|-----------|-----------|
| 0x54   | addr   | -      | JUMP addr | PC = addr |
| 0x55   | addr   | flags  | JUMP addr,flags | PC = addr se flags |

**Máscaras de Flags para JUMP Condicional**:
- 0x01: Z (Zero)
- 0x02: N (Negative)
- 0x04: C (Carry)
- 0x08: K (oVerflow)
- 0x80: P (Parity)

---

## 🎓 Conceitos Avançados

### 1. Complemento de 2

O processador usa complemento de 2 para representar números negativos:

**Representação**:
- Números positivos: 0x00 (0) a 0x7F (127)
- Números negativos: 0x80 (-128) a 0xFF (-1)

**Conversão**:
1. Inverte todos os bits
2. Soma 1

**Exemplo**: -5
```
5  = 0b00000101
~5 = 0b11111010
+1 = 0b11111011 = 0xFB = -5
```

---

### 2. Flags e Condições

#### **Flag Zero (Z)**
- Ativada quando resultado = 0
- Uso: Detectar igualdade, fim de loops

#### **Flag Negative (N)**
- Ativada quando bit 7 = 1
- Uso: Detectar números negativos, comparações

#### **Flag Carry (C)**
- Ativada em overflow/underflow
- Uso: Aritmética de precisão estendida

#### **Flag Parity (P)**
- Ativada quando número de bits '1' é par
- Uso: Detecção de erros, verificações

#### **Flag oVerflow (K)**
- Cópia do carry para jumps
- Uso: Jumps condicionais

---

### 3. Pipeline e Latência

#### **Instruções de 1 Ciclo**:
- NOP, RES, RESF
- LOAD registrador-registrador
- Operações lógicas simples

#### **Instruções de 2-3 Ciclos**:
- LOAD com valor imediato
- SUM, SUB (se com imediato)
- JUMP incondicional

#### **Instruções de Múltiplos Ciclos**:
- **MULT**: ~8 ciclos
- **DIV**: ~8 ciclos
- **MOD**: ~8 ciclos
- **LSHIFT/RSHIFT**: ~n ciclos (n = quantidade de shifts)

---

### 4. Endereçamento Indireto

Usando o registrador MA (Memory Address):

```assembly
# Carregar valor de posição variável da memória

LOAD r1, 50;     # r1 = 50
LOAD ma, r1;     # MA = 50
LOAD r2, [ma];   # r2 = memory[50]
```

---

### 5. Subrotinas (Simulação)

O processador não tem CALL/RET nativos, mas pode-se simular:

```assembly
# Simular chamada de subrotina

LOAD r4, -retorno;  # Salva endereço de retorno
JUMP -subrotina;

-retorno;
# Código continua aqui...

-subrotina;
# Código da subrotina
LOAD ma, r4;
JUMP [ma];          # Retorna
```

---

## 📈 Desempenho e Otimizações

### Otimizações Possíveis

#### **1. Uso Eficiente de Registradores**
- Manter valores frequentes em registradores matemáticos (x, y, z, w)
- Usar registradores de memória (r1-r4) para armazenamento temporário

#### **2. Minimizar Acessos à Memória**
- LOAD imediato é mais lento que operação entre registradores
- Reutilizar valores já carregados

#### **3. Evitar Operações Caras**
- Preferir LSHIFT/RSHIFT a MULT/DIV quando possível
- Usar ADD repetido ao invés de MULT para multiplicar por constantes pequenas

#### **4. Desenrolar Loops (Loop Unrolling)**
```assembly
# Ao invés de:
-loop;
SUM x, y;
SUB z, 1;
JUMP -loop, n;

# Fazer:
SUM x, y;
SUM x, y;
SUM x, y;
SUM x, y;
```

---

## 🐛 Debugging e Testes

### Sinais de Debug

A unidade de controle expõe:
- `debug_pc`: Valor atual do Program Counter
- `debug_state`: Estado atual da máquina de estados

**Estados**:
- 000: FETCH
- 001: DECODE
- 010: GET_VALUE1
- 011: GET_VALUE2
- 100: EXECUTE
- 101: WRITE_BACK
- 111: HALT

### Testbenches Disponíveis

1. **testbench_ULA.vhd**: Testa todas operações da ULA
2. **testbench_SUM.vhd**: Testa somador
3. **testbench_SUB.vhd**: Testa subtrator
4. **testbench_MULT.vhd**: Testa multiplicador
5. **testbench_DIV_MOD.vhd**: Testa divisor/módulo
6. **testbench_BW.vhd**: Testa operações bit-wise
7. **testbench_S.vhd**: Testa shifts
8. **testbench_REG.vhd**: Testa banco de registradores
9. **testbench_comp.vhd**: Testa comparador

---

## 📚 Referências e Recursos

### Arquivos Principais do Projeto

```
Processador/
├── Entitys/
│   ├── C_UNIT.vhd          # Unidade de Controle
│   ├── ULA.vhd             # ULA completa
│   ├── archive.vhd         # Memória ROM
│   ├── pack_register.vhd   # Banco de registradores
│   ├── sum.vhd             # Somador
│   ├── sub.vhd             # Subtrator
│   ├── mult.vhd            # Multiplicador
│   ├── DIV_MOD.vhd         # Divisor/Módulo
│   ├── bit_wise.vhd        # Operações lógicas
│   ├── l_shift.vhd         # Shift esquerda
│   ├── r_shift.vhd         # Shift direita
│   ├── comp.vhd            # Comparador
│   └── ...
├── Testbench's/
│   ├── packages.vhd        # Pacotes auxiliares
│   ├── testebench_ULA.vhd
│   └── ...
├── Compiler/
│   ├── compiler.cpp        # Compilador
│   └── teste2.gbf          # Exemplo de código
└── DOCUMENTACAO.md         # Este documento
```

### Extensões Futuras

1. **Interrupts**: Sistema de interrupções
2. **Stack**: Pilha para subrotinas
3. **RAM**: Memória de escrita
4. **I/O**: Portas de entrada/saída
5. **DMA**: Acesso direto à memória
6. **Cache**: Cache de instruções
7. **Pipeline**: Pipeline de execução
8. **Floating Point**: Aritmética de ponto flutuante

---

## 🎉 Conclusão

Este processador de 8 bits é um sistema completo e funcional que demonstra os conceitos fundamentais de arquitetura de computadores:

✅ **Ciclo de Busca-Decodificação-Execução**
✅ **Unidade Lógica Aritmética com 12 operações**
✅ **Sistema de registradores organizado**
✅ **Conjunto de instruções rico e extensível**
✅ **Suporte a saltos condicionais e incondicionais**
✅ **Flags de status para controle de fluxo**
✅ **Operações aritméticas, lógicas e de deslocamento**
✅ **Compilador assembly funcional**

O processador é capaz de executar programas complexos incluindo loops, condicionais, operações aritméticas avançadas e manipulação de bits, fornecendo uma base sólida para entender como processadores reais funcionam internamente.

---

## 📞 Informações Adicionais

**Versão**: 1.0
**Data**: Outubro 2025
**Linguagem**: VHDL (IEEE 1076-2008)
**Simulador Recomendado**: ModelSim, GHDL, ou Vivado

---

*Documentação gerada para apresentação acadêmica do projeto de processador de 8 bits.*
