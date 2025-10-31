# Guia para EDA Playground - ORDEM CORRETA

## PROBLEMA COMUM: "Design unit declaration expected"

Esse erro acontece quando você tenta compilar um arquivo que usa componentes que ainda não foram declarados.

## SOLUÇÃO: Ordem de Carregamento

No EDA Playground, você deve carregar os arquivos **de baixo para cima** na hierarquia:

### 1. Componentes Básicos (Base da Hierarquia)

```
Arquivo: sum.vhd
Arquivo: sub.vhd
Arquivo: mult.vhd
Arquivo: DIV_MOD.vhd
Arquivo: bit_wise.vhd
Arquivo: l_shift.vhd
Arquivo: r_shift.vhd
Arquivo: comp.vhd
Arquivo: parity.vhd
```

### 2. ULA (Usa os componentes acima)

```
Arquivo: ULA.vhd
```

### 3. Registradores

```
Arquivo: u_register.vhd
Arquivo: pack_register_mem.vhd
Arquivo: pack_register_math.vhd
```

### 4. Memória ROM

```
Arquivo: archive.vhd
```

### 5. Unidade de Controle (Usa TUDO acima)

```
Arquivo: C_UNIT.vhd
```

### 6. Testbench (TOP ENTITY)

```
Arquivo: testbench_C_UNIT_standalone.vhd
```

## CONFIGURAÇÃO NO EDA PLAYGROUND

1. Clique em "+ Add File" para cada arquivo
2. Carregue na ordem acima
3. Em "Settings":
   - Testbench + Design: **testbench_C_UNIT_standalone**
   - Language: **VHDL**
   - VHDL Version: **VHDL-93** ou **VHDL-2002**
   - Simulator: **ModelSim** ou **GHDL**
4. Run Time: **2000 ns**
5. Clique em "Run"

## TESTE MÍNIMO (Se houver muitos erros)

Se ainda houver erros, comece com um teste mínimo:

### Arquivos Mínimos para Testar C_UNIT:

1. **archive.vhd** (ROM com programa teste)
2. **pack_register_mem.vhd** (registradores r1-r4)
3. **pack_register_math.vhd** (registradores x-w)
4. **ULA.vhd** + dependências
5. **C_UNIT.vhd**
6. **testbench_C_UNIT_standalone.vhd**

### Verificando Erros de Codificação

Se ainda der "Design unit declaration expected" na linha 1:
- O arquivo pode ter BOM (Byte Order Mark)
- Ou caracteres Unicode invisíveis
- Solução: Copie o conteúdo para um editor de texto puro, salve como ASCII

## RESULTADO ESPERADO

Após compilação bem-sucedida, você deve ver:
```
COMP96 Entity => archive
COMP96 Entity => PACK_REGISTER_MEM  
COMP96 Entity => PACK_REGISTER_MATH
COMP96 Entity => ULA
COMP96 Entity => C_UNIT
COMP96 Entity => testbench_C_UNIT_standalone
COMP96 Compile Architecture "TB" of Entity "testbench_C_UNIT_standalone"
COMP96 Compile success 0 Errors 0 Warnings
```

Na simulação, você deve ver reports mostrando:
```
=== INICIANDO TESTE DO PROCESSADOR (CLOCK INTERNO) ===
Reset liberado. Processador executando programa...
PC=0 Estado: FETCH
PC=1 Estado: DECODE
PC=1 Estado: GET_VALUE1
...
=== TESTE CONCLUIDO ===
```

## CHECKLIST

- [ ] Todos os arquivos estão em ASCII puro (sem BOM, sem acentos)
- [ ] Arquivos carregados na ordem correta (dependências primeiro)
- [ ] Top entity definida como testbench_C_UNIT_standalone
- [ ] VHDL-93 ou VHDL-2002 selecionado
- [ ] Run time >= 2000ns
