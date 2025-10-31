# 🎮 Guia Completo: Como Testar o Processador no EDA Playground

## 📋 Passo a Passo Detalhado

### 1️⃣ Acessar o EDA Playground

1. Acesse: https://www.edaplayground.com/
2. Faça login (ou use como visitante)
3. Clique em "Create New Playground"

---

## 2️⃣ Configurar o Ambiente

### Configurações Principais (no painel direito):

- **Testbench + Design**: Selecione esta opção
- **Languages & Libraries**: 
  - Selecione **VHDL**
- **Tools & Simulators**:
  - Selecione **Aldec Riviera-Pro 2023.04** (recomendado)
  - Ou **ModelSim** (alternativa)
- **Compile & Run Options**:
  - Deixe em branco ou adicione: `-2008` (para VHDL-2008)

---

## 3️⃣ Preparar os Arquivos

### O EDA Playground tem limitações:
- ❌ Não pode ter múltiplos arquivos separados facilmente
- ✅ Solução: Criar um arquivo único com todas as entities
- ✅ Usar `configuration` para especificar ordem de compilação

---

## 4️⃣ Arquivo teste.bin (Programa do Processador)

**IMPORTANTE**: O EDA Playground precisa do arquivo `teste.bin` carregado.

### Opção A: Criar o arquivo manualmente

1. No EDA Playground, clique em **"+"** ao lado de "testbench.vhd"
2. Crie um arquivo chamado **"teste.bin"**
3. Cole o seguinte conteúdo:

```
01
6D
0A
64
05
60
20
6D
14
64
08
B0
25
6D
06
64
07
70
2A
3F
10
3A
00
00
00
```

### Opção B: Usar um programa já compilado

Se você já compilou o programa localmente:
1. Copie o conteúdo do arquivo `Compiler/teste.bin`
2. Cole no EDA Playground

---

## 5️⃣ Código Completo para o EDA Playground

### 📄 No campo "testbench.vhd":

Vou criar um arquivo unificado que você pode copiar e colar diretamente!

---

## 6️⃣ Estrutura de Arquivos no EDA Playground

```
EDA Playground Project/
├── testbench.vhd          ← Código principal (tudo em um arquivo)
└── teste.bin              ← Programa em hexadecimal
```

---

## 7️⃣ Como Executar

1. ✅ Certifique-se de que ambos arquivos estão carregados
2. ✅ Verifique as configurações (VHDL + Riviera-Pro)
3. ✅ Clique em **"Run"** (botão verde)
4. ✅ Aguarde a compilação e execução
5. ✅ Veja os resultados no console

---

## 8️⃣ O Que Esperar na Saída

Você verá algo como:

```
# =================================================
#     INICIANDO TESTE DO PROCESSADOR
# =================================================
# 
# Removendo reset - Processador iniciando...
# 
# =================================================
#     EXECUTANDO PROGRAMA
# =================================================
# 
# Clock 1 | PC: 0 | State: FETCH
# Clock 2 | PC: 1 | State: DECODE
# Clock 3 | PC: 1 | State: FETCH
# ...
# 
# =================================================
#     TESTE CONCLUÍDO
# =================================================
# 
# Processador executou 26 instruções
```

---

## 9️⃣ Visualizar Waveforms

### No EDA Playground:

1. Após executar com sucesso
2. Clique em **"Open EPWave"** (botão azul)
3. Selecione os sinais que deseja visualizar:
   - `clk` - Clock
   - `pc_out` - Program Counter
   - `state_out` - Estado da máquina
   - Sinais internos da UUT

---

## 🔟 Troubleshooting (Resolução de Problemas)

### ❌ Erro: "teste.bin not found"
**Solução**: Certifique-se de criar o arquivo teste.bin com o nome exato

### ❌ Erro de compilação
**Solução**: Verifique se todo o código está em um único arquivo

### ❌ Timeout
**Solução**: Reduza o tempo de simulação (mude `200` para `100` no testbench)

### ❌ Sinais não aparecem no waveform
**Solução**: Verifique se está usando Riviera-Pro e se os sinais estão declarados

---

## 📊 Programa de Teste (teste.bin explicado)

```assembly
# Linha | Hex  | Instrução      | Descrição
----------------------------------------------
1       | 01   | RES            | Reset registradores
2-3     | 6D0A | LOAD x, 10     | x = 10
4-5     | 6405 | LOAD y, 5      | y = 5  
6       | 60   | SUM x, y       | x = x + y = 15
7       | 20   | LOAD r1, x     | r1 = 15
8-9     | 6D14 | LOAD x, 20     | x = 20
10-11   | 6408 | LOAD y, 8      | y = 8
12      | B0   | SUB x, y       | x = x - y = 12
13      | 25   | LOAD r2, x     | r2 = 12
14-15   | 6D06 | LOAD x, 6      | x = 6
16-17   | 6407 | LOAD y, 7      | y = 7
18      | 70   | MULT x, y      | x = x * y = 42
19      | 2A   | LOAD r3, x     | r3 = 42
20-21   | 3F10 | LOAD r4, r1    | r4 = r1 = 15
22      | 3A   | LOAD r3, r4    | Erro: deveria ser 1A (LOAD z, r4)
23-25   | 000000 | NOP x3       | Pausa
```

---

## 🎯 Resultados Esperados

Após a simulação completa:

| Registrador | Valor Esperado | Hexadecimal |
|-------------|----------------|-------------|
| x           | 42             | 0x2A        |
| y           | 7              | 0x07        |
| z           | 15             | 0x0F        |
| w           | 0              | 0x00        |
| r1          | 15             | 0x0F        |
| r2          | 12             | 0x0C        |
| r3          | 42             | 0x2A        |
| r4          | 15             | 0x0F        |

---

## 🚀 Dicas para Uso no EDA Playground

### ✅ Boas Práticas:

1. **Salve seu trabalho**: Crie uma conta e salve o projeto
2. **Use nomes descritivos**: Nomeie seu projeto claramente
3. **Comente seu código**: Adicione comentários para entender depois
4. **Versione**: Faça cópias antes de grandes mudanças
5. **Compartilhe**: Use o link para compartilhar com seu professor

### ⚡ Atalhos Úteis:

- `Ctrl + S`: Salvar
- `F5` ou `Ctrl + R`: Executar simulação
- `Ctrl + /`: Comentar/descomentar linha

---

## 📱 Compartilhar Resultados

Após executar com sucesso:

1. Clique em **"Copy Project"** (canto superior)
2. Você receberá um link único
3. Compartilhe este link com seu professor
4. O link permanece ativo e pode ser executado novamente

Exemplo de link: `https://www.edaplayground.com/x/XXXXX`

---

## 🔍 Verificação Passo a Passo

### Checklist antes de executar:

- [ ] Arquivo testbench.vhd com todo o código
- [ ] Arquivo teste.bin criado e preenchido
- [ ] Linguagem selecionada: VHDL
- [ ] Simulador selecionado: Riviera-Pro ou ModelSim
- [ ] Tempo de simulação adequado (2us ou mais)

### Se tudo estiver OK:
- [ ] Clique em RUN
- [ ] Aguarde compilação (30-60 segundos)
- [ ] Verifique mensagens no console
- [ ] Abra waveforms se necessário

---

## 💡 Próximos Passos

Depois de testar no EDA Playground:

1. ✅ Experimente modificar o programa teste.bin
2. ✅ Teste diferentes instruções
3. ✅ Adicione mais operações
4. ✅ Crie loops e jumps
5. ✅ Teste casos extremos (overflow, divisão por zero, etc.)

---

## 📚 Recursos Adicionais

- **EDA Playground Docs**: https://www.edaplayground.com/help
- **VHDL Tutorial**: Acesse tutoriais integrados
- **Examples**: Explore exemplos públicos no EDA Playground

---

**Criado em**: 31 de Outubro de 2025  
**Versão**: 1.0  
**Para**: Testes do Processador 8-bits
