from pathlib import Path
import sys

ADDRESS_SIZE = 255
STACK_ADDRESS = 249

labels = {}

registers = {
    "R0" : "0000",
    "R1" : "0001",
    "R2" : "0010",
    "R3" : "0011",
    "R4" : "0100",
    "R5" : "0101",
    "R6" : "0110",
    "R7" : "0111",
    "R8" : "1000",
    "R9" : "1001",
    "R10": "1010",
    "R11": "1011",
    "R12": "1100",
    "R13": "1101",
    "R14": "1110",
    "R15": "1111"
}

instruction_types = {
    # Control instructions
    "HLT": "CONTROL",
    "NOP": "CONTROL",
    # Branch instructions
    "JMP": "BRANCH",
    "JEZ": "BRANCH",
    "JNZ": "BRANCH",
    "JGZ": "BRANCH",
    "JLZ": "BRANCH",
    "JCA": "BRANCH",
    "JOV": "BRANCH",
    # Data instructions
    "MOV": "DATA",
    "LDI": "DATA",
    "LDR": "DATA",
    "STR": "DATA",
    # ALU instructions
    "ADD": "ALU",
    "SUB": "ALU",
    "NEG": "ALU",
    "NOT": "ALU",
    "AND": "ALU",
    "OR" : "ALU",
    "INC": "ALU",
    "DEC": "ALU",
    # Pseudo instructions
    "CALL":"PSEUDO",
    "RET" : "PSEUDO",
    "POP" : "PSEUDO",
    "PUSH": "PSEUDO"
}

instructions = {
    # Control instructions
    "HLT": "0000000000000000",
    "NOP": "0010000000000000",
    # Branch instructions
    "JMP": "01001000",
    "JEZ": "01010000",
    "JNZ": "01011000",
    "JGZ": "01100000",
    "JLZ": "01101000",
    "JCA": "01110000",
    "JOV": "01111000",
    # Data instructions
    "MOV": "1000",
    "LDI": "1001",
    "LDR": "1010",
    "STR": "1011",
    # ALU instructions
    "ADD": "11010000",
    "SUB": "11110010",
    "NEG": "11111100",
    "NOT": "11101100",
    "AND": "11000000",
    "OR" : "11101010",
    "INC": "11111110",
    "DEC": "11011100"
}

peripherals = {
    "SW0" : 250,
    "SW1" : 251,
    "LED0": 252,
    "LED1": 253,
    "DSP0": 254,
    "DSP1": 255
}

def strip_comments(lines):
    stripped_lines = []
    for line in lines:
        # Remove comments
        line = line.strip("\n")
        line = line.split(";", 1)[0]
        if line.strip(" ") != "":
            stripped_lines.append(line)
    return stripped_lines

def parse_lines(lines):
    elements = ["LDI R15 {}".format(STACK_ADDRESS).split()]
    line_count = 1
    for line in lines:
        line = line.upper()
        line = line.replace(",", " ", 1)

        if line.find(":") != -1:
            line = line.split(":", 1)
            labels.update({line[0]: line_count})
            line = line[1]
        
        if line == "":
            continue
        
        instruction = line.split()[0]
        if instruction_types[instruction] == "PSEUDO":
            if instruction == "CALL":
                elements.append("LDI R14 {}".format(line_count + 5).split())
                elements.append("STR R15 {}".format(line_count + 2).split())
                elements.append("STR R14 0".split())
                elements.append("DEC R15".split())
                elements.append("JMP {}".format(line.split()[1]).split())
                line_count += 4
            elif instruction == "RET":
                elements.append("INC R15".split())
                elements.append("STR R15 {}".format(line_count + 2).split())
                elements.append("LDR R14 0".split())
                elements.append("STR R14 {}".format(line_count + 4).split())
                elements.append("JMP 0".split())
                line_count += 4
            elif instruction == "POP":
                elements.append("INC R15".split())
                elements.append("STR R15 {}".format(line_count + 2).split())
                elements.append("LDR {} 0".format(line.split()[1]).split())
                line_count += 2
            elif instruction == "PUSH":
                elements.append("STR R15 {}".format(line_count + 1).split())
                elements.append("STR {} 0".format(line.split()[1]).split())
                elements.append("DEC R15".split())
                line_count += 2
        else:
            elements.append(line.split())
        line_count += 1
    
    if line_count > ADDRESS_SIZE:
        print("Warning: instructions will not fit in memory!")
    
    return elements

def parse_instruction(line):
    binary = ""
    instruction = line[0]
    instruction_category = instruction_types[instruction]
    
    if instruction_category == "CONTROL":
        binary = instructions[instruction]
    
    elif instruction_category == "BRANCH":
        binary = instructions[instruction]
        if line[1].isdecimal():
            binary += "{:08b}".format(int(line[1]))
        else:
            binary += "{:08b}".format(labels[line[1]])
    
    elif instruction_category == "DATA":
        binary = instructions[instruction] + registers[line[1]]
        if instruction == "MOV":
            binary += registers[line[2]] + "0000"
        elif instruction == "LDI":
            binary += "{:08b}".format(int(line[2]))
        elif instruction in ["LDR", "STR"]:
            if line[2] in peripherals.keys():
                binary += "{:08b}".format(peripherals[line[2]])
            else:
                binary += "{:08b}".format(int(line[2]))
    
    elif instruction_category == "ALU":
        binary = instructions[instruction]
        if instruction in ["DEC", "INC", "NEG", "NOT"]:
            binary += "0000"
        else:
            binary += registers[line[2]]
        binary += registers[line[1]]
    
    return binary

def read_file(file):
    lines = file.readlines()
    lines = strip_comments(lines)
    return parse_lines(lines)

def main():
    code = []

    # Ensure an input file has been specified
    if len(sys.argv) == 2:
        if sys.argv[1] in ["-h", "--help"]:
            print("Usage: {} <file>".format(sys.argv[0]))
            return
            
        # Open the file and read into code
        with open(sys.argv[1]) as file:
            code = read_file(file)
    else:
        print("Usage: {} <file>".format(sys.argv[0]))
        return
    
    # Write decoded binary instructions to file
    with open("{}.bin".format(Path(sys.argv[1]).name.split(".")[0]), "w") as file:
        for line_num, line in enumerate(code):
            file.write(parse_instruction(line))
            if line_num != len(code)-1:
                file.write("\n")

if __name__ == "__main__":
    main()