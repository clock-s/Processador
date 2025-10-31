# Correção: Leitura Síncrona de Registradores

## Problema Descoberto

Após corrigir a leitura de valores imediatos, apareceu bug de timing: **registradores sendo lidos antes de atualizar!**

### Execução com Bug:
```
LOAD r1, 2   → mem_regs[0] = 2  ✅
LOAD r2, 3   → mem_regs[1] = 3  ✅
LOAD x, r1   → math_regs[0] = 2  ✅
LOAD y, r2   → math_regs[1] = 3  ✅ (report correto!)
SUM x, y     → 2 + 2 = 4  ❌ ERRADO! Deveria ser 2 + 3 = 5!
```

O report mostrava y=3, mas a ULA recebia B=2!

## Causa Raiz

**TODOS** os componentes PACK_REGISTER têm **leitura síncrona** - quando você configura `read_addr`, o dado só fica disponível em `read_data` no **próximo ciclo de clock**!

### Bug 1: Instrução 0x1X (LOAD math_reg <- mem_reg)
```vhdl
DECODE:
  mem_read_addr_a <= 1  ← Configura endereço
  operand1 <= mem_read_data_a  ← Lê IMEDIATAMENTE (ERRADO!)
```

### Bug 2: Operações de ULA com registradores (0x6X, 0x7X, etc)
```vhdl
GET_VALUE1:
  math_read_addr_a <= 0  ← x
  math_read_addr_b <= 1  ← y
  operand1 <= math_read_data_a  ← Lê IMEDIATAMENTE (ERRADO!)
  operand2 <= math_read_data_b  ← Lê IMEDIATAMENTE (ERRADO!)
```

## Soluções Implementadas

### Solução 1: Instrução 0x1X
```vhdl
DECODE (0x1X):
  - mem_read_addr_a <= src_reg
  - NÃO lê operand1
  - Vai para EXECUTE

EXECUTE (0x1X):
  - math_write_data <= mem_read_data_a  ← Lê AGORA (após 1 ciclo)
```

### Solução 2: Operações ULA com registradores
```vhdl
GET_VALUE1 (needs_value1='0', needs_value2='0'):
  - math_read_addr_a <= reg_a
  - math_read_addr_b <= reg_b
  - NÃO lê operand1/operand2
  - Vai para EXECUTE

EXECUTE (operação ULA):
  - if needs_value1='0' and needs_value2='0' then
      ULA_A <= math_read_data_a  ← Lê AGORA (após 1 ciclo)
      ULA_B <= math_read_data_b  ← Lê AGORA (após 1 ciclo)
    else
      ULA_A <= operand1  ← Usa valores imediatos já lidos
      ULA_B <= operand2
    end if
```

## Mudanças no Código

### 1. No DECODE (0x1X):
**Antes:**
```vhdl
mem_read_addr_a <= to_integer(unsigned(instruction(1 downto 0)));
operand1 <= mem_read_data_a;  -- Lia imediatamente (ERRADO!)
current_state <= EXECUTE;
```

**Depois:**
```vhdl
mem_read_addr_a <= to_integer(unsigned(instruction(1 downto 0)));
-- DON'T read operand1 yet, need to wait 1 cycle for register read
-- Will read in EXECUTE state
current_state <= EXECUTE;
```

### 2. No EXECUTE (0x1X):
**Antes:**
```vhdl
math_write_data <= operand1;  -- Usava valor lido errado
```

**Depois:**
```vhdl
math_write_data <= mem_read_data_a;  -- Lê AGORA, após 1 ciclo
```

### 3. No GET_VALUE1 (operandos de registradores):
**Antes:**
```vhdl
math_read_addr_a <= to_integer(unsigned(current_instruction(3 downto 2)));
math_read_addr_b <= to_integer(unsigned(current_instruction(1 downto 0)));
operand1 <= math_read_data_a;  -- ERRADO!
operand2 <= math_read_data_b;  -- ERRADO!
```

**Depois:**
```vhdl
math_read_addr_a <= to_integer(unsigned(current_instruction(3 downto 2)));
math_read_addr_b <= to_integer(unsigned(current_instruction(1 downto 0)));
-- DON'T read operand1/operand2 yet, need to wait 1 cycle for register read
-- Will read in EXECUTE state
```

### 4. No EXECUTE (operações ULA):
**Antes:**
```vhdl
ULA_A <= operand1;
ULA_B <= operand2;
```

**Depois:**
```vhdl
if needs_value1 = '0' and needs_value2 = '0' then
    -- Both operands from math registers (read NOW, after 1 cycle delay)
    ULA_A <= math_read_data_a;
    ULA_B <= math_read_data_b;
else
    -- Operands already loaded from immediate values
    ULA_A <= operand1;
    ULA_B <= operand2;
end if;
```

## Resultado Esperado

Agora o programa deve executar corretamente:

```
LOAD r1, 2   → mem_regs[0] = 2  ✅
LOAD r2, 3   → mem_regs[1] = 3  ✅
LOAD x, r1   → math_regs[0] = 2  ✅
LOAD y, r2   → math_regs[1] = 3  ✅ CORRETO!
SUM x, y     → 2 + 3 = 5  ✅ CORRETO!
```

## Lições Aprendidas

### Regra de Ouro em VHDL:
**Componentes síncronos precisam de 1 ciclo de clock para propagar dados!**

- ROM: `rom_addr` → espera 1 ciclo → `instruction` válida
- Registradores: `read_addr` → espera 1 ciclo → `read_data` válido
- ULA: `permission='1'` → espera N ciclos → `finished='1'` e `output` válido

### Estratégia de Correção:
1. Configurar endereços/controles em um estado
2. Aguardar 1 ciclo (transição de estado)
3. Ler dados no próximo estado

### Casos Especiais:
- Valores imediatos: Já estão em `operand1`/`operand2` (lidos de ROM com espera)
- Registradores: Devem ser lidos **no EXECUTE** usando `math_read_data_a/b` ou `mem_read_data_a/b`

Isso garante que os dados síncronos sejam lidos após propagação! 🎯
