# SOLUÇÃO PARA ERROS DE CARACTERES ESPECIAIS NO EDA PLAYGROUND

## Problema

Você está vendo erros como:
```
COMP96 ERROR COMP96_0696: "Illegal non-graphic character (<0x9c>)."
COMP96 ERROR COMP96_0696: "Illegal non-graphic character (<0x85>)."
COMP96 ERROR COMP96_0696: "Illegal non-graphic character (<0x86>)."
COMP96 ERROR COMP96_0696: "Illegal non-graphic character (<0x92>)."
```

Isso acontece porque o EDA Playground está carregando a **versão ANTIGA** do arquivo com caracteres Unicode (aspas curvas, travessões).

## Solução Rápida

### No EDA Playground:

1. **DELETE o arquivo testbench_C_UNIT_standalone.vhd** do EDA Playground
2. Clique em "+ Add File"
3. Nomeie: `testbench_C_UNIT_standalone.vhd`
4. **Copie o conteúdo do arquivo limpo** (abaixo)
5. Cole no EDA Playground
6. Salve

### Também DELETE e recrie:

- **C_UNIT.vhd** - pode ter caracteres especiais nos comentários
- **testbench_PROCESSOR.vhd** - também tinha aspas curvas

## Arquivos Limpos para Copiar

Os arquivos limpos estão em:
- `/Users/marcusvinicius/Documents/GitHub/Processador/Testbench's/testbench_C_UNIT_standalone.vhd`
- `/Users/marcusvinicius/Documents/GitHub/Processador/Testbench's/testbench_PROCESSOR.vhd`
- `/Users/marcusvinicius/Documents/GitHub/Processador/Entitys/C_UNIT.vhd`

## Verificação

Depois de recarregar, você **NÃO deve ver mais** nenhum erro de "Illegal non-graphic character".

## Ordem de Carregamento Correta

Depois de ter todos os arquivos limpos:

1. ULA.vhd (e dependências)
2. pack_register_mem.vhd
3. pack_register_math.vhd
4. archive.vhd
5. C_UNIT.vhd
6. testbench_C_UNIT_standalone.vhd (TOP ENTITY)

## Outros Erros no Log

Você também tem:
```
COMP96 ERROR COMP96_0016: "Design unit declaration expected." "testbench.vhd" 4 0
COMP96 ERROR COMP96_0016: "Design unit declaration expected." "design.vhd" 4 0
```

**REMOVA estes arquivos do EDA Playground:**
- ❌ testbench.vhd (arquivo padrão do EDA, não use)
- ❌ design.vhd (arquivo padrão do EDA, não use)

Eles interferem com a compilação.

## Checklist Final

- [ ] Todos os arquivos .vhd padrão do EDA Playground foram removidos
- [ ] testbench_C_UNIT_standalone.vhd foi RE-CARREGADO com conteúdo limpo
- [ ] C_UNIT.vhd foi RE-CARREGADO com conteúdo limpo
- [ ] Apenas UM testbench está carregado (testbench_C_UNIT_standalone)
- [ ] Top entity = testbench_C_UNIT_standalone
- [ ] Arquivos na ordem correta (dependências primeiro)
