#!/usr/bin/python

# ---------------
# Address Spaces:
# ---------------

# USER_MIN = 0x0000
# USER_MAX = 0x7FFF
# USER_CODE_MIN = 0x0000
# USER_CODE_MAX = 0x1FFF

# OS_MIN = 0x8000
# OS_MAX = 0xFFFF
# OS_CODE_MIN 0x8000
# OS_CODE_MAX 0x9FFF

import sys, os, random

addr_lst = (0xB010, 0xC010, 0xD010)
addr_regs = range(0, 4)
alu_regs = range(4, 8)

label_counter = 0
max_label_counter = 0

def next_label():
    global label_counter
    label_counter += 1
    return "LBL_%04x" % (label_counter-1)

def relative_label(offset):
    global label_counter, max_label_counter
    max_label_counter = max(label_counter+offset, max_label_counter)
    return "LBL_%04x" % (label_counter+offset)

def align_label():
    global max_label_counter
    num = (label_counter + 32) & (~0xf)
    max_label_counter = max(num, max_label_counter)
    return "LBL_%04x" % num

def is_converged():
    return (label_counter > max_label_counter)

def orig(addr):
    global label_counter
    label_counter = addr;
    return ".ADDR x%04x" % addr

def parse_symbol(sym):
    if sym == "reg":
        return "R" + str(random.choice(addr_regs + alu_regs))

    if sym == "addr_reg":
        return "R" + str(random.choice(addr_regs))

    if sym == "alu_reg":
        return "R" + str(random.choice(alu_regs))

    if sym == "label":
        return relative_label(random.randint(2, 5));

    if sym == "align_label":
        return align_label()

    if sym == "jmpr_label":
        return relative_label(random.randint(8,12))

    if sym[0] == "s":  # signed immediate
        size = int(sym[1:])
        return "#" + str(random.randint(-2**(size-1), 2**(size-1) - 1))
    
    if sym[0] == "u":  # unsigned immediate
        size = int(sym[1:])
        return "#" + str(random.randint(0, (2**size)-1))

    return sym;

def make_insn(opcode, template):
    global label_counter
    lst = [parse_symbol(s) for s in template.split()]
    insn = "%s %s %s" % (next_label(), opcode, ", ".join(lst))
    if opcode == "LEA": 
        label_counter += 1  # LEA expands to two instructions
    return insn
    

alu_ops = (
    (("ADD", "alu_reg reg reg"),
     ("MUL", "alu_reg reg reg"),
     ("SUB", "alu_reg reg reg"),
     ("ADD", "alu_reg reg s5"),),
    
    (("CMP"  , "reg reg"),
     ("CMPU" , "reg reg"),
     ("CMPI" , "reg s7"),
     ("CMPIU", "reg u7")),
    
    (("AND"  , "alu_reg reg reg"),
     ("NOT"  , "alu_reg reg"),
     ("OR"   , "alu_reg reg reg"),
     ("XOR"  , "alu_reg reg reg"),
     ("AND"  , "alu_reg reg s5"),),
    
    (("CONST", "alu_reg s9"),),
    
    (("SLL"  , "alu_reg reg u4"),
     ("SRA"  , "alu_reg reg u4"),
     ("SRL"  , "alu_reg reg u4"),),
    (("HICONST" , "alu_reg u8"),),
    
    (("DIV", "alu_reg reg reg"),
     ("MOD", "alu_reg reg reg")),
    )

mem_ops = (
    (("LDR",  "addr_reg addr_reg #0"),),
    (("STR",  "addr_reg addr_reg #0"),),
    (("LDR",  "addr_reg addr_reg s2"),),
    (("STR",  "addr_reg addr_reg s2"),),
    (("ADD",  "addr_reg addr_reg s2"),),
    (("SLL",  "addr_reg addr_reg #0"),
     ("SRA",  "addr_reg addr_reg #0"),
     ("SRL",  "addr_reg addr_reg #0")),
    )

br_ops = (
    (("BRn", "label"),
     ("BRnz", "label"),
     ("BRnp", "label"),
     ("BRz", "label"),
     ("BRzp", "label"),
     ("BRp", "label"),
     ("BRnzp", "label"),
     ("JMP", "label"),
     ("JSR", "align_label"),
     ("TRAP", "u8"),
     ("JSRR", ""),
     ("JMPR", ""),),
    (("LOOP", ""),),
    )

br_ld_ops = (
    (("LDR", "addr_reg addr_reg #0"),),
    (("LDR", "addr_reg addr_reg s2"),),
    (("ADD", "addr_reg addr_reg s2"),
     ("STR", "addr_reg addr_reg s2")),
    (("BRn", "label"),
     ("BRnz", "label"),
     ("BRnp", "label"),
     ("BRz", "label"),
     ("BRzp", "label"),
     ("BRp", "label"),
     ("BRnzp", "label"),),
)

def generate(filename, insn_lst):

    random.seed(1)
    output = open(filename, 'w')

    print >>output, ".OS"
    print >>output, ".CODE"
    print >>output, orig(0x8200)

    # Init all registers with valid addresses
    for reg in addr_regs:
        value = random.choice(addr_lst)
        print >>output, make_insn("CONST",   "R%d #%d" % (reg, value % 256))
        print >>output, make_insn("HICONST", "R%d #%d" % (reg, value / 256))

    # Generate random instructions
    global label_counter
    while label_counter <= (0xA000 - 100):
        
        (opcode, format) = random.choice(random.choice(insn_lst))

        # JSR writes R7 with the PC, so make sure it is already in the alu_regs bucket
        if (opcode in ["JSR", "JSRR", "TRAP"]) and (7 not in alu_regs):
            continue

        if opcode in ["JSRR", "JMPR"]:
            if not is_converged(): continue  # avoid some other insn jumping to middle of LEA
            lea_reg = random.choice(alu_regs);
            alu_regs.remove(lea_reg)
            print >>output, make_insn("LEA", "R%d jmpr_label" % lea_reg)
            # Put in a random number of spacing instructions
            for i in xrange(0, random.randint(0, 5)):
                (op, format) = random.choice(random.choice(alu_ops))
                print >>output, make_insn(op, format)
                        
            print >>output, make_insn(opcode, "R%d" % lea_reg)
            alu_regs.append(lea_reg)
            continue

        if opcode == "LOOP":
            if not is_converged(): continue
            count_reg = random.choice(alu_regs)
            alu_regs.remove(count_reg)
            print >>output, make_insn("CONST", "R%d #0" % count_reg)
            print >>output, make_insn("ADD", "R%d R%d #1" % (count_reg, count_reg))
            
            loopsize = random.randint(1, 10)
            # Put in a random number of insn in loop
            for i in xrange(0, loopsize):
                (op, format) = random.choice(random.choice(alu_ops))
                print >>output, make_insn(op, format)

            loopcount = random.randint(1, 7)
            print >>output, make_insn("CMPI", "R%d #%d" % (count_reg, loopcount))
            print >>output, make_insn("BRnp", relative_label(-(loopsize+2)))
            alu_regs.append(count_reg)

            continue

        #### Generate a normal instruction
        print >>output, make_insn(opcode, format)

        # Swap a register between the two buckets, which can only be
        # done if we know we're aren't going to skip past it

        if is_converged() and random.randint(0, 20) == 1:
            new_addr_reg = random.choice(alu_regs)
            new_alu_reg = random.choice(addr_regs)
            print >>output, make_insn("ADD", "R%d R%d 0" % (new_addr_reg, new_alu_reg))

            alu_regs.remove(new_addr_reg)
            alu_regs.append(new_alu_reg)

            addr_regs.remove(new_alu_reg)
            addr_regs.append(new_addr_reg)

    # stop label
    while not is_converged():
        print >>output, make_insn("ADD", "reg reg reg")

    print >>output, "END_LABEL ADD R1, R1, R1";

    # Initialize 100 words before and after addresses
    for addr in addr_lst:
        print >>output, "\n.DATA"
        print >>output, ".ADDR x%04x" % (addr-200)
        for i in xrange(400):
            print >>output, ".FILL x%04x" % (random.choice(addr_lst) + random.randint(-1, 1))

    # TRAP table
    print >>output, ".CODE"
    print >>output, orig(0x8000)
    for i in xrange(64):
        print >>output, make_insn("CMP", "reg reg")
        print >>output, make_insn("CMP", "reg reg")
        print >>output, make_insn("CMP", "reg reg")
        print >>output, make_insn("RET", "")
    output.close()

def main():
    generate("test_alu.asm", alu_ops)
    generate("test_mem.asm", mem_ops)
    generate("test_br.asm",  br_ops+alu_ops)
    generate("test_all.asm", mem_ops+alu_ops+br_ops)
    generate("test_ld_br.asm", br_ld_ops)

if __name__ == "__main__":
    main()
