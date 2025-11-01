#include <iostream>
#include <cstdint>
#include <map>
#include <cctype>
#include <vector>

using namespace std;


map<string, uint8_t> registers_first_operand;
map<string, uint8_t> registers_second_operand;


const vector<string> memory_registers = {"r1", "r2", "r3" ,"r4"};
const vector<string> math_registers = {"x", "y", "z" ,"w"};
const vector<string> special_registers = {"a","ma", "[ma]"};
vector<pair<string, uint8_t>> jumps_pointers; 

void nop(string &instruction, size_t &line, size_t &PC, FILE* output);
void res(string &instruction, size_t &line, size_t &PC, FILE* output);
void resf(string &instruction, size_t &line, size_t &PC, FILE* output);

void load(string &instruction, size_t &line, size_t &PC, FILE* output);
void jump(string &instruction, size_t &line, size_t &PC, FILE* output, bool first_time = false);

void sum(string &instruction, size_t &line, size_t &PC, FILE* output);
void mult(string &instruction, size_t &line, size_t &PC, FILE* output);

void sub(string &instruction, size_t &line, size_t &PC, FILE* output);
void div(string &instruction, size_t &line, size_t &PC, FILE* output);
void mod(string &instruction, size_t &line, size_t &PC, FILE* output);

void b_and(string &instruction, size_t &line, size_t &PC, FILE* output, uint8_t size = 3, uint8_t instruction_opcode = 0x80);
void b_or(string &instruction, size_t &line, size_t &PC, FILE* output);
void b_xor(string &instruction, size_t &line, size_t &PC, FILE* output);
void b_not(string &instruction, size_t &line, size_t &PC, FILE* output);
void comp(string &instruction, size_t &line, size_t &PC, FILE* output);

void lshift(string &instruction, size_t &line, size_t &PC, FILE* output);
void rshift(string &instruction, size_t &line, size_t &PC, FILE* output);

bool jump_stacking(string &instruction, size_t &line, size_t &PC, FILE* output, bool first_time = false);



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
    for(int i = 0 ; i < memory_registers.size() ; i++){
        if(s == memory_registers[i]) return true;
    }
    return false;
}

bool is_math_register(string s){
     for(int i = 0 ; i < math_registers.size() ; i++){
        if(s == math_registers[i]) return true;
    }
    return false;
}

bool is_special_register(string s){
    for(int i = 0 ; i < special_registers.size() ; i++){
        if(s == special_registers[i]) return true;
    }
    return false;
}

void operand_to_opcode(map<string, uint8_t> &reg_map, const string &operand, int8_t &opcode, const size_t &line){
    if(reg_map.find(operand) != reg_map.end()){
        opcode = reg_map[operand];  
    }else{
        printf("Error in line %ld, incorrect operand or instruction.\n", line);
        exit(3);
    } 
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

    
    

    
    registers_first_operand["r1"] = registers_first_operand["x"] = 0; //0000
    registers_first_operand["r2"] = registers_first_operand["y"] = 4; //0100
    registers_first_operand["r3"] = registers_first_operand["z"] = 8; //1000
    registers_first_operand["r4"] = registers_first_operand["w"] = 12; //1100
    registers_first_operand["a"] = registers_first_operand["ma"] = 128; // out of all ranges, dont had a pattern
    



    
    registers_second_operand["r1"] = registers_second_operand["x"] = 0; //0000
    registers_second_operand["r2"] = registers_second_operand["y"] = 1; //0001
    registers_second_operand["r3"] = registers_second_operand["z"] = 2; //0010
    registers_second_operand["r4"] = registers_second_operand["w"] = 3; //0011
    registers_second_operand["a"] = registers_second_operand["ma"] = 128; // out of all ranges
   

    size_t PC = 0;
    size_t line = 1;


    char caracter = '-';
    string instruction;
    
    //NOTA: NESSE COMPILADOR, ELE COMPILA O CÓDIGO DUAS VEZES, NA PRIMEIRA ELE VÊ TODOS OS ELEMENTOS 
    //QUE CAUSAM JUMPS "-ALGUMA_COISA" E NA SEGUNDA É Q ELE UTILIZA OS JUMPS DE FATO


    cout << "First Pass: " << endl;
    while(!feof(input_file)){

        instruction.clear();
        opcode = 0;

        while(caracter != ';' && !feof(input_file)){
            caracter = fgetc(input_file);
            
            if(caracter != ' ' && caracter != '\n' && caracter != '\n')
                instruction.push_back(tolower(caracter));
            //cout << instruction << endl;

            if(caracter == '\n') line++;
        }
        
        //line++;

        caracter = '-';

        //cout << "Lido: " << instruction << " => ";


        if(instruction.size() > 1){
            

            if(jump_stacking(instruction, line, PC, output_file, true)){}
            else if(instruction.find("jump") != string::npos)   jump(instruction, line, PC, output_file, true);
            else if(instruction.find("load") != string::npos)        load(instruction, line, PC, output_file);
            else if(instruction.find("sum") != string::npos)    sum(instruction, line, PC, output_file);
            else if(instruction.find("mult") != string::npos)   mult(instruction, line, PC, output_file);
            else if(instruction.find("sub") != string::npos)    sub(instruction, line, PC, output_file);
            else if(instruction.find("div") != string::npos)    div(instruction, line, PC, output_file);
            else if(instruction.find("mod") != string::npos)    mod(instruction, line, PC, output_file);
            else if(instruction.find("and") != string::npos)    b_and(instruction, line, PC, output_file);
            else if(instruction.find("xor") != string::npos)    b_xor(instruction, line, PC, output_file);
            else if(instruction.find("or") != string::npos)     b_or(instruction, line, PC, output_file);
            else if(instruction.find("not") != string::npos)    b_not(instruction, line, PC, output_file);
            else if(instruction.find("comp") != string::npos)   comp(instruction, line, PC, output_file);
            else if(instruction.find("nop") != string::npos)    nop(instruction, line, PC, output_file);            
            else if(instruction.find("lshift") != string::npos) lshift(instruction, line, PC, output_file);            
            else if(instruction.find("rshift") != string::npos) rshift(instruction, line, PC, output_file);
            else if(instruction.find("resf") != string::npos)   resf(instruction, line, PC, output_file);
            else if(instruction.find("res") != string::npos)    res(instruction, line, PC, output_file);
            else{
                printf("Error in line %ld, this instruction doesn't exist!\n", line);
                exit(5);
            }


        }

    
    

    }

    line = 0;
    PC = 0;
    
    fseek(input_file, 0, SEEK_SET);
    fseek(output_file, 0, SEEK_SET);

    cout << "Labels: " << endl;
    for(int i = 0 ; i < jumps_pointers.size() ; i++){
        printf("%s %d\n", jumps_pointers[i].first.c_str(), jumps_pointers[i].second);
    }

    cout << endl;


    cout << "Second pass" << endl;
    while(!feof(input_file)){

        instruction.clear();
        opcode = 0;

        while(caracter != ';' && !feof(input_file)){
            caracter = fgetc(input_file);
            
            if(caracter != ' ' && caracter != '\n' && caracter != '\n')
                instruction.push_back(tolower(caracter));
            //cout << instruction << endl;

            if(caracter == '\n') line++;
        }
        
        //line++;

        caracter = '-';

        //cout << "Lido: " << instruction << " => ";


        if(instruction.size() > 1){
            

            
            
            if(jump_stacking(instruction, line, PC, output_file)){}
            else if(instruction.find("jump") != string::npos)   jump(instruction, line, PC, output_file);
            else if(instruction.find("load") != string::npos)        load(instruction, line, PC, output_file);
            else if(instruction.find("sum") != string::npos)    sum(instruction, line, PC, output_file);
            else if(instruction.find("mult") != string::npos)   mult(instruction, line, PC, output_file);
            else if(instruction.find("sub") != string::npos)    sub(instruction, line, PC, output_file);
            else if(instruction.find("div") != string::npos)    div(instruction, line, PC, output_file);
            else if(instruction.find("mod") != string::npos)    mod(instruction, line, PC, output_file);
            else if(instruction.find("and") != string::npos)    b_and(instruction, line, PC, output_file);
            else if(instruction.find("xor") != string::npos)    b_xor(instruction, line, PC, output_file);
            else if(instruction.find("or") != string::npos)     b_or(instruction, line, PC, output_file);
            else if(instruction.find("not") != string::npos)    b_not(instruction, line, PC, output_file);
            else if(instruction.find("comp") != string::npos)   comp(instruction, line, PC, output_file);
            else if(instruction.find("nop") != string::npos)    nop(instruction, line, PC, output_file);            
            else if(instruction.find("lshift") != string::npos) lshift(instruction, line, PC, output_file);            
            else if(instruction.find("rshift") != string::npos) rshift(instruction, line, PC, output_file);
            else if(instruction.find("resf") != string::npos)   resf(instruction, line, PC, output_file);
            else if(instruction.find("res") != string::npos)    res(instruction, line, PC, output_file);
            else{
                printf("Error in line %ld, this instruction doesn't exist!\n", line);
                exit(5);
            }


        }

    
    

    }

   


    for(int i = 0 ; i < jumps_pointers.size() ; i++){
        printf("%s %d\n", jumps_pointers[i].first.c_str(), jumps_pointers[i].second);
    }


    fclose(input_file);
    fclose(output_file);
    
    return 0;
}


//LOAD MOV CARREGAR
void load(string &instruction, size_t &line, size_t &PC, FILE* output){
    uint8_t instruction_size = 4;
    uint8_t comma_index = -1;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    int8_t opcode_second_value = 0;
    bool extern_value = false;

    string operands;
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
        operand_to_opcode(registers_first_operand, operands, opcode_first_value, line);
    }else{
        printf("Error in line %ld, syntaxe statemant\n", line);
        exit(1);
    }

    if(!is_all_digits(second_operand)){
        operand_to_opcode(registers_second_operand, second_operand, opcode_second_value, line);
    }else{
        extern_value = true;
        opcode_second_value = atoi(second_operand.c_str());
    }

    if(second_operand == "a"){
        opcode_second_value = 0;
    }else if(second_operand == "ma"){
        opcode_second_value = 1;
    }else if(second_operand == "[ma]" ){
        opcode_second_value = 2;
    }

    //0001XXXX
    if(is_math_register(operands) && is_memory_register(second_operand)) opcode = 0x10;

    //0010XXXX
    else if(is_memory_register(operands) && is_math_register(second_operand)) opcode = 0x20;

    //0011XXXX
    else if(is_memory_register(operands) && (is_memory_register(second_operand) || extern_value)) opcode = 0x30;

    //0100XXXX
    else if((is_memory_register(operands) && is_special_register(second_operand))
    || (operands.compare("ma") && is_memory_register(second_operand))) opcode = 0x40;

    else{
        printf("Error in line %ld, syntaxe statemant\n", line);
        exit(1);
    }
    
    if(!extern_value){
        opcode = opcode + opcode_first_value + opcode_second_value;
        fprintf(output, "%02X\n", opcode); 
        PC++;

    }else{
        opcode = opcode + opcode_first_value + (opcode_first_value >> 2);
        fprintf(output, "%02X\n", opcode);
        PC++;
        
        opcode = opcode_second_value;
        fprintf(output, "%02X\n", opcode);
        PC++;
    }

    cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;
            
}

//SOMA
void sum(string &instruction, size_t &line, size_t &PC, FILE* output){
    uint8_t instruction_size = 3;
    uint8_t comma_index = -1;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    int8_t opcode_second_value = 0;
    bool first_extern_value = false;
    bool second_extern_value = false;

    string operands;
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
    
    if(!is_all_digits(operands))       operand_to_opcode(registers_first_operand, operands, opcode_first_value, line);
    if(!is_all_digits(second_operand)) operand_to_opcode(registers_second_operand, second_operand, opcode_second_value, line);

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
    

    fprintf(output, "%02X\n", opcode);
    PC++;

    if(first_extern_value){
        fprintf(output, "%02X\n", opcode_first_value);
        PC++;
    }

    if(second_extern_value){
        fprintf(output, "%02X\n", opcode_second_value);
        PC++;
    }


    cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;
}

//MULTIPLICAÇÃO
void mult(string &instruction, size_t &line, size_t &PC, FILE* output){    
    uint8_t instruction_size = 4;
    uint8_t comma_index = -1;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    int8_t opcode_second_value = 0;
    bool first_extern_value = false;
    bool second_extern_value = false;

    string operands;
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
    

    if(!is_all_digits(operands))       operand_to_opcode(registers_first_operand, operands, opcode_first_value, line);
    if(!is_all_digits(second_operand)) operand_to_opcode(registers_second_operand, second_operand, opcode_second_value, line);


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
    

    fprintf(output, "%02X\n", opcode);
    PC++;

    if(first_extern_value){
        fprintf(output, "%02X\n", opcode_first_value);
        PC++;
    }

    if(second_extern_value){
        fprintf(output, "%02X\n", opcode_second_value);
        PC++;
    }


    cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;
}

//SUBTRAÇÃO
void sub(string &instruction, size_t &line, size_t &PC, FILE* output){    
    uint8_t instruction_size = 3;
    uint8_t comma_index = -1;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    int8_t opcode_second_value = 0;
    bool first_extern_value = false;
    bool second_extern_value = false;
    bool is_a_sum = false;

    string operands;
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

    if(is_all_digits(operands) && is_all_digits(second_operand)){
        opcode += 0xE;
        first_extern_value = true;
        second_extern_value = true;
        opcode_first_value = atoi(operands.c_str());
        opcode_second_value = -atoi(second_operand.c_str());
        opcode += 0x60;
        is_a_sum = true;
    }else if(is_math_register(operands) && is_all_digits(second_operand)){
        opcode += 0x60;
        second_extern_value = true;
        opcode_second_value = -atoi(second_operand.c_str());
        is_a_sum = true;
    }

    if(!is_all_digits(operands))       operand_to_opcode(registers_first_operand, operands, opcode_first_value, line);
    if(!is_all_digits(second_operand)) operand_to_opcode(registers_second_operand, second_operand, opcode_second_value, line);

    if((opcode_first_value >> 2) == opcode_second_value){
        printf("Error in line %ld, operation denied.\n", line);
        exit(4);
    }

    if(!is_a_sum)opcode += 0xB0;

    if(is_math_register(operands) && is_math_register(second_operand)) opcode += opcode_first_value + opcode_second_value;
    else if(is_math_register(operands) && is_all_digits(second_operand)) opcode += opcode_first_value;
    else if(is_all_digits(operands) && is_math_register(second_operand)){
        opcode += opcode_second_value + (opcode_second_value << 2);
        first_extern_value = true;
        opcode_first_value = atoi(operands.c_str());
    }

    fprintf(output, "%02X\n", opcode);
    PC++;

    if(first_extern_value){
        fprintf(output, "%02X\n", opcode_first_value);
        PC++;
    }

    if(second_extern_value){
        fprintf(output, "%02X\n", opcode_second_value);
        PC++;
    }


    cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;

}

//DIVISÃO
void div(string &instruction, size_t &line, size_t &PC, FILE* output){
    uint8_t instruction_size = 3;
    uint8_t comma_index = -1;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    int8_t opcode_second_value = 0;
    bool extern_value = false;

    string operands;
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


    opcode += 0xD0;

    if(is_all_digits(operands)){
        printf("Error in line %ld, operation denied.\n", line);
        exit(4);
    }

    if(!is_all_digits(operands))       operand_to_opcode(registers_first_operand, operands, opcode_first_value, line);
    if(!is_all_digits(second_operand)) operand_to_opcode(registers_second_operand, second_operand, opcode_second_value, line);
    else{
        extern_value = true;
        opcode_second_value = atoi(second_operand.c_str());
    }

    if(is_math_register(operands) && is_math_register(second_operand)) opcode += opcode_first_value + opcode_second_value;
    else if(is_math_register(operands) && is_all_digits(second_operand)) opcode += opcode_first_value + (opcode_first_value>>2);




    fprintf(output, "%02X\n", opcode);
    PC++;

    if(extern_value){
        fprintf(output, "%02X\n", opcode_second_value);
        PC++;
    }

    cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;

    
}

//RESTO
void mod(string &instruction, size_t &line, size_t &PC, FILE* output){    
    uint8_t instruction_size = 3;
    uint8_t comma_index = -1;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    int8_t opcode_second_value = 0;
    bool extern_value = false;

    string operands;
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


    opcode += 0xE0;

    if(is_all_digits(operands)){
        printf("Error in line %ld, operation denied.\n", line);
        exit(4);
    }

    if(!is_all_digits(operands))       operand_to_opcode(registers_first_operand, operands, opcode_first_value, line);
    if(!is_all_digits(second_operand)) operand_to_opcode(registers_second_operand, second_operand, opcode_second_value, line);
    else{
        extern_value = true;
        opcode_second_value = atoi(second_operand.c_str());
    }

    if(is_math_register(operands) && is_math_register(second_operand)) opcode += opcode_first_value + opcode_second_value;
    else if(is_math_register(operands) && is_all_digits(second_operand)) opcode += opcode_first_value + (opcode_first_value>>2);




    fprintf(output, "%02X\n", opcode);
    PC++;

    if(extern_value){
        fprintf(output, "%02X\n", opcode_second_value);
        PC++;
    }

    cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;
    
    


}

//AND
void b_and(string &instruction, size_t &line, size_t &PC, FILE* output, uint8_t size, uint8_t instruction_opcode){        
    uint8_t instruction_size = size;
    uint8_t comma_index = -1;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    int8_t opcode_second_value = 0;
    bool extern_value = false;

    string operands;
    string second_operand;

    operands = instruction.substr(instruction_size, instruction.size() - instruction_size - 1);
    instruction = instruction.substr(0, instruction_size);


    comma_index = operands.find(',');
    if(operands.find(',') == string::npos){
        printf("Error in line %ld, miss a comma (,)\n", line);
        exit(2);
    }

    opcode += instruction_opcode;

    second_operand = operands.substr(comma_index + 1, operands.size() - (comma_index + 1));
    operands = operands.substr(0, comma_index);   


    if(is_all_digits(operands) && is_math_register(second_operand)){
        swap(operands, second_operand);
        opcode_second_value = atoi(second_operand.c_str());
    }   
    
    if(!is_all_digits(operands))       operand_to_opcode(registers_first_operand, operands, opcode_first_value, line);
    if(!is_all_digits(second_operand)) operand_to_opcode(registers_second_operand, second_operand, opcode_second_value, line);


    if(is_math_register(operands) && is_math_register(second_operand)){
        if((opcode_first_value >> 2) > opcode_second_value){
            swap(opcode_first_value, opcode_second_value);
            opcode_first_value = opcode_first_value << 2;
            opcode_second_value = opcode_second_value >> 2;
        }

        if((opcode_first_value >> 2) == opcode_second_value){
            printf("Error in line %ld, operation denied.\n", line);
            exit(4);
        }
    }

    if(is_math_register(operands) && is_math_register(second_operand)) opcode += opcode_first_value + opcode_second_value;
    else if(is_math_register(operands) && is_all_digits(second_operand)){
        extern_value = true;
        opcode += opcode_first_value + (opcode_first_value >> 2);
        opcode_second_value = atoi(second_operand.c_str());
    }else{
        printf("Error in line %ld, syntaxe statemant\n", line);
        exit(1);
    }
    
    fprintf(output, "%02X\n", opcode);
    PC++;

    if(extern_value){
        fprintf(output, "%02X\n", opcode_second_value);
        PC++;
    }

    cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;

}

//OR
void b_or(string &instruction, size_t &line, size_t &PC, FILE* output){
    b_and(instruction, line, PC, output, 2, 0x90);
}

//XOR
void b_xor(string &instruction, size_t &line, size_t &PC, FILE* output){
    b_and(instruction, line, PC, output, 3, 0xA0);
}

//COMP
void comp(string &instruction, size_t &line, size_t &PC, FILE* output){
    b_and(instruction, line, PC, output, 4, 0xC0);
}

//NOT
void b_not(string &instruction, size_t &line, size_t &PC, FILE* output){
    uint8_t instruction_size = 3;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    bool extern_value = false;

    string operands;

    operands = instruction.substr(instruction_size, instruction.size() - instruction_size - 1);
    instruction = instruction.substr(0, instruction_size);

    opcode += 0x80;
    
    
    if(is_math_register(operands)){
       
        if(operands == math_registers[0]) opcode += 0xD; //x
        else if(operands == math_registers[1]) opcode += 0x4; //y
        else if(operands == math_registers[2]) opcode += 0x8; //z
        else if(operands == math_registers[3]) opcode += 0xC; //w
        else{
            printf("Error in line %ld, incorrect operand or instruction.\n", line);
            exit(3);    
        }
        
    }else if(is_all_digits(operands)){
        opcode += 0x9;
        opcode_first_value = atoi(operands.c_str());
        extern_value = true;
    }
    else{
        printf("Error in line %ld, syntaxe statemant\n", line);
        exit(1);
    }

    fprintf(output, "%02X\n", opcode);
    PC++;

    if(extern_value){
        fprintf(output, "%02X\n", opcode_first_value);
        PC++;
    }

        cout << PC-1 << ":" << instruction  << " " << operands << endl;

}

//NOP
void nop(string &instruction, size_t &line, size_t &PC, FILE* output){    
    uint8_t instruction_size = 3;
    uint8_t opcode = 0;

    instruction = instruction.substr(0, instruction_size);

    if(instruction != "nop"){
        printf("Error in line %ld, this instruction doesn't exist!\n", line);
        exit(5);
    }

    fprintf(output, "%02X\n", opcode);
    PC++;

    cout << PC-1 << ":" << instruction  << endl;

}

//LSHIFT
void lshift(string &instruction, size_t &line, size_t &PC, FILE* output){
    uint8_t instruction_size = 6;
    uint8_t comma_index = -1;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    int8_t opcode_second_value = 0;
    bool extern_value = false;

    string operands;
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


    if(is_math_register(operands) && is_math_register(second_operand)){
        opcode += 0xF0;
        
        operand_to_opcode(registers_first_operand, operands, opcode_first_value, line);
        operand_to_opcode(registers_second_operand, second_operand, opcode_second_value, line);

        opcode += opcode_first_value + opcode_second_value;


    }else if(is_math_register(operands) && is_all_digits(second_operand)){
        opcode += 0xC0;
        extern_value = true;
        opcode_second_value = atoi(second_operand.c_str());

        if(operands == math_registers[0]) opcode += 0x4; //x,V
        else if(operands == math_registers[1]) opcode += 0x8; //y,V
        else if(operands == math_registers[2]) opcode += 0x9; //z,V
        else if(operands == math_registers[3]) opcode += 0xC; //w,V
        else{
            printf("Error in line %ld, incorrect operand or instruction.\n", line);
            exit(3);    
        }

    }else{
        printf("Error in line %ld, operation denied.\n", line);
        exit(4);
    }

    fprintf(output, "%02X\n", opcode);
    PC++;

    if(extern_value){
        fprintf(output, "%02X\n", opcode_second_value);
        PC++;
    }

    cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;


}

//RSHIFT
void rshift(string &instruction, size_t &line, size_t &PC, FILE* output){
    uint8_t instruction_size = 6;
    uint8_t comma_index = -1;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    int8_t opcode_second_value = 0;
    bool extern_value = false;

    string operands;
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
    
    
    if(is_all_digits(operands)){
        printf("Error in line %ld, operation denied.\n", line);
        exit(4);
    } 
    else if(is_math_register(operands)){
        if(operands == math_registers[0]){ //x
            if(is_math_register(second_operand)){
                if(second_operand == math_registers[0]) opcode = 0x94;      //xx
                else if(second_operand == math_registers[1]) opcode = 0x98; //xy
                else if(second_operand == math_registers[2]) opcode = 0x99; //xz
                else if(second_operand == math_registers[3]) opcode = 0x9C; //xw
                else{
                    printf("Error in line %ld, incorrect operand or instruction.\n", line);
                    exit(3); 
                }
            }
            if(is_all_digits(second_operand)){
                opcode = 0x9D;
                extern_value = true;
                opcode_second_value = atoi(second_operand.c_str());
            }
        }else if(operands == math_registers[1]){ //y
            if(is_math_register(second_operand)){
                if(second_operand == math_registers[0]) opcode = 0x9E;      //yx
                else if(second_operand == math_registers[1]) opcode = 0xA4; //yy
                else if(second_operand == math_registers[2]) opcode = 0xA8; //yz
                else if(second_operand == math_registers[3]) opcode = 0xA9; //yw
                else{
                    printf("Error in line %ld, incorrect operand or instruction.\n", line);
                    exit(3); 
                }
            }
            if(is_all_digits(second_operand)){
                opcode = 0xAC;
                extern_value = true;
                opcode_second_value = atoi(second_operand.c_str());
            }
        }else if(operands == math_registers[2]){ //z
            if(is_math_register(second_operand)){
                if(second_operand == math_registers[0]) opcode = 0xAD;      //zx
                else if(second_operand == math_registers[1]) opcode = 0xAE; //zy
                else if(second_operand == math_registers[2]) opcode = 0xCD; //zz
                else if(second_operand == math_registers[3]) opcode = 0xCE; //zw
                else{
                    printf("Error in line %ld, incorrect operand or instruction.\n", line);
                    exit(3); 
                }
            }
            if(is_all_digits(second_operand)){
                opcode = 0x8E;
                extern_value = true;
                opcode_second_value = atoi(second_operand.c_str());
            }
        }else if(operands == math_registers[3]){//w
            if(is_math_register(second_operand)){
                if(second_operand == math_registers[0]) opcode = 0x69;      //wx
                else if(second_operand == math_registers[1]) opcode = 0x79; //wy
                else if(second_operand == math_registers[2]) opcode = 0x5D; //wz
                else if(second_operand == math_registers[3]) opcode = 0x5E; //ww
                else{
                    printf("Error in line %ld, incorrect operand or instruction.\n", line);
                    exit(3); 
                }
            }
            if(is_all_digits(second_operand)){
                opcode = 0x5F;
                extern_value = true;
                opcode_second_value = atoi(second_operand.c_str());
            }
        }

    }else{
            printf("Error in line %ld, incorrect operand or instruction.\n", line);
            exit(3); 
    }


    fprintf(output, "%02X\n", opcode);
    PC++;

    if(extern_value){
        fprintf(output, "%02X\n", opcode_second_value);
        PC++;
    }

    cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;


}

bool jump_stacking(string &instruction, size_t &line, size_t &PC, FILE* output, bool first_time){
    if(instruction[0] != '-') return false;

    instruction = instruction.substr(1, instruction.size() - 2);
    cout << instruction << endl;

    if(first_time){
        for(int i = 0 ; i < jumps_pointers.size() ; i++){
        if(instruction == jumps_pointers[i].first){
                printf("Error in line %ld, pointer %s already exist!\n", line, instruction.c_str());
                exit(6);
            }
        }

        jumps_pointers.push_back({instruction, PC});
    }
    
    

    return true;
}

void jump(string &instruction, size_t &line, size_t &PC, FILE* output, bool first_time){
    uint8_t instruction_size = 4;
    uint8_t comma_index = -1;
    uint8_t opcode = 0;

    int8_t opcode_first_value = 0;
    int8_t opcode_second_value = 0;
    bool extern_value = false;

    string operands;
    string second_operand;
    

    operands = instruction.substr(instruction_size, instruction.size() - instruction_size - 1);
    instruction = instruction.substr(0, instruction_size);

    comma_index = operands.find(',');
    if(operands.find(',') != string::npos){
        extern_value = true;
        second_operand = operands.substr(comma_index + 1, operands.size() - (comma_index + 1));
        operands = operands.substr(0, comma_index); 

    }


    bool exist = false;
    for(int i = 0 ; i < jumps_pointers.size() ; i++){
        if(operands == jumps_pointers[i].first){
            exist = true;
            opcode_first_value = jumps_pointers[i].second;
        }
    }

    if(!exist && !first_time){
        printf("Error in line %ld, pointer %s doesn't exist!\n", line, operands.c_str());
        exit(7);
    }else{
        if(extern_value) opcode += 0x55;
        else opcode += 0x54;
    }
    

    if(!first_time){
        fprintf(output, "%02X\n", opcode);
        PC++;

        fprintf(output, "%02X\n", opcode_first_value);
        PC++;

        if(extern_value){
            bool c = false;
            bool n = false;
            bool z = false;
            bool p = false;
            bool k = false;

            for(char flag : second_operand){
                if(flag == 'c'){
                    if(c){
                        printf("Error in line %ld, can't repeat flags.\n", line);
                        exit(8); 
                    }
                    opcode_second_value += 4;
                    c = true;
                }

                else if(flag == 'n'){
                    if(n){
                        printf("Error in line %ld, can't repeat flags.\n", line);
                        exit(8); 
                    }
                    opcode_second_value += 2;
                    n = true;
                }

                else if(flag == 'z'){
                    if(z){
                        printf("Error in line %ld, can't repeat flags.\n", line);
                        exit(8); 
                    }
                    opcode_second_value += 1;
                    z = true;
                }

                else if(flag == 'p'){
                    if(p){
                        printf("Error in line %ld, can't repeat flags.\n", line);
                        exit(8); 
                    }
                    opcode_second_value += 128;
                    p = true;
                }

                else if(flag == 'k'){
                    if(k){
                        printf("Error in line %ld, can't repeat flags.\n", line);
                        exit(8); 
                    }
                    opcode_second_value += 8;
                    k = true;
                }
                
                else{
                    printf("Error in line %ld, syntaxe error, need a valid conditional flag.\n", line);
                    exit(8); 
                }
            }

            if(!c && !n && !z && !p){
                printf("Error in line %ld, syntaxe error, need a valid conditional flag.\n", line);
                exit(8); 
            }

            fprintf(output, "%02X\n", opcode_second_value);
            PC++;

        }
        
        if(extern_value) cout << PC-1 << ":" << instruction  << " " << operands << " " << second_operand << endl;
        else cout << PC-1 << ":" << instruction  << " " << operands << endl;
    }else{
        PC += 2;
        if(extern_value) PC++;
    }
    

}

void res(string &instruction, size_t &line, size_t &PC, FILE* output){
    uint8_t instruction_size = 3;
    uint8_t opcode = 0x1;

    instruction = instruction.substr(0, instruction_size);

    if(instruction != "res"){
        printf("Error in line %ld, this instruction doesn't exist!\n", line);
        exit(5);
    }

    fprintf(output, "%02X\n", opcode);
    PC++;

    cout << PC-1 << ":" << instruction  << endl;
}
void resf(string &instruction, size_t &line, size_t &PC, FILE* output){
    uint8_t instruction_size = 4;
    uint8_t opcode = 0x2;

    instruction = instruction.substr(0, instruction_size);

    if(instruction != "resf"){
        printf("Error in line %ld, this instruction doesn't exist!\n", line);
        exit(5);
    }

    fprintf(output, "%02X\n", opcode);
    PC++;

    cout << PC-1 << ":" << instruction  << endl;
}
