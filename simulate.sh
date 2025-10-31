#!/bin/bash

# Script para compilar e simular o processador com GHDL
# Autor: Sistema de Processador 8-bits
# Data: 31 de Outubro de 2025

echo "=================================================="
echo "  SIMULAÇÃO DO PROCESSADOR COM GHDL"
echo "=================================================="
echo ""

# Configurações
WORK_DIR="work"
ENTITY_DIR="Entitys"
TESTBENCH_DIR="Testbench's"
TESTBENCH="testbench_PROCESSOR"
STOP_TIME="2us"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Cria diretório de trabalho
mkdir -p "$WORK_DIR"

echo "🔧 Verificando GHDL..."
if ! command -v ghdl &> /dev/null; then
    echo -e "${RED}❌ ERRO: GHDL não está instalado${NC}"
    echo ""
    echo "Para instalar o GHDL:"
    echo "  macOS: brew install ghdl"
    echo "  Linux: sudo apt-get install ghdl"
    echo ""
    exit 1
fi
echo -e "${GREEN}✅ GHDL encontrado${NC}"
echo ""

# Lista de arquivos para compilar (ordem importa!)
FILES=(
    # Packages primeiro
    "$TESTBENCH_DIR/packages.vhd"
    
    # Componentes básicos
    "$ENTITY_DIR/C2.vhd"
    "$ENTITY_DIR/sum.vhd"
    "$ENTITY_DIR/sub.vhd"
    "$ENTITY_DIR/comp.vhd"
    "$ENTITY_DIR/bit_wise.vhd"
    "$ENTITY_DIR/mult.vhd"
    "$ENTITY_DIR/DIV_MOD.vhd"
    "$ENTITY_DIR/l_shift.vhd"
    "$ENTITY_DIR/r_shift.vhd"
    
    # ULA (usa os componentes acima)
    "$ENTITY_DIR/ULA.vhd"
    
    # ROM
    "$ENTITY_DIR/archive.vhd"
    
    # Unidade de Controle (usa ULA e ROM)
    "$ENTITY_DIR/C_UNIT.vhd"
    
    # Testbench
    "$TESTBENCH_DIR/$TESTBENCH.vhd"
)

echo "📚 Compilando arquivos VHDL..."
echo ""

COMPILE_SUCCESS=true

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -n "  Compilando $(basename "$file")... "
        if ghdl -a --workdir="$WORK_DIR" "$file" 2>&1 | grep -i error; then
            echo -e "${RED}❌ FALHOU${NC}"
            COMPILE_SUCCESS=false
        else
            echo -e "${GREEN}✅${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Arquivo não encontrado: $file${NC}"
    fi
done

echo ""

if [ "$COMPILE_SUCCESS" = false ]; then
    echo -e "${RED}❌ Compilação falhou. Verifique os erros acima.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Todos os arquivos compilados com sucesso${NC}"
echo ""

# Elabora o testbench
echo "🔗 Elaborando testbench..."
if ! ghdl -e --workdir="$WORK_DIR" "$TESTBENCH"; then
    echo -e "${RED}❌ Falha na elaboração${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Elaboração bem-sucedida${NC}"
echo ""

# Executa a simulação
echo "=================================================="
echo "  EXECUTANDO SIMULAÇÃO"
echo "=================================================="
echo ""

ghdl -r --workdir="$WORK_DIR" "$TESTBENCH" --stop-time="$STOP_TIME" --wave=simulation.ghw

SIMULATION_STATUS=$?

echo ""
echo "=================================================="

if [ $SIMULATION_STATUS -eq 0 ]; then
    echo -e "${GREEN}✅ SIMULAÇÃO CONCLUÍDA COM SUCESSO${NC}"
    echo "=================================================="
    echo ""
    echo "📊 Arquivo de waveform gerado: simulation.ghw"
    echo ""
    echo "Para visualizar o waveform:"
    echo "  gtkwave simulation.ghw"
    echo ""
else
    echo -e "${RED}❌ SIMULAÇÃO FALHOU${NC}"
    echo "=================================================="
    echo ""
fi

echo "Arquivos gerados:"
echo "  - simulation.ghw (waveform)"
echo "  - work/ (arquivos compilados)"
echo ""
