# Correções de Bugs Adicionais - Testes 11 e 12

## 🐛 Bug 1: SUB com Valor Imediato (Teste 11)

### Problema
```
Instrução: 0xBD 0x0F  (SUB x, 15)
Esperado: x = 50 - 15 = 35
Log: ULA: A=147 B=0 OP=1  ← B deveria ser 15!
```

### Causa
Caso misto não tratado:
- `needs_value1='0'` (A vem de registrador)
- `needs_value2='1'` (B vem de imediato)

### Solução
Adicionado no EXECUTE:
```vhdl
elsif needs_value1 = '0' and needs_value2 = '1' then
    ULA_A <= math_read_data_a;  -- Registrador
    ULA_B <= operand2;          -- Imediato
```

---

## 🐛 Bug 2: Cópia entre Memory Registers (Teste 12)

### Problema
```
Instrução: 0x31 (LOAD r1, r2)
Vai direto para FETCH sem copiar!
```

### Causa
Lendo `mem_read_data_a` imediatamente após configurar `mem_read_addr_a` (timing bug).

### Solução
**DECODE:** Vai para EXECUTE em vez de FETCH  
**EXECUTE:** Lê `mem_read_data_a` após 1 ciclo

---

## ⚠️ Limitação Descoberta

**Não é possível fazer LOAD r1, r1** com este encoding!

Quando bits 1-0 = bits 3-2 em 0x3X, o processador assume **valor imediato**.

Exemplo:
- 0x30 = LOAD r1, [próximo byte] (imediato)
- 0x35 = LOAD r2, [próximo byte] (imediato)

**Autocopia não é suportada** pelo encoding atual. Design está correto.

---

## ✅ Status

Bugs corrigidos! Teste 11 e 12 devem funcionar agora.
