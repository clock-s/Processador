#include <iostream>
#include <cstdint>
#include <map>
#include <cctype>

using namespace std;


const string memory_registers = "r1 r2 r3 r4";
const string math_registers = "x y z w";
const string special_registers = "a ma";
const string memory = "[ma]";

bool is_all_digits(string s){
    for(int i = 0 ; i < s.size() ; i++){
        if(s[i] == '-') continue;

        if(!isdigit(s[i])){
            return false;
        }
    }

    return true;
}

bool is_memory_register(string s){
    if(memory_registers.find(s) != string::npos) return true;
    return false;
}

bool is_math_register(string s){
    if(math_registers.find(s) != string::npos) return true;
    return false;
}

bool is_special_register(string s){
    if(special_registers.find(s) != string::npos) return true;
    return false;
}



int main(int argc, char const *argv[]){
    if(argc <= 2){
        printf("You need a file name for input and output\n");
        exit(-1);
    }


    string name_input_file = argv[1];
    string name_output_file = argv[2];
    
    FILE *input_file;
    FILE *output_file;
    
    input_file = fopen(name_input_file.c_str(), "r");
    output_file = fopen(name_output_file.c_str(), "w");


    string operands;
    uint8_t opcode;

    /*
        00000000 = 0
        00000001 = 1
        00000010 = 2
        00000100 = 4
        00001000 = 8
        00010000 = 16
        00100000 = 32
        01000000 = 64
        10000000 = 128
    
    */

    
    

    map<string, uint8_t> registers_first_operand;
    registers_first_operand["r1"] = registers_first_operand["x"] = 0; //0000
    registers_first_operand["r2"] = registers_first_operand["y"] = 4; //0100
    registers_first_operand["r3"] = registers_first_operand["z"] = 8; //1000
    registers_first_operand["r4"] = registers_first_operand["w"] = 12; //1100
    registers_first_operand["a"] = registers_first_operand["ma"] = 128; // out of all ranges, dont had a pattern



    map<string, uint8_t> registers_second_operand;
    registers_second_operand["r1"] = registers_second_operand["x"] = 0; //0000
    registers_second_operand["r2"] = registers_second_operand["y"] = 1; //0001
    registers_second_operand["r3"] = registers_second_operand["z"] = 2; //0010
    registers_second_operand["r4"] = registers_second_operand["w"] = 3; //0011
    registers_second_operand["a"] = registers_second_operand["ma"] = 128; // out of all ranges
   

    size_t PC = 0;
    size_t line = 0;


    char caracter = '-';
    string instruction;
    

    while(!feof(input_file)){

        instruction.clear();
        opcode = 0;

        while(caracter != ';' && !feof(input_file)){
            caracter = fgetc(input_file);
            
            if(caracter != ' ' && caracter != '\n' && caracter != '\n')
                instruction.push_back(tolower(caracter));
            //cout << instruction << endl;
        }
        
        line++;

        caracter = '-';

        //cout << "Lido: " << instruction << " => ";


        if(instruction.size() > 1){
            

            //================================================ LOAD ================================================//
            if(instruction.find("load") != string::npos){
                uint8_t instruction_size = 4;
                uint8_t comma_index = -1;

                int8_t opcode_first_value = 0;
                int8_t opcode_second_value = 0;
                bool extern_value = false;

                string second_operand;
                

                
                operands = instruction.substr(instruction_size, instruction.size()- instruction_size - 1);
                instruction = instruction.substr(0, instruction_size);


                comma_index = operands.find(',');
                if(operands.find(',') == string::npos){
                    printf("Error in line %ld, miss a comma (,)\n", line);
                    exit(2);
                }

                second_operand = operands.substr(comma_index + 1, operands.size() - (comma_index + 1));
                operands = operands.substr(0, comma_index);

                if(!is_all_digits(operands)){
                    opcode_first_value = registers_first_operand[operands];
                }else{
                    printf("Error in line %ld, syntaxe statemant\n", line);
                    exit(1);
                }

                if(!is_all_digits(second_operand)){
                    opcode_second_value = registers_second_operand[second_operand];
                }else{
                    extern_value = true;
                    opcode_second_value = atoi(second_operand.c_str());
                }

                //0001XXXX
                if(is_math_register(operands) && is_memory_register(second_operand)) opcode = 0x10;

                //0010XXXX
                else if(is_memory_register(operands) && is_math_register(second_operand)) opcode = 0x20;

                //0011XXXX
                else if(is_memory_register(operands) && (is_memory_register(second_operand) || extern_value)) opcode = 0x30;

                //0010XXXX
                else if((is_memory_register(operands) && is_special_register(second_operand))
                 || (operands.compare("ma") && is_memory_register(second_operand))) opcode = 0x40;

                else{
                    printf("Error in line %ld, syntaxe statemant\n", line);
                    exit(1);
                }
                
                if(!extern_value){
                    opcode = opcode + opcode_first_value + opcode_second_value;
                    fwrite(&opcode, sizeof(uint8_t), 1, output_file); 
                    PC++;

                }else{
                    opcode = opcode + opcode_first_value + opcode_first_value/4;
                    fwrite(&opcode, sizeof(uint8_t), 1, output_file);
                    PC++;
                    
                    opcode = opcode_second_value;
                    fwrite(&opcode, sizeof(uint8_t), 1, output_file);
                    PC++;
                }

                cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;
            

            }

            //======================================================================================================//


            //================================================ SUM ================================================//
            if(instruction.find("sum") != string::npos){
                uint8_t instruction_size = 3;
                uint8_t comma_index = -1;

                int8_t opcode_first_value = 0;
                int8_t opcode_second_value = 0;
                bool first_extern_value = false;
                bool second_extern_value = false;

                string second_operand;

                operands = instruction.substr(instruction_size, instruction.size() - instruction_size - 1);
                instruction = instruction.substr(0, instruction_size);


                comma_index = operands.find(',');
                if(operands.find(',') == string::npos){
                    printf("Error in line %ld, miss a comma (,)\n", line);
                    exit(2);
                }

                second_operand = operands.substr(comma_index + 1, operands.size() - (comma_index + 1));
                operands = operands.substr(0, comma_index);


                //0110XXXX
                opcode += 0x60;


                if(is_all_digits(operands) && is_all_digits(second_operand)){
                    opcode += 0xE;
                    first_extern_value = true;
                    second_extern_value = true;
                    opcode_first_value = atoi(operands.c_str());
                    opcode_second_value = atoi(second_operand.c_str());

                }else if(is_all_digits(operands) && is_math_register(second_operand)){
                    swap(operands, second_operand);
                    second_extern_value = true;
                    opcode_second_value = atoi(second_operand.c_str());
                }   
                
                if(!is_all_digits(operands)){
                    opcode_first_value = registers_first_operand[operands];
                }
                if(!is_all_digits(second_operand)){
                    opcode_second_value = registers_second_operand[second_operand];
                }

                if(is_math_register(operands) && is_math_register(second_operand)){
                    if((opcode_first_value >> 2) > opcode_second_value){
                        swap(opcode_first_value, opcode_second_value);
                        opcode_first_value = opcode_first_value << 2;
                        opcode_second_value = opcode_second_value >> 2;
                    }
                }

                if(is_math_register(operands) && is_math_register(second_operand)) opcode += opcode_first_value + opcode_second_value;

                else if(is_math_register(operands) && is_all_digits(second_operand)){
                    if(operands.find("x") != string::npos){
                        opcode += 0xD;
                    }else{
                        opcode += opcode_first_value;
                    }
                    second_extern_value = true;
                    opcode_second_value = atoi(second_operand.c_str());
                }
                

                fwrite(&opcode, sizeof(uint8_t), 1, output_file);
                PC++;

                if(first_extern_value){
                    fwrite(&opcode_first_value, sizeof(uint8_t), 1, output_file);
                    PC++;
                }

                if(second_extern_value){
                    fwrite(&opcode_second_value, sizeof(uint8_t), 1, output_file);
                    PC++;
                }


                cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;


            }

            //======================================================================================================//

            //================================================ MULT ================================================//

            if(instruction.find("mult") != string::npos){
                uint8_t instruction_size = 4;
                uint8_t comma_index = -1;

                int8_t opcode_first_value = 0;
                int8_t opcode_second_value = 0;
                bool first_extern_value = false;
                bool second_extern_value = false;

                string second_operand;

                operands = instruction.substr(instruction_size, instruction.size() - instruction_size - 1);
                instruction = instruction.substr(0, instruction_size);


                comma_index = operands.find(',');
                if(operands.find(',') == string::npos){
                    printf("Error in line %ld, miss a comma (,)\n", line);
                    exit(2);
                }

                second_operand = operands.substr(comma_index + 1, operands.size() - (comma_index + 1));
                operands = operands.substr(0, comma_index);


                //0111XXXX
                opcode += 0x70;


                if(is_all_digits(operands) && is_all_digits(second_operand)){
                    opcode += 0xE;
                    first_extern_value = true;
                    second_extern_value = true;
                    opcode_first_value = atoi(operands.c_str());
                    opcode_second_value = atoi(second_operand.c_str());

                }else if(is_all_digits(operands) && is_math_register(second_operand)){
                    swap(operands, second_operand);
                    second_extern_value = true;
                    opcode_second_value = atoi(second_operand.c_str());
                }   
                
                if(!is_all_digits(operands)){
                    opcode_first_value = registers_first_operand[operands];
                }
                if(!is_all_digits(second_operand)){
                    opcode_second_value = registers_second_operand[second_operand];
                }

                if(is_math_register(operands) && is_math_register(second_operand)){
                    if((opcode_first_value >> 2) > opcode_second_value){
                        swap(opcode_first_value, opcode_second_value);
                        opcode_first_value = opcode_first_value << 2;
                        opcode_second_value = opcode_second_value >> 2;
                    }
                }

                if(is_math_register(operands) && is_math_register(second_operand)) opcode += opcode_first_value + opcode_second_value;

                else if(is_math_register(operands) && is_all_digits(second_operand)){
                    if(operands.find("x") != string::npos){
                        opcode += 0xD;
                    }else{
                        opcode += opcode_first_value;
                    }
                    second_extern_value = true;
                    opcode_second_value = atoi(second_operand.c_str());
                }
                

                fwrite(&opcode, sizeof(uint8_t), 1, output_file);
                PC++;

                if(first_extern_value){
                    fwrite(&opcode_first_value, sizeof(uint8_t), 1, output_file);
                    PC++;
                }

                if(second_extern_value){
                    fwrite(&opcode_second_value, sizeof(uint8_t), 1, output_file);
                    PC++;
                }


                cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;


            }

            //======================================================================================================//


        }

    
    

    }



    fclose(input_file);
    fclose(output_file);
    
    return 0;
}
