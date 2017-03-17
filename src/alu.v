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
   wire arith_mux = 1'b0;
   wire sub_mux = 1'b0;
   wire [1:0] tc_mux = 2'b11;
   wire [WORD_SIZE-1:0] shifted = {WORD_SIZE{1'b0}};
   wire [15:0] pcJSR = 16'b0;
   wire [WORD_SIZE-1:0] rs = i_r1data;
   wire [WORD_SIZE-1:0] rt = {WORD_SIZE{1'b0}};

   wire [WORD_SIZE-1:0] r_arith = {WORD_SIZE{1'b0}};
   wire [WORD_SIZE-1:0] r_shift = {WORD_SIZE{1'b0}};
   wire [WORD_SIZE-1:0] r_xmp = {WORD_SIZE{1'b0}};
   wire [WORD_SIZE-1:0] r_tc = {WORD_SIZE{1'b0}};

   assign arith_mux = (opcode == 5'b00101 || opcode == 5'b00110 || opcode == 5'b00111);
   assign sub_mux = (opcode == 5'b00110) ? 1'b1 : 1'b0;
   assign tc_mux = 
      (opcode == 5'b10100) ? 2'b00 : // TCDL
      (opcode == 5'b10101) ? 2'b01 : // TCDH
      (opcode == 5'b10110) ? 2'b10 : 2'b11; // TCS
   
   assign shifted = {{{1'b0},i_insn[10:0]}, 4'b0};
   assign pcJSR = (i_pc & 16'h8000) | shifted[15:0];
   
   assign rt = 
      (opcode == 5'b00111) | // ADDI -- sext(5)
      (opcode == 5'b01001) ? // AND -- sext(5)
          {{(WORD_SIZE-5){i_insn[4]}}, i_insn[4:0]} : i_r2data;

   adder_module #(.WORD_SIZE(WORD_SIZE))
      adder(rs, rt, arith_mux, sub_mux, tc_mux, r_arith, r_tc);

   assign o_result =
      (opcode == 5'b00000  | // NOP
       opcode == 5'b00001  | // BRz
       opcode == 5'b00010  | // BRzp
       opcode == 5'b00011  | // BRnp
       opcode == 5'b00100) ? // BRnz
          {(WORD_SIZE-(IADDR+1)){1'b0}, (i_pc + {i_insn[8], i_insn[8:0]})} :
      
      (opcode == 5'b00101) | // ADD
      (opcode == 5'b00110) | // SUB
      (opcode == 5'b00111) ? // ADDI
          r_arith :
      
      (opcode == 5'b01000) ? // JSR
          {48'b0, pcJSR} :
      
      (opcode == 5'b01001) ? // AND
          (rs & rt) :
      
      (opcode == 5'b01010) ? // RTI
          rs :
      
      (opcode == 5'b01011) ? // CONST
          {(WORD_SIZE-9){i_insn[8]}, i_insn[8:0]} :
      
      (opcode == 5'b01100) ? // SLL
          rs << i_insn[3:0] :
      (opcode == 5'b01101) | // SRL
          rs >> i_insn[3:0] :
      (opcode == 5'b01110) | // SDRH
          rs >> 1 :
      (opcode == 5'b01111) | // SDRL
          {rs[0], rt >> 1} :
      (opcode == 5'b10010) ? // SDL
          {rs[WORD_SIZE-1:1], rt[WORD_SIZE-1]} :
      
      (opcode == 5'b10000) ? // CHK
          {WORD_SIZE{rs[0]}} :
      
      (opcode == 5'b10011) ? // XMP
          rs[WORD_SIZE-1:0] ^ rt[WORD_SIZE-1:0] :
      
      (opcode == 5'b10100) | // TCDL
      (opcode == 5'b10101) | // TCDH
      (opcode == 5'b10110) ? // TCS
          r_tc : {WORD_SIZE{1'b0}};

endmodule

module adder_module(i_r1data, i_r2data, i_arith_mux, i_sub_mux, i_tc_mux, o_arith, o_tc);
   parameter WORD_SIZE = 64;
   input [WORD_SIZE-1:0] i_r1data;
   input [WORD_SIZE-1:0] i_r2data;
   input i_arith_mux;
   input i_sub_mux;
   input [1:0] i_tc_mux;
   output [WORD_SIZE-1:0] o_arith;
   output [WORD_SIZE-1:0] o_tc;
   wire [1:0] tc_mux = 2'b11;
   wire [WORD_SIZE-1:0] rt = {WORD_SIZE{1'b0}};
   wire [2*WORD_SIZE-1:0] rs_rt = {2*WORD_SIZE{1'b0}};

   assign rs_rt = ~{rs, rt} + 1;
   assign tc_mux =
      (i_arith_mux) ?
          ((i_sub_mux) ? 2'b10 : 2'b11) : i_tc_mux;
   assign o_tc = 
      (tc_mux == 2'b00) ? // TCDL
          rs_rt[WORD_SIZE-1:0] :
      (tc_mux == 2'b01) ? // TCDH
          rs_rt[2*WORD_SIZE-1:WORD_SIZE] :
      (tc_mux == 2'b10) ? // TCS
          ~rs + 1 : i_r1data;
   assign rt = (i_arith_mux && i_sub_mux) ? o_tc : i_r2data;
   assign o_arith = i_r1data + rt;
endmodule
