`timescale 1ns / 1ps


module alu(i_insn, i_pc, i_r1data, i_r2data, carry, o_result);
   parameter WORD_SIZE = 64;
   parameter DADDR = 4;
   parameter INSN = 19;
   parameter IADDR = 10;

   input [INSN:0] i_insn;
   input [IADDR:0] i_pc;
   input [WORD_SIZE-1:0] i_r1data, i_r2data;
   input carry;
   output [WORD_SIZE-1:0] o_result;

   wire [4:0]   opcode = insn[19:15];
   assign o_result =
      (opcode == 5'b00000  | // NOP
       opcode == 5'b00001  | // BRz
       opcode == 5'b00010  | // BRzp
       opcode == 5'b00011  | // BRnp
       opcode == 5'b00100) ? // BRnz
          {WORD_SIZE-(IADDR+1){1'b0}, (i_pc + {i_insn[8], i_insn[8:0]} :
      (opcode == 00101
 endmodule
