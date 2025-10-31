# Reports Ativados no C_UNIT.vhd

## O que foi ativado

Todos os `report` statements foram descomentados para facilitar o debug.

## Reports Disponíveis

### FETCH
```vhdl
report "=== FETCH: PC=" & integer'image(PC) & " ===";
```
Mostra quando busca uma nova instrução e o valor do PC.

### DECODE
```vhdl
report "DECODE: inst=" & integer'image(to_integer(unsigned(instruction)));
```
Mostra a instrução sendo decodificada (valor decimal).

### GET_VALUE1
```vhdl
report "GET_VALUE1: Lendo valor imediato " & integer'image(to_integer(unsigned(instruction)));
```
Quando lê um valor imediato da ROM.

```vhdl
report "GET_VALUE1: Lendo de registrador, aguardando valor imediato";
```
Quando lê de registrador mas ainda precisa de valor imediato.

```vhdl
report "GET_VALUE1: Ambos operandos de registradores";
```
Quando ambos operandos vêm de registradores.

### GET_VALUE2
```vhdl
report "GET_VALUE2: Lendo valor imediato " & integer'image(to_integer(unsigned(instruction)));
```
Quando lê o segundo valor imediato.

### EXECUTE
```vhdl
report ">>> EXECUTE: opcode=" & integer'image(to_integer(unsigned(opcode)));
```
Mostra o opcode sendo executado.

```vhdl
report "  -> LOAD math_regs[" & integer'image(dest_reg) & "] = " & integer'image(to_integer(unsigned(operand1)));
```
Quando carrega valor em registrador matemático.

```vhdl
report "  -> LOAD mem_regs[" & integer'image(dest_reg) & "] = " & integer'image(to_integer(unsigned(operand1)));
```
Quando carrega valor em registrador de memória.

```vhdl
report "  -> ULA: A=" & integer'image(to_integer(unsigned(operand1))) & 
       " B=" & integer'image(to_integer(unsigned(operand2))) &
       " OP=" & integer'image(to_integer(unsigned(decoded_operation)));
```
Mostra entradas da ULA e operação.

### WRITE_BACK
```vhdl
report "WRITE_BACK: resultado=" & integer'image(to_integer(unsigned(ULA_OUTPUT))) & 
       " escrito em math_regs[" & integer'image(to_integer(unsigned(opcode(3 downto 2)))) & "]";
```
Mostra resultado da ULA e onde foi escrito.

## Exemplo de Saída Esperada

Para o programa teste (LOAD r1,2; LOAD r2,3; LOAD x,r1; LOAD y,r2; SUM x,y):

```
=== FETCH: PC=0 ===
DECODE: inst=48                      (0x30 = LOAD r1,)
=== FETCH: PC=1 ===
DECODE: inst=2                       (0x02 = valor 2)
GET_VALUE1: Lendo valor imediato 2
>>> EXECUTE: opcode=48
  -> LOAD mem_regs[0] = 2            (r1 = 2)
=== FETCH: PC=2 ===
DECODE: inst=53                      (0x35 = LOAD r2,)
=== FETCH: PC=3 ===
DECODE: inst=3                       (0x03 = valor 3)
GET_VALUE1: Lendo valor imediato 3
>>> EXECUTE: opcode=53
  -> LOAD mem_regs[1] = 3            (r2 = 3)
=== FETCH: PC=4 ===
DECODE: inst=16                      (0x10 = LOAD x,r1)
>>> EXECUTE: opcode=16
  -> LOAD math_regs[0] = 2           (x = r1 = 2)
=== FETCH: PC=5 ===
DECODE: inst=21                      (0x15 = LOAD y,r2)
>>> EXECUTE: opcode=21
  -> LOAD math_regs[1] = 3           (y = r2 = 3)
=== FETCH: PC=6 ===
DECODE: inst=97                      (0x61 = SUM x,y)
GET_VALUE1: Ambos operandos de registradores
>>> EXECUTE: opcode=97
  -> ULA: A=2 B=3 OP=0               (operação SUM)
WRITE_BACK: resultado=5 escrito em math_regs[0]  (x = 5)
=== FETCH: PC=7 ===
DECODE: inst=0                       (0x00 = NOP)
```

## Como Ver os Reports

No EDA Playground, após clicar "Run", os reports aparecem no console de simulação:

```
# KERNEL: Note: === FETCH: PC=0 ===
# KERNEL: Note: DECODE: inst=48
...
```

Cada linha mostra exatamente o que o processador está fazendo! 📊
