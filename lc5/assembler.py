#! /usr/bin/env python

import ctypes
import re
import sys

INSN_BIT_WIDTH = 20
INSN_HEX_WIDTH = INSN_BIT_WIDTH / 4
INSN_MEM_SIZE = 1024

INSNS = {insn: i for i, insn in enumerate([
    'NOP',
    'BRz',
    'BRzp',
    'BRnp',
    'BRnz',
    'ADD',
    'SUB',
    'ADDi',
    'JSR',
    'AND',
    'RTI',
    'CONST',
    'SLL',
    'SRL',
    'SDRH',
    'SDRL',
    'CHKL',
    'DONE',
    'SDL',
    'CHKH',
    'TCS',
    'TCDH'
])}

LABELLED_INSNS = {INSNS[insn] for insn in {
    'BRz', 'BRzp', 'BRnp', 'BRnz', 'JSR'
}}

THREE_REG_INSNS = {INSNS[insn] for insn in {
    'ADD', 'SUB', 'ADDi', 'AND',
    'SLL', 'SRL', 'SDRH', 'SDRL',
    'SDL', 'CHKH'
}}

TWO_REG_INSNS = {INSNS[insn] for insn in {
    'TCS', 'TCDH'
}}

ONE_REG_INSNS = {INSNS[insn] for insn in {
    'CHKL', 'CHKH'
}}



ERR = '\n**Parsing Failed**\nError line: {}: {err}'
REG_INVALID = '\n**Parsing Failed**\nError line: {}: invalid register {reg}: {reg_val}'
REG_MISSING = '\n**Parsing Failed**\nError line: {}: Missing {reg} in {line}'

REG_LO_RANGE = range(0,2)
REG_HI_RANGE = range(2,32)

IMM5_MAX = pow(2,4)
IMM9_MAX = pow(2,8)

def parse_instruction(pc, line_num, words, labels):
    insn = words[0]
    line = ' '.join(words)

    try:
        opcode = INSNS[insn]
    except Exception as e:
        print ERR.format(line_num, err='Invalid insn %s' % insn)
        sys.exit(1)

    ret = 0

    if opcode in LABELLED_INSNS:
        try:
            label = words[1]
        except:
            print REG_MISSING.format(line_num, reg='LABEL', line=line)
            sys.exit(1)

        if label not in labels:
            print ERR.format(line_num, err='Invalid label %s' % label)
            sys.exit(1)

        # Calculates offset for PC = PC + 1 + IMM9(offset)
        offset = labels[label] - pc - 1

        ret = (opcode << 15) | (offset & (IMM9_MAX - 1))

    elif opcode in THREE_REG_INSNS:

        # Get register values with error handling
        try:
            rd = words[1]
        except Exception as e:
            print REG_MISSING.format(line_num, reg='Rd', line=line)
            sys.exit(1)
        try:
            rs = words[2]
        except Exception as e:
            print REG_MISSING.format(line_num, reg='Rs', line=line)
            sys.exit(1)
        try:
            rt = words[3]
        except Exception as e:
            print REG_MISSING.format(line_num, reg='Rt or IMM5', line=line)
            sys.exit(1)

        # Make sure the registers are valid
        assert rd.startswith('R'), REG_INVALID.format(line_num, reg='Rd', reg_val=rd)
        assert rs.startswith('R'), REG_INVALID.format(line_num, reg='Rs', reg_val=rs)
        assert rt.startswith('R') or rt.startswith('#'), REG_INVALID.format(line_num, reg='Rt', reg_val=rt)

        is_imm = False
        if rt.startswith('#'):
            is_imm = True
            if opcode == INSNS['ADD']:
                opcode = INSNS['ADDi']

        rd = int(rd[1:])
        rs = int(rs[1:])
        rt = int(rt[1:])

        assert rd in (REG_LO_RANGE + REG_HI_RANGE), ERR.format(line_num, err='Rd must be in the range [{}, {}]'.format(REG_LO_RANGE[0], REG_HI_RANGE[-1]))

        if is_imm:
            assert rs in (REG_LO_RANGE + REG_HI_RANGE), ERR.format(line_num, err='Rs must be in the range [{}, {}]'.format(REG_LO_RANGE[0], REG_HI_RANGE[-1]))
            assert -IMM5_MAX <= rt < IMM5_MAX, ERR.format(line_num, err='imm5 must be in the range [{}, {}]'.format(-IMM5_MAX, IMM5_MAX-1))
            rt &= IMM5_MAX - 1
        else:
            assert rs in REG_LO_RANGE, ERR.format(line_num, err='Rs must be in the range [{}, {}]'.format(REG_LO_RANGE[0], REG_LO_RANGE[-1]))
            assert rt in REG_HI_RANGE, ERR.format(line_num, err='Rt must be in the range [{}, {}]'.format(REG_HI_RANGE[0], REG_HI_RANGE[-1]))

        ret = (opcode << 15) | (rd << 10) | (rs << 5) | rt

    elif opcode in TWO_REG_INSNS:

        # Get register values with error handling
        try:
            rd = words[1]
        except Exception as e:
            print REG_MISSING.format(line_num, reg='Rd', line=line)
            sys.exit(1)
        try:
            rs = words[1]
        except Exception as e:
            print REG_MISSING.format(line_num, reg='Rs', line=line)
            sys.exit(1)

        # Make sure register is valid
        assert rd.startswith('R'), REG_INVALID.format(line_num, reg='Rd', reg_val=rd)
        assert rs.startswith('R'), REG_INVALID.format(line_num, reg='Rs', reg_val=rs)

        rd = int(rd[1:])
        rs = int(rs[1:])

        assert rd in (REG_LO_RANGE + REG_HI_RANGE), ERR.format(line_num, err='Rd must be in the range [{}, {}]'.format(REG_LO_RANGE[0], REG_HI_RANGE[-1]))
        assert rs in (REG_LO_RANGE + REG_HI_RANGE), ERR.format(line_num, err='Rs must be in the range [{}, {}]'.format(REG_LO_RANGE[0], REG_HI_RANGE[-1]))

        ret = (opcode << 15) | (rd << 10) | (rs << 5)

    elif opcode in ONE_REG_INSNS:
        # Get register values with error handling
        try:
            rs = words[1]
        except Exception as e:
            print REG_MISSING.format(line_num, reg='Rs', line=line)
            sys.exit(1)

        # Make sure registers are valid
        assert rs.startswith('R'), REG_INVALID.format(line_num, reg='Rs', reg_val=rs)

        rs = int(rs[1:])
        assert rs in (REG_LO_RANGE + REG_HI_RANGE), ERR.format(line_num, err='Rs must be in the range [{}, {}]'.format(REG_LO_RANGE[0], REG_HI_RANGE[-1]))

        ret = (opcode << 15) | (rs << 5)

    elif opcode == INSNS['CONST']:

        try:
            rd = words[1]
        except Exception as e:
            print REG_MISSING.format(line_num, reg='Rd', line=line)
            sys.exit(1)
        try:
            imm = words[2]
        except Exception as e:
            print REG_MISSING.format(line_num, reg='IMM9', line=line)
            sys.exit(1)


        # Make sure the registers are valid
        assert rd.startswith('R'), REG_INVALID.format(line_num, reg='Rd', reg_val=rd)
        assert imm.startswith('#'), REG_INVALID.format(line_num, reg='Rt', reg_val=rt)

        rd = int(rd[1:])
        imm = int(imm[1:])

        assert rd in (REG_LO_RANGE + REG_HI_RANGE), ERR.format(line_num, err='Rd must be in the range [{}, {}]'.format(REG_LO_RANGE[0], REG_HI_RANGE[-1]))
        assert -IMM9_MAX <= imm < IMM9_MAX, ERR.format(line_num, err='imm9 must be in the range [{}, {}]'.format(-IMM9_MAX, IMM9_MAX-1))
        imm &= IMM9_MAX - 1

        ret = (opcode << 15) | (rd << 10) | imm

    else:
        ret = opcode << 15

    return "{0:0{1}X}".format(ret, INSN_HEX_WIDTH)


def parse_lines(lines):
    labels = {}
    pc = 0
    line_num = 0
    hex_ret = ''
    chex_ret = ''

    # Populate labels dict
    for i in xrange(len(lines)):
        line = lines[i]
        words = re.split(', |\s+', line)
        insn = words[0]

        # ignore empty lines and comments and commands that start with '.'
        if not insn or insn.startswith(('.', ';')):
            words = []

        # Treat non existing instructions as labels
        elif insn not in INSNS:
            if insn in labels:
                print ERR.format(line_num, err='Repeated label %s' % insn)
                sys.exit(1)

            labels[insn] = pc
            words = words[1:]

        lines[i] = ' '.join(words)
        if words:
            pc += 1

    pc = 0

    # Actually parse instructions
    for line in lines:
        line_num += 1

        words = re.split(', |\s+', line)
        insn = words[0]

        # ignore empty lines
        if not insn:
            continue

        pinsn = parse_instruction(pc, line_num, words, labels)
        hex_ret += pinsn + '\n'

        chex_ret += '%04x | ' % pc
        chex_ret += pinsn
        chex_ret += ' | {0:0{1}b} | {2} \n'.format(int(pinsn, 16), INSN_BIT_WIDTH, line)

        pc += 1

    # Fill rest of hex file with NOPs
    hex_ret += "00000\n" * (INSN_MEM_SIZE - pc)

    return (hex_ret, chex_ret)


def main():
    if len(sys.argv) != 2:
        print ("Usage: assembler.py <file.asm>")
        sys.exit(1)

    asm_file = sys.argv[1]
    hex_file = ''
    chex_file = ''
    if not asm_file.endswith(".asm"):
        print ("Must be an asm file")
        sys.exit(1)
    else:
        filename = asm_file[0:asm_file.find(".asm")]
        hex_file = filename + '.hex'
        chex_file = filename + '.chex'

    infile = open(asm_file, 'r')
    lines = infile.readlines()
    lines = [x.strip() for x in lines]

    outfile = open(hex_file, 'w')
    outfile2 = open(chex_file, 'w')
    hex_out, chex_out = parse_lines(lines)
    outfile.write(hex_out)
    outfile2.write(chex_out)

    infile.close()
    outfile.close()
    outfile2.close()

    print "Success!"

if __name__ == "__main__":
    main()
