import sys

WORD_SIZE = 256
INSN_BIT_WIDTH = 20
NUM_REGS = 32

NUM_ITERS = 10

# Actual state
REG_FILE = [0] * NUM_REGS

# Decoder stuff
R1_SEL = 0
R1_RE = False
R2_SEL = 0
R2_RE = False
WSEL = 0
REGFILE_WE = False
NZP_WE = False
SELECT_PC_PLUS_ONE = False
IS_BRANCH = False
IS_CONTROL_INSN = False

MASK_RT = 0b11111
MASK_RS = MASK_RT << 5
MASK_RD = MASK_RT << 10
MASK_OP = MASK_RT << 15
MASK_MSB = 1 << 255

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
    'TCDH',
    'ADDc',
    'GCAR'
])}

LABELLED_INSNS = {INSNS[insn] for insn in {
    'BRz', 'BRzp', 'BRnp', 'BRnz', 'JSR'
}}

def decode(insn):
    global R1_SEL, R1_RE, R2_SEL, R2_RE, WSEL, REGFILE_WE, NZP_WE, SELECT_PC_PLUS_ONE, IS_BRANCH, IS_CONTROL_INSN

    opcode = insn >> 15
    IS_BRANCH = 0 <= opcode <= 4

    R1_SEL = 7 if opcode == 10 else ((insn & MASK_RS) >> 5)
    R1_RE = (opcode == 0b00101 or # ADD
            opcode == 0b00110 or # SUB
            opcode == 0b00111 or # ADD I
            opcode == 0b01001 or # AND I
            opcode == 0b01100 or # SLL
            opcode == 0b01101 or # SRL
            opcode == 0b01110 or # SDRH
            opcode == 0b01111 or # SDRL
            opcode == 0b10000 or # CHKL
            opcode == 0b10010 or # SDL
            opcode == 0b10011 or # CHKH
            opcode == 0b10100 or # TCS
            opcode == 0b10101 or # TCDH
            opcode == 0b10110)   # ADDc


    R2_SEL = insn & MASK_RT
    R2_RE = (opcode == 0b00101 or # ADD
            opcode == 0b00110 or # SUB
            opcode == 0b01100 or # SLL
            opcode == 0b01101 or # SRL
            opcode == 0b01110 or # SDRH
            opcode == 0b01111 or # SDRL
            opcode == 0b10010 or # SDL
            opcode == 0b10100 or # TCS
            opcode == 0b10101)   # TCDH

    WSEL = 7 if opcode == 0b01000 else ((insn & MASK_RD) >> 10)

    NZP_WE = R1_RE or opcode == 0b01011 or opcode == 0b01000 or opcode == INSNS['GCAR']

    REGFILE_WE = NZP_WE and (opcode != 0b10000 and opcode != 0b10011)

    SELECT_PC_PLUS_ONE = opcode == 0b01000

    IS_CONTROL_INSN = opcode in {0b01000, 0b01010}


def nzp_calc(reg_input_mux_out):
    if reg_input_mux_out == 0:
        return 0b010
    elif reg_input_mux_out.bit_length() == 256 and bin(reg_input_mux_out)[2:][0] == '1':
        return 0b100
    else:
        return 0b001


def sign_extend(value, bits):
    sign_bit = 1 << (bits - 1)
    return (value & (sign_bit - 1)) - (value & sign_bit)


def run_insns(insns, outfile, debug_file):
    pc = 0
    carry = 0
    carry_store = 0
    iters = 0
    NZP = 0
    end = False
    while not end:
        insn = int(insns[pc], 16)
        opcode = insn >> 15
        pc_plus_one = pc + 1
        decode(insn)

        rd = WSEL
        rs = R1_SEL
        rt = R2_SEL

        # TODO: Make sure to sign extend
        imm5 = sign_extend(insn & 0x1F, 5)
        imm9 = sign_extend(insn & 0x1FF, 9)

        uimm4 = insn & 0xF

        alu_out = 0

        if opcode in LABELLED_INSNS:
            alu_out = pc_plus_one + imm9

        elif opcode == INSNS['ADD']:
            alu_out = REG_FILE[rs] + REG_FILE[rt]
            carry = alu_out >> 256
            alu_out &= (pow(2, 256) - 1)

        elif opcode == INSNS['SUB']:
            alu_out = REG_FILE[rs] - REG_FILE[rt]

        elif opcode == INSNS['ADDi']:
            alu_out = REG_FILE[rs] + imm5

        elif opcode == INSNS['AND']:
            alu_out = REG_FILE[rs] & imm5

        elif opcode == INSNS['RTI']:
            alu_out = REG_FILE[7]

        elif opcode == INSNS['CONST']:
            alu_out = imm9

        elif opcode == INSNS['SLL']:
            alu_out = (REG_FILE[rs] << uimm4) & (pow(2, 256) - 1)

        elif opcode == INSNS['SRL']:
            if uimm4 == 15:
                uimm4 = 255
            elif uimm4 == 14:
                uimm4 = 252

            alu_out = (REG_FILE[rs] & (pow(2, 256) - 1)) >> uimm4

        elif opcode == INSNS['SDRH']:
            alu_out = (REG_FILE[rs] & (pow(2, 256) - 1)) >> 1

        elif opcode == INSNS['SDRL']:
            snd_lsb = (REG_FILE[rs] & 1)
            alu_out = (snd_lsb << 255) | ((REG_FILE[rt] & (pow(2, 256) - 1)) >> 1)

        elif opcode == INSNS['CHKL']:
            lsb = str(REG_FILE[rs] & 1) * WORD_SIZE
            alu_out = int(lsb, 2)

        elif opcode == INSNS['DONE']:
            alu_out = 0xDEAD
            end = True

        elif opcode == INSNS['SDL']:
            # rs_list = list(bin(REG_FILE[rs])[2:])
            alu_out = ((REG_FILE[rs] << 1) & (pow(2, 256) - 1)) | ((REG_FILE[rt] & (pow(2, 256) - 1)) >> 255)
            # rs_list[-1] = str()
            # print rs_list
            # alu_out = int(''.join(rs_list), 2)

        elif opcode == INSNS['CHKH']:
            alu_out = REG_FILE[rs]

        elif opcode == INSNS['TCS']:
            # alu_out = (~REG_FILE[rs] & (pow(2, 255) - 1)) + 1
            alu_out = ~REG_FILE[rs] + 1
            carry = int(REG_FILE[rs] == 0)

        elif opcode == INSNS['TCDH']:
            alu_out = ~REG_FILE[rs] + carry

        elif opcode == INSNS['ADDc']:
            alu_out = REG_FILE[rs] + carry

        elif opcode == INSNS['GCAR']:
            alu_out = carry


        control_out = pc_plus_one if SELECT_PC_PLUS_ONE else alu_out
        reg_input_mux_out = control_out
        wdata = reg_input_mux_out

        nzp_calc_out = nzp_calc(reg_input_mux_out)
        nzp_out = nzp_calc_out if NZP_WE else NZP

        branch_out = branch_logic(IS_BRANCH, IS_CONTROL_INSN, NZP, insn)
        next_pc = alu_out if branch_out else pc_plus_one

        # Print pc (hex), insn (binary), regfile_we, regfile_reg, regfile_in, nzp_we, nzp_new_bits
        output = '{:0{}x} {:0{}b} {:x} {:0{}x} {:0{}x} {:x} {:0{}b}\n'.format(
            pc, 3, insn, INSN_BIT_WIDTH, REGFILE_WE, rd, 2, wdata, 64, NZP_WE, nzp_calc_out, 3)

        debug_output = '{:0{}x} {:0{}x} {:0{}x} {:0{}x} {:0{}x} {:0{}b}\n'.format(
            pc, 3, insn, INSN_BIT_WIDTH / 4, REG_FILE[rs] & (pow(2, 256) - 1), 64, REG_FILE[rt] & (pow(2, 256) - 1), 64, wdata & (pow(2, 256) - 1), 64, nzp_calc_out, 3)

        outfile.write(output)
        debug_file.write(debug_output)

        pc = next_pc
        NZP = nzp_out
        if REGFILE_WE:
            REG_FILE[rd] = wdata

        iters += 1


def branch_logic(is_branch, is_control, nzp_reg_out, insn):
    opcode = insn >> 15
    if opcode == 0b00001:
        nzp_t = 0b010
    elif opcode == 0b00010:
        nzp_t = 0b011
    elif opcode == 0b00011:
        nzp_t = 0b101
    elif opcode == 0b00100:
        nzp_t = 0b110
    else:
        nzp_t = 0

    nzp = nzp_reg_out & nzp_t
    return int(((nzp != 0) and is_branch) or is_control)


def main():
    global REG_FILE
    if len(sys.argv) != 2:
        print ("Usage: simulator.py <file.hex>")
        sys.exit(1)

    hex_file = sys.argv[1]
    if not hex_file.endswith(".hex"):
        print ("Must be an hex file")
        sys.exit(1)
    else:
        filename = hex_file[0:hex_file.find(".hex")]
        trace_file = filename + '.trace'
        debug_file = filename + '.debug.trace'
        reghex_file = filename + '.reg.hex'

    with open(reghex_file) as f:
        for i, line in enumerate(f):
            REG_FILE[i + 2] = int(line, 16)

    infile = open(hex_file, 'r')
    outfile = open(trace_file, 'w')
    debugfile = open(debug_file, 'w')
    lines = infile.readlines()
    insns = [x.strip() for x in lines]

    run_insns(insns, outfile, debugfile)

    infile.close()
    outfile.close()


if __name__ == '__main__':
    main()
