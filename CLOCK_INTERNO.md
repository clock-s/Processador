# Clock Interno do C_UNIT

## Visão Geral

O C_UNIT agora possui um **gerador de clock interno** que permite testá-lo de forma isolada, sem precisar de um testbench externo com gerador de clock.

## Novos Sinais

### Porta `use_internal_clock`
- **Tipo**: `std_logic`
- **Default**: `'1'`
- **Função**: Seleciona entre clock interno ou externo
  - `'1'` = Usa clock interno (20ns de período - 10ns LOW, 10ns HIGH)
  - `'0'` = Usa clock externo fornecido na porta `clock`

### Porta `clock`
- **Tipo**: `std_logic`
- **Default**: `'0'`
- **Função**: Clock externo (usado somente quando `use_internal_clock = '0'`)

## Modos de Uso

### Modo 1: Clock Interno (Standalone)

```vhdl
-- Instancia C_UNIT com clock interno
C_UNIT_INSTANCE: C_UNIT port map (
    use_internal_clock => '1',  -- Habilita clock interno
    reset => reset_signal,
    debug_pc => pc_value,
    debug_state => state_value
);
```

**Vantagens:**
- Não precisa gerar clock no testbench
- Mais simples para testes rápidos
- Ideal para EDA Playground

### Modo 2: Clock Externo (Integração)

```vhdl
-- Gerador de clock externo no testbench
CLOCK_PROC: process
begin
    clock <= '0';
    wait for 10 ns;
    clock <= '1';
    wait for 10 ns;
end process;

-- Instancia C_UNIT com clock externo
C_UNIT_INSTANCE: C_UNIT port map (
    clock => clock,
    use_internal_clock => '0',  -- Desabilita clock interno
    reset => reset_signal,
    debug_pc => pc_value,
    debug_state => state_value
);
```

**Vantagens:**
- Controle total sobre a frequência do clock
- Melhor para integração com outros componentes
- Permite sincronização com outros módulos

## Testbench Standalone

Foi criado um testbench de exemplo: `testbench_C_UNIT_standalone.vhd`

Este testbench:
- ✅ Usa o clock interno do C_UNIT
- ✅ Aplica reset inicial
- ✅ Monitora estado e PC
- ✅ Não precisa de gerador de clock externo

## Exemplo para EDA Playground

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity simple_test is
end simple_test;

architecture TB of simple_test is
    signal reset : std_logic := '0';
    signal debug_pc : integer range 0 to 255;
    signal debug_state : std_logic_vector(2 downto 0);
begin
    
    -- C_UNIT com clock interno
    CPU: entity work.C_UNIT 
        port map (
            use_internal_clock => '1',
            reset => reset,
            debug_pc => debug_pc,
            debug_state => debug_state
        );
    
    process
    begin
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 1000 ns;
        report "FIM";
        wait;
    end process;
    
end TB;
```

## Frequência do Clock Interno

- **Período**: 20 ns
- **Frequência**: 50 MHz
- **Duty Cycle**: 50% (10ns LOW, 10ns HIGH)

Se precisar de outra frequência, edite o processo `CLOCK_GEN` em `C_UNIT.vhd`:

```vhdl
CLOCK_GEN: process
begin
    if use_internal_clock = '1' then
        internal_clock <= '0';
        wait for 10 ns;  -- <-- Altere aqui para LOW
        internal_clock <= '1';
        wait for 10 ns;  -- <-- Altere aqui para HIGH
    else
        wait;
    end if;
end process CLOCK_GEN;
```

## Compatibilidade

O C_UNIT mantém **100% de compatibilidade** com código existente:
- Testbenches antigos continuam funcionando
- Se não especificar `use_internal_clock`, usa clock interno por padrão
- Pode ignorar as novas portas se não precisar delas

## Debugging

Os sinais de debug permitem monitorar o estado interno:

```vhdl
-- Estados possíveis
"000" => FETCH
"001" => DECODE  
"010" => GET_VALUE1
"011" => GET_VALUE2
"100" => EXECUTE
"101" => WRITE_BACK
"111" => HALT
```

Exemplo de uso:
```vhdl
process(debug_state)
begin
    case debug_state is
        when "000" => report "FETCH em PC=" & integer'image(debug_pc);
        when "001" => report "DECODE";
        when "100" => report "EXECUTE";
        when "101" => report "WRITE_BACK";
        when others => null;
    end case;
end process;
```
