#!/bin/bash

# Script para compilar programa assembly e preparar para simulação
# Autor: Sistema de Processador 8-bits
# Data: 31 de Outubro de 2025

echo "=================================================="
echo "  COMPILADOR DE PROGRAMAS PARA O PROCESSADOR"
echo "=================================================="
echo ""

# Diretórios
COMPILER_DIR="./Compiler"
PROGRAM_FILE="${1:-teste_basico.gbf}"
OUTPUT_FILE="teste.bin"

# Verifica se o arquivo de entrada existe
if [ ! -f "$COMPILER_DIR/$PROGRAM_FILE" ]; then
    echo "❌ ERRO: Arquivo $PROGRAM_FILE não encontrado em $COMPILER_DIR/"
    echo ""
    echo "Uso: $0 [arquivo.gbf]"
    echo "Exemplo: $0 teste_basico.gbf"
    exit 1
fi

# Entra no diretório do compilador
cd "$COMPILER_DIR" || exit 1

echo "📝 Arquivo de entrada: $PROGRAM_FILE"
echo ""

# Compila o compilador se necessário
if [ ! -f "compiler" ]; then
    echo "🔨 Compilando o compilador C++..."
    g++ -o compiler compiler.cpp
    
    if [ $? -ne 0 ]; then
        echo "❌ ERRO: Falha ao compilar o compilador"
        exit 1
    fi
    echo "✅ Compilador C++ compilado com sucesso"
    echo ""
fi

# Executa o compilador
echo "⚙️  Compilando programa assembly..."
./compiler "$PROGRAM_FILE" "$OUTPUT_FILE"

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ ERRO: Falha ao compilar o programa"
    exit 1
fi

echo ""
echo "✅ Programa compilado com sucesso!"
echo ""
echo "📦 Arquivo binário gerado: $OUTPUT_FILE"
echo ""

# Mostra o conteúdo do arquivo binário
echo "📋 Conteúdo do arquivo binário (hexadecimal):"
echo "--------------------------------------------"
cat "$OUTPUT_FILE"
echo "--------------------------------------------"
echo ""

# Conta instruções
NUM_BYTES=$(wc -l < "$OUTPUT_FILE")
echo "📊 Total de bytes: $NUM_BYTES"
echo ""

echo "✅ Pronto para simulação!"
echo ""
echo "Próximos passos:"
echo "  1. Certifique-se de que teste.bin está em Compiler/"
echo "  2. Execute a simulação com seu simulador VHDL preferido"
echo "  3. Use o testbench: testbench_PROCESSOR.vhd"
echo ""

cd - > /dev/null
