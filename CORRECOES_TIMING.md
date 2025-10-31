# Correções de Timing - C_UNIT

## Problema Identificado

O processador estava apresentando valores incorretos porque havia **problemas de timing** ao usar signals como índices de arrays no mesmo ciclo de clock.

### Exemplo do Bug

```vhdl
-- ERRADO (timing problem):
dest_reg <= to_integer(unsigned(instruction(3 downto 2)));
mem_regs(dest_reg) <= operand1;  -- dest_reg ainda não foi atualizado!
```

O signal `dest_reg` só é atualizado no **próximo ciclo de clock**, mas estávamos tentando usá-lo **no mesmo ciclo**.

## Correções Aplicadas

### 1. Instrução 0x1X (LOAD math_reg <- memory_reg)

**Antes:**
```vhdl
src_reg <= to_integer(unsigned(instruction(1 downto 0)));
operand1 <= mem_regs(src_reg);  -- BUG: src_reg não atualizado
```

**Depois:**
```vhdl
src_reg <= to_integer(unsigned(instruction(1 downto 0)));
operand1 <= mem_regs(to_integer(unsigned(instruction(1 downto 0))));  -- OK: indexação direta
```

### 2. Instrução 0x2X (LOAD memory_reg <- math_reg)

**Antes:**
```vhdl
src_reg <= to_integer(unsigned(instruction(3 downto 2)));
dest_reg <= to_integer(unsigned(instruction(1 downto 0)));
mem_regs(dest_reg) <= math_regs(src_reg);  -- BUG: ambos não atualizados
```

**Depois:**
```vhdl
src_reg <= to_integer(unsigned(instruction(3 downto 2)));
dest_reg <= to_integer(unsigned(instruction(1 downto 0)));
mem_regs(to_integer(unsigned(instruction(1 downto 0)))) <= 
    math_regs(to_integer(unsigned(instruction(3 downto 2))));  -- OK: indexação direta
```

### 3. Instrução 0x3X (LOAD memory_reg <- memory_reg)

**Antes:**
```vhdl
dest_reg <= to_integer(unsigned(instruction(3 downto 2)));
src_reg <= to_integer(unsigned(instruction(1 downto 0)));
mem_regs(dest_reg) <= mem_regs(src_reg);  -- BUG: ambos não atualizados
```

**Depois:**
```vhdl
dest_reg <= to_integer(unsigned(instruction(3 downto 2)));
src_reg <= to_integer(unsigned(instruction(1 downto 0)));
mem_regs(to_integer(unsigned(instruction(3 downto 2)))) <= 
    mem_regs(to_integer(unsigned(instruction(1 downto 0))));  -- OK: indexação direta
```

### 4. Salvamento de Instrução Atual

**Problema:** No estado GET_VALUE1, o signal `instruction` da ROM já mudou para o próximo byte.

**Solução:**
```vhdl
-- No DECODE, salvar instrução:
current_instruction <= instruction;

-- No GET_VALUE1, usar a instrução salva:
operand1 <= math_regs(to_integer(unsigned(current_instruction(3 downto 2))));
operand2 <= math_regs(to_integer(unsigned(current_instruction(1 downto 0))));
```

## Debug Adicionado

Agora o processador imprime em cada mudança de estado:

- **FETCH**: Mostra o PC
- **DECODE**: Mostra a instrução e opcode
- **GET_VALUE1/GET_VALUE2**: Mostra valores sendo lidos
- **EXECUTE**: Mostra opcode e operandos
- **WRITE_BACK**: Mostra resultado sendo escrito

### Exemplo de Saída Esperada

Para o programa `LOAD r1,2; LOAD r2,3; LOAD x,r1; LOAD y,r2; SUM x,y`:

```
=== FETCH: PC=0 ===
DECODE: inst=00110000 opcode=0011
GET_VALUE1: Lendo valor imediato da ROM: 00000010
>>> EXECUTE: opcode=00110000 operand1=00000010 operand2=00000000
  -> LOAD mem_regs[0] = 00000010

=== FETCH: PC=2 ===
DECODE: inst=00110101 opcode=0011
GET_VALUE1: Lendo valor imediato da ROM: 00000011
>>> EXECUTE: opcode=00110101 operand1=00000011 operand2=00000000
  -> LOAD mem_regs[1] = 00000011

=== FETCH: PC=4 ===
DECODE: inst=00010000 opcode=0001
>>> EXECUTE: opcode=00010000 operand1=00000010 operand2=00000000
  -> LOAD math_regs[0] = 00000010

=== FETCH: PC=5 ===
DECODE: inst=00010101 opcode=0001
>>> EXECUTE: opcode=00010101 operand1=00000011 operand2=00000000
  -> LOAD math_regs[1] = 00000011

=== FETCH: PC=6 ===
DECODE: inst=01100001 opcode=0110
GET_VALUE1: OP1=math_regs[0]=00000010 OP2=math_regs[1]=00000011
>>> EXECUTE: opcode=01100001 operand1=00000010 operand2=00000011
  -> ULA: A=00000010 B=00000011 OP=0000
WRITE_BACK: math_regs[0] = 00000101
```

## Resultado Esperado

Após essas correções, o programa de teste deve:
- ✅ r1 = 2 (00000010)
- ✅ r2 = 3 (00000011)
- ✅ x = 2 (copiado de r1)
- ✅ y = 3 (copiado de r2)
- ✅ SUM x, y → x = 5 (00000101)

## Lição Aprendida

Em VHDL, quando se usa um signal como índice de array:
- O signal só é atualizado no **próximo delta cycle** ou **próximo clock**
- Se precisar usar o valor no **mesmo ciclo**, calcule o índice diretamente
- Sempre use indexação explícita: `array(to_integer(unsigned(...)))` ao invés de `array(signal_index)`
