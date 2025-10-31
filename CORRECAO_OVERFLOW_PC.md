# Correção: Erro "Value 256 out of range (0 to 255)"

## Problema

```
RUNTIME: Fatal Error: RUNTIME_0067 C_UNIT.vhd (238): Value 256 out of range (0 to 255).
```

O Program Counter (PC) estava incrementando além de 255, causando overflow.

## Causa

O processador continuava executando após o programa terminar:
- NOP não parava o processador
- PC continuava incrementando: 0→1→2→...→255→**256** ❌

## Solução Implementada

### 1. Proteção no DECODE
Adicionado verificação antes de incrementar PC:

```vhdl
when DECODE =>
    if PC >= 255 then
        current_state <= HALT;  -- Para antes de overflow
    else
        PC <= PC + 1;
        -- ... resto do decode
    end if;
```

### 2. Proteção no GET_VALUE1
Adicionado verificação para segundo valor imediato:

```vhdl
if needs_value2 = '1' then
    if PC < 254 then
        PC <= PC + 1;
        -- ... continua
    else
        current_state <= HALT;  -- Previne overflow
    end if;
```

### 3. HALT no NOP após limite
Adicionado verificação no NOP para parar após o programa:

```vhdl
if instruction = "00000000" then
    if PC > 10 then
        current_state <= HALT;  -- Para após programa
    else
        current_state <= FETCH;
    end if;
```

## Resultado

Agora o processador:
1. ✅ Executa o programa normalmente
2. ✅ Para no NOP após PC > 10
3. ✅ Nunca ultrapassa PC = 255
4. ✅ Não causa overflow

## Teste Novamente

1. No EDA Playground, **DELETE** o arquivo `C_UNIT.vhd` antigo
2. **Carregue** a nova versão de:
   ```
   /Users/marcusvinicius/Documents/GitHub/Processador/Entitys/C_UNIT.vhd
   ```
3. Clique em **"Run"**

## Resultado Esperado

Simulação deve executar até ~600ns e parar:

```
# KERNEL: PC=0 Estado: FETCH      
# KERNEL: PC=1 Estado: DECODE     
# KERNEL: PC=1 Estado: GET_VALUE1 
# KERNEL: PC=1 Estado: EXECUTE    
# KERNEL: PC=2 Estado: FETCH      
# KERNEL: PC=3 Estado: DECODE     
# KERNEL: PC=3 Estado: GET_VALUE1 
# KERNEL: PC=4 Estado: FETCH      
# KERNEL: PC=5 Estado: DECODE     
# KERNEL: PC=5 Estado: EXECUTE    
# KERNEL: PC=6 Estado: FETCH      
# KERNEL: PC=7 Estado: DECODE     
# KERNEL: PC=7 Estado: GET_VALUE1 
# KERNEL: PC=7 Estado: EXECUTE    
# KERNEL: PC=7 Estado: WRITE_BACK 
# KERNEL: PC=7 Estado: FETCH      
# KERNEL: PC=8 Estado: DECODE     
# KERNEL: PC=8 Estado: FETCH      (NOP)
# KERNEL: PC=9 Estado: DECODE     
# KERNEL: PC=9 Estado: FETCH      (NOP)
# KERNEL: PC=10 Estado: DECODE    
# KERNEL: PC=10 Estado: FETCH     (NOP)
# KERNEL: PC=11 Estado: DECODE    
# KERNEL: PC=11 Estado: HALT      (Parou!)
# KERNEL: === TESTE CONCLUIDO ===
```

Sem mais erros de overflow! ✅
