`timescale 1ns / 1ps

module lc4_decoder(insn,
                   r1sel,
                   r1re,
                   r2sel,
                   r2re,
                   wsel,
                   regfile_we,
                   nzp_we,
                   select_pc_plus_one,
                   is_branch,
                   is_control_insn);

   input [19:0] insn;                 // instruction
   output [4:0] r1sel;                // rs
   output       r1re;                 // does this instruction read from rs?
   output [4:0] r2sel;                // rt
   output       r2re;                 // does this instruction read from rt?
   output [4:0] wsel;                 // rd
   output       regfile_we;           // does this instruction write to rd?
   output       nzp_we;               // does this instruction write the NZP bits?
   output       select_pc_plus_one;   // route PC+1 to the ALU instead of rs?
   output       is_branch;            // is this a branch instruction?
   output       is_control_insn;      // is this a control instruction (JSR, JSRR, RTI, JMPR, JMP, TRAP)?


   // Instruction decoder
   wire [4:0]   opcode = insn[19:15];
   assign is_branch = opcode == 5'b00000 | // NOP
                      opcode == 5'b00001 | // BRz
                      opcode == 5'b00010 | // BRzp
                      opcode == 5'b00011 | // BRnp
                      opcode == 5'b00100;  // BRnz


   // Register file
   assign r1sel = insn[9:5]; // Rs
   assign r1re = opcode == 5'b00101 | // ADD
                 opcode == 5'b00110 | // SUB
                 opcode == 5'b00111 | // ADD I
                 opcode == 5'b01001 | // AND I
                 opcode == 5'b01100 | // SLL
                 opcode == 5'b01101 | // SRL
                 opcode == 5'b01110 | // SDRH
                 opcode == 5'b01111 | // SDRL
                 opcode == 5'b10000 | // CHKL
                 opcode == 5'b10010 | // SDL
                 opcode == 5'b10011 | // CHKH
                 opcode == 5'b10100 | // TCS
                 opcode == 5'b10101 ; // TCDH



   assign r2sel = insn[4:0]; // Rt

   assign r2re = opcode == 5'b00101 | // ADD
                 opcode == 5'b00110 | // SUB
                 opcode == 5'b01100 | // SLL
                 opcode == 5'b01101 | // SRL
                 opcode == 5'b01110 | // SDRH
                 opcode == 5'b01111;  // SDRL
                 opcode == 5'b10010 | // SDL
                 opcode == 5'b10100 | // TCS
                 opcode == 5'b10101 ; // TCDH



   assign wsel = (opcode == 5'b01000) // JSR
                    ? 3'd7 : insn[14:10];  /*rd*/

   assign nzp_we = r1re |
                        opcode == 5'b01011 | // CONST
                        opcode == 5'b01000; // JSR
   assign regfile_we = nzp_we &
                 (opcode != 5'b10000 | // CHKL
                 opcode != 5'b100011); // CHKH
   assign select_pc_plus_one = opcode == 5'b01000; // JSR
   assign is_control_insn = opcode == 5'b01000 | // JSR
                            opcode == 5'b01010; // RTI

endmodule
