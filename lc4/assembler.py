#! /usr/bin/env python

import sys
instructions = [ "NOP", "BRp", "BRz", "BRzp", "BRn", "BRnp", "BRnz", "BRnzp"
               , "ADD", "MUL", "SUB", "DIV"
               , "CMP", "CMPU", "CMPI", "CMPIU"
               , "JSRR", "JSR", "AND", "NOT", "OR", "XOR"
               , "LDR", "STR", "RTI", "CONST"
               , "SLL", "SRA", "SRL", "MOD"
               , "JMPR", "JMP", "HICONST", "TRAP"]

def main():
    if (len(sys.argv) != 2):
        print ("Usage: assembler.py <file.asm>")
        sys.exit(1)
    asm_file = sys.argv[1]
    hex_file = ""
    if not asm_file.endswith(".asm"):
        print ("Must be an asm file")
        sys.exit(1)
    else:
        hex_file = asm_file[0:asm_file.find(".asm")]
        hex_file += ".hex"

    infile = open(asm_file, 'r')
    outfile = open(hex_file, 'w')
    lines = infile.readlines()
    lines = [x.strip() for x in lines]
    print lines

    labels = {}
    pc = 0;
    for line in lines:
        words = line.split()
        if words[0].startswith("."): continue
        if words[0] not in instructions:
            # label
            if words[0] in labels:
                print "Repeated Label. Exit"
                sys.exit(1)
            else:
                labels[words[0]] = pc
                words = words[1:]
        # Actual instruction
        print words



        # increment PC for each line
        pc = pc + 1
    print labels




    infile.close()
    outfile.close()

if __name__ == "__main__":
    main()
