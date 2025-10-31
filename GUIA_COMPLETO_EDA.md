# GUIA COMPLETO: EDA Playground - Passo a Passo

## PASSO 1: Limpar EDA Playground

No EDA Playground, **DELETE TODOS os arquivos**:
- Clique no X ao lado de cada arquivo
- Remova especialmente:
  - ❌ design.vhd (arquivo padrão)
  - ❌ testbench.vhd (arquivo padrão)
  - ❌ Qualquer testbench antigo
  - ❌ Todos os arquivos com erros

## PASSO 2: Adicionar Arquivos na Ordem Correta

### 2.1 - Componentes Base da ULA

Adicione estes arquivos (da pasta `Entitys/`):

```
1. sum.vhd
2. sub.vhd
3. mult.vhd
4. DIV_MOD.vhd
5. bit_wise.vhd
6. l_shift.vhd
7. r_shift.vhd
8. comp.vhd
9. parity.vhd
```

### 2.2 - ULA

```
10. ULA.vhd
```

### 2.3 - Registradores

```
11. u_register.vhd
12. pack_register_mem.vhd
13. pack_register_math.vhd
```

### 2.4 - Memória ROM

```
14. archive.vhd
```

### 2.5 - Unidade de Controle

```
15. C_UNIT.vhd
```

**IMPORTANTE:** Use a versão LIMPA sem acentos!
- Arquivo local: `/Users/marcusvinicius/Documents/GitHub/Processador/Entitys/C_UNIT.vhd`

### 2.6 - Testbench (TOP ENTITY)

```
16. testbench_C_UNIT_standalone.vhd
```

**IMPORTANTE:** Use a versão LIMPA sem aspas curvas!
- Arquivo local: `/Users/marcusvinicius/Documents/GitHub/Processador/Testbench's/testbench_C_UNIT_standalone.vhd`

## PASSO 3: Configurar Simulação

1. Em "Settings" (canto superior direito):
   - **Testbench + Design:** `testbench_C_UNIT_standalone`
   - **Language:** `VHDL`
   - **VHDL Version:** `VHDL-2002` ou `VHDL-93`
   - **Simulator:** `ModelSim` (recomendado) ou `GHDL`

2. Em "Time":
   - **Run Time:** `2000 ns` ou `2 us`

## PASSO 4: Compilar

1. Clique em **"Run"**
2. Aguarde a compilação

## PASSO 5: Verificar Resultado

### Compilação Bem-Sucedida

Você deve ver:
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

### Simulação Executando

No console, você deve ver:
```
# ==> Note: === INICIANDO TESTE DO PROCESSADOR (CLOCK INTERNO) ===
# ==> Note: Reset liberado. Processador executando programa...
# ==> Note: PC=0 Estado: FETCH
# ==> Note: PC=1 Estado: DECODE
# ==> Note: PC=1 Estado: GET_VALUE1
# ==> Note: PC=1 Estado: EXECUTE
# ==> Note: PC=1 Estado: WRITE_BACK
# ==> Note: PC=1 Estado: FETCH
# ==> Note: PC=2 Estado: DECODE
...
# ==> Note: === TESTE CONCLUIDO ===
```

## PASSO 6: Analisar Waveform

1. Clique em "Open EPWave" após a simulação
2. Adicione sinais importantes:
   - `debug_pc` - mostra o Program Counter
   - `debug_state` - mostra o estado atual
   - `DUT/PC` - Program Counter interno
   - `DUT/instruction` - Instrução atual
   - `DUT/mem_regs` (se visível) - Registradores r1-r4
   - `DUT/math_regs` (se visível) - Registradores x-w

## ERROS COMUNS

### "Illegal non-graphic character"
**Causa:** Arquivo com caracteres Unicode (aspas curvas, acentos)
**Solução:** Delete e re-carregue o arquivo da versão limpa local

### "Design unit declaration expected"
**Causa:** Arquivo na ordem errada ou arquivo padrão do EDA interferindo
**Solução:** 
- Delete design.vhd e testbench.vhd padrão
- Carregue arquivos na ordem correta (dependências primeiro)

### "Entity port length is X. Y length is Z"
**Causa:** Port map incorreto em algum testbench
**Solução:** Use apenas testbench_C_UNIT_standalone.vhd

### Múltiplos "Top-level unit(s) detected"
**Causa:** Vários testbenches carregados
**Solução:** Mantenha apenas UM testbench

## CHECKLIST FINAL

Antes de clicar "Run":
- [ ] Todos os arquivos padrão do EDA foram removidos
- [ ] 16 arquivos carregados na ordem correta
- [ ] Testbench C_UNIT_standalone é o último arquivo
- [ ] Top entity = testbench_C_UNIT_standalone
- [ ] VHDL-2002 ou VHDL-93 selecionado
- [ ] Run time >= 2000ns
- [ ] Nenhum arquivo com caracteres especiais

## ARQUIVOS LIMPOS (SEM CARACTERES ESPECIAIS)

Localizações dos arquivos corretos:
```
Entitys/C_UNIT.vhd                           <- Versão SEM acentos
Testbench's/testbench_C_UNIT_standalone.vhd  <- Versão SEM aspas curvas
Testbench's/testbench_PROCESSOR.vhd          <- Versão SEM aspas curvas
```

## SUCESSO!

Se tudo der certo, você verá:
- ✅ 0 Errors
- ✅ Simulação executa até o fim
- ✅ Mensagens de report no console
- ✅ Waveform disponível para análise
