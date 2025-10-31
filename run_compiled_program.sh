#!/bin/bash

# Script para compilar e simular programa do compilador
# Usa GHDL para compilação e simulação

echo "================================================="
echo "  SIMULADOR DE PROGRAMA COMPILADO"
echo "================================================="
echo ""

# Diretórios
ENTITY_DIR="Entitys"
TESTBENCH_DIR="Testbench's"
COMPILER_DIR="Compiler"
WORK_DIR="work_sim"

# Arquivos
BIN_FILE="teste.bin"
ARCHIVE_FILE="archive_bin.vhd"

# Limpar diretório de trabalho
echo "1. Limpando diretório de trabalho..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Copiar arquivo .bin para o diretório de trabalho
echo "2. Copiando arquivo binário..."
if [ ! -f "../$COMPILER_DIR/$BIN_FILE" ]; then
    echo "ERRO: Arquivo $BIN_FILE não encontrado em $COMPILER_DIR/"
    exit 1
fi
cp "../$COMPILER_DIR/$BIN_FILE" .
echo "   Arquivo $BIN_FILE copiado"

# Verificar conteúdo do arquivo
echo ""
echo "3. Conteúdo do programa (hexadecimal):"
echo "   ----------------------------------------"
hexdump -C "$BIN_FILE" | head -20
echo "   ----------------------------------------"
echo ""

# Análise do programa
echo "4. Análise do programa:"
echo "   Bytes: $(wc -l < $BIN_FILE)"
echo ""

# Compilar componentes na ordem correta
echo "5. Compilando componentes VHDL..."

# Packages
echo "   - Compilando packages..."
ghdl -a --std=02 ../$TESTBENCH_DIR/packages.vhd 2>/dev/null

# ULA components
echo "   - Compilando componentes da ULA..."
ghdl -a --std=02 ../$ENTITY_DIR/sum.vhd
ghdl -a --std=02 ../$ENTITY_DIR/sub.vhd
ghdl -a --std=02 ../$ENTITY_DIR/mult.vhd
ghdl -a --std=02 ../$ENTITY_DIR/DIV_MOD.vhd
ghdl -a --std=02 ../$ENTITY_DIR/comp.vhd
ghdl -a --std=02 ../$ENTITY_DIR/bit_wise.vhd
ghdl -a --std=02 ../$ENTITY_DIR/l_shift.vhd
ghdl -a --std=02 ../$ENTITY_DIR/r_shift.vhd
ghdl -a --std=02 ../$ENTITY_DIR/parity.vhd

# ULA
echo "   - Compilando ULA..."
ghdl -a --std=02 ../$ENTITY_DIR/ULA.vhd

# Registers
echo "   - Compilando registradores..."
ghdl -a --std=02 ../$ENTITY_DIR/u_register.vhd
ghdl -a --std=02 ../$ENTITY_DIR/pack_register_mem.vhd
ghdl -a --std=02 ../$ENTITY_DIR/pack_register_math.vhd

# ROM (usando archive_bin.vhd que lê do arquivo)
echo "   - Compilando ROM (archive_bin.vhd)..."
ghdl -a --std=02 ../$ENTITY_DIR/$ARCHIVE_FILE

# Control Unit
echo "   - Compilando Control Unit..."
# Criar versão temporária do C_UNIT que usa archive_bin
sed 's/component archive/component archive/' ../$ENTITY_DIR/C_UNIT.vhd > C_UNIT_temp.vhd
ghdl -a --std=02 C_UNIT_temp.vhd

# Testbench
echo "   - Compilando Testbench..."
ghdl -a --std=02 ../$TESTBENCH_DIR/testbench_COMPILER_BIN.vhd

# Elaborar
echo ""
echo "6. Elaborando design..."
ghdl -e --std=02 testbench_COMPILER_BIN

# Executar simulação
echo ""
echo "7. Executando simulação..."
echo "================================================="
echo ""
ghdl -r --std=02 testbench_COMPILER_BIN --stop-time=2000ns --wave=waveform.ghw

# Verificar se gerou waveform
if [ -f "waveform.ghw" ]; then
    echo ""
    echo "================================================="
    echo "  SIMULAÇÃO CONCLUÍDA"
    echo "================================================="
    echo ""
    echo "Arquivo de waveform gerado: work_sim/waveform.ghw"
    echo ""
    echo "Para visualizar a forma de onda, execute:"
    echo "  cd work_sim"
    echo "  gtkwave waveform.ghw"
    echo ""
else
    echo ""
    echo "AVISO: Arquivo de waveform não foi gerado"
fi

cd ..
