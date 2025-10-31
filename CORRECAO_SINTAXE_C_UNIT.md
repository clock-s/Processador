# Correção: Erro de Sintaxe no C_UNIT.vhd

## Erro

```
COMP96 ERROR COMP96_0046: "Sequential statement expected." "C_UNIT.vhd" 480 25
COMP96 ERROR COMP96_0019: "Keyword 'end' expected." "C_UNIT.vhd" 548 25
```

## Causa

Erro de indentação no `end case;` do DECODE. O case statement estava dentro de um `if...else`, mas o `end case;` estava com indentação errada, sugerindo que estava fora do `else`.

## Estrutura Correta

```vhdl
when DECODE =>
    if PC >= 255 then
        current_state <= HALT;
    else
        -- ... setup ...
        PC <= PC + 1;
        
        case instruction(7 downto 4) is
            when "0000" => ...
            when "0001" => ...
            ...
            when others => ...
                current_state <= GET_VALUE1;
        
        end case;    -- Deve estar alinhado com 'case'
    end if;          -- Fecha o 'if PC >= 255'
```

## Correção Aplicada

Ajustei a indentação do `end case;` para o nível correto:

**Antes:**
```vhdl
                        end case;  -- Indentação errada (8 espaços a mais)
                    end if;
```

**Depois:**
```vhdl
                    end case;      -- Indentação correta
                    end if;
```

## Teste Novamente

1. No EDA Playground, **delete** o `C_UNIT.vhd` antigo
2. **Carregue** a versão corrigida:
   ```
   /Users/marcusvinicius/Documents/GitHub/Processador/Entitys/C_UNIT.vhd
   ```
3. Clique em **"Run"**

Agora deve compilar sem erros de sintaxe! ✅
