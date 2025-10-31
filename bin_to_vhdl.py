#!/usr/bin/env python3
"""
Conversor de .bin para ROM VHDL (EDA Playground)

Converte arquivo .bin do compilador em código VHDL hardcoded
pronto para usar no EDA Playground (que não suporta leitura de arquivos).

Uso: python3 bin_to_vhdl.py <arquivo.bin>
"""

import sys
import os

def read_bin_file(filename):
    """Lê arquivo .bin e retorna lista de bytes em hexadecimal"""
    bytes_list = []
    
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if line:  # Ignora linhas vazias
                # Cada linha deve conter 2 caracteres hex
                if len(line) == 2:
                    bytes_list.append(line.upper())
                else:
                    print(f"AVISO: Linha inválida ignorada: {line}")
    
    return bytes_list

def generate_vhdl_rom(bytes_list, rom_name="archive"):
    """Gera código VHDL da ROM com os bytes fornecidos"""
    
    vhdl_code = f"""library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ROM gerada automaticamente de arquivo .bin
-- Total de bytes: {len(bytes_list)}

entity {rom_name} is port(
    data : out std_logic_vector (7 downto 0);
    addr : in integer range 0 to 255
);
end {rom_name};

architecture {rom_name}_function of {rom_name} is
    type memory_array is array (0 to 255) of std_logic_vector (7 downto 0);
    signal memory : memory_array := (
"""
    
    # Adiciona cada byte
    for i, byte in enumerate(bytes_list):
        vhdl_code += f'        {i} => x"{byte}"'
        if i < len(bytes_list) - 1:
            vhdl_code += ","
        
        # Adiciona comentário com decodificação básica
        comment = decode_instruction(i, byte, bytes_list)
        if comment:
            vhdl_code += f"  -- {comment}"
        
        vhdl_code += "\n"
    
    # Preenche resto com zeros
    if len(bytes_list) < 256:
        vhdl_code += f"        others => x\"00\"\n"
    
    vhdl_code += """    );
begin
    data <= memory(addr);
end """ + rom_name + """_function;
"""
    
    return vhdl_code

def decode_instruction(addr, byte_hex, bytes_list):
    """Tenta decodificar a instrução para comentário"""
    byte_val = int(byte_hex, 16)
    
    # Verifica upper nibble
    upper = (byte_val >> 4) & 0x0F
    lower = byte_val & 0x0F
    
    # Decodificação básica
    if byte_val == 0x00:
        return "NOP/HALT"
    elif byte_val == 0x01:
        return "RES"
    elif byte_val == 0x02:
        return "RESF"
    elif upper == 0x1:
        return f"LOAD math_reg[{(lower>>2)&0x3}] <- mem_reg[{lower&0x3}]"
    elif upper == 0x2:
        return f"LOAD mem_reg[{lower&0x3}] <- math_reg[{(lower>>2)&0x3}]"
    elif upper == 0x3:
        if (lower >> 2) == (lower & 0x3):
            return f"LOAD mem_reg[{lower&0x3}] <- immediate (next byte)"
        else:
            return f"LOAD mem_reg[{(lower>>2)&0x3}] <- mem_reg[{lower&0x3}]"
    elif upper == 0x6:
        if lower == 0xE:
            return "SUM imm, imm"
        elif lower == 0xD:
            return "SUM x, imm"
        else:
            return f"SUM math_reg[{(lower>>2)&0x3}], math_reg[{lower&0x3}]"
    elif upper == 0x7:
        if lower == 0xE:
            return "MULT imm, imm"
        elif lower == 0xD:
            return "MULT x, imm"
        else:
            return f"MULT math_reg[{(lower>>2)&0x3}], math_reg[{lower&0x3}]"
    elif upper == 0x8:
        if lower == 0x9 or lower == 0xD:
            return "NOT"
        else:
            return "AND"
    elif upper == 0x9:
        return "OR or RSHIFT"
    elif upper == 0xA:
        return "XOR or RSHIFT"
    elif upper == 0xB:
        if lower == 0xE:
            return "SUB imm, imm"
        elif lower == 0xD:
            return "SUB x, imm"
        else:
            return f"SUB math_reg[{(lower>>2)&0x3}], math_reg[{lower&0x3}]"
    elif upper == 0xC:
        return "DIV or LSHIFT"
    elif upper == 0xD:
        return "MOD or LSHIFT"
    else:
        # Se for um valor pequeno após uma instrução LOAD immediate
        if addr > 0:
            prev_byte = int(bytes_list[addr-1], 16) if addr-1 < len(bytes_list) else 0
            prev_upper = (prev_byte >> 4) & 0x0F
            if prev_upper == 0x3 or prev_upper == 0x6 or prev_upper == 0x7 or prev_upper == 0xB:
                return f"immediate value = {byte_val}"
        return ""

def main():
    if len(sys.argv) < 2:
        print("Uso: python3 bin_to_vhdl.py <arquivo.bin> [arquivo_saida.vhd]")
        print("")
        print("Exemplo:")
        print("  python3 bin_to_vhdl.py Compiler/teste_debug.bin Entitys/archive_compiled.vhd")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    # Verifica se arquivo existe
    if not os.path.exists(input_file):
        print(f"ERRO: Arquivo '{input_file}' não encontrado!")
        sys.exit(1)
    
    print("=" * 60)
    print("  CONVERSOR .BIN -> VHDL ROM")
    print("=" * 60)
    print(f"\nArquivo de entrada: {input_file}")
    
    # Lê arquivo .bin
    bytes_list = read_bin_file(input_file)
    print(f"Total de bytes lidos: {len(bytes_list)}")
    
    if len(bytes_list) == 0:
        print("ERRO: Nenhum byte válido encontrado no arquivo!")
        sys.exit(1)
    
    print("\nConteúdo do programa:")
    print("-" * 60)
    for i, byte in enumerate(bytes_list):
        print(f"  [{i:3d}] 0x{byte}  {decode_instruction(i, byte, bytes_list)}")
    print("-" * 60)
    
    # Gera código VHDL
    vhdl_code = generate_vhdl_rom(bytes_list)
    
    # Salva ou imprime
    if output_file:
        with open(output_file, 'w') as f:
            f.write(vhdl_code)
        print(f"\n✓ Arquivo VHDL gerado: {output_file}")
        print(f"\nAgora você pode:")
        print(f"  1. Copiar {output_file} para o EDA Playground")
        print(f"  2. Modificar C_UNIT.vhd para usar 'archive' ao invés de 'archive_eda'")
        print(f"  3. Executar a simulação")
    else:
        print("\n" + "=" * 60)
        print("  CÓDIGO VHDL GERADO")
        print("=" * 60)
        print(vhdl_code)
        print("=" * 60)
        print("\nPara salvar em arquivo, execute:")
        print(f"  python3 bin_to_vhdl.py {input_file} arquivo_saida.vhd")

if __name__ == "__main__":
    main()
