`timescale 1ns / 1ps


module lc4_alu(i_insn, i_pc, i_r1data, i_r2data, carry,float, carry_out, float_out, o_result);
   parameter WORD_SIZE = 256;
   parameter DADDR = 4;
   parameter INSN = 19;
   parameter IADDR = 10;

   input [INSN:0] i_insn;
   input [IADDR:0] i_pc;
   input [WORD_SIZE-1:0] i_r1data, i_r2data;
   input carry;
   input [8:0] float;
   output carry_out;
   output [8:0] float_out;
   output [WORD_SIZE-1:0] o_result;

   wire [4:0]   opcode = i_insn[19:15];
   wire [1:0] arith_mux;
   wire sub_mux;
   wire tc_mux;
   wire [WORD_SIZE-1:0] rs = i_r1data;
   wire [WORD_SIZE-1:0] rt;
   wire [WORD_SIZE-1:0] r_adder;

   assign arith_mux = (opcode === 5'b10100) ? 2'b11 :
      (opcode === 5'b10110) ? 2'b10 :
      (opcode === 5'b00101 | opcode === 5'b00110 | opcode === 5'b00111) ? 2'b1 :
      2'b0; // add or sub or addi
   assign sub_mux = (opcode === 5'b00110); // SUB
   assign tc_mux = (opcode === 5'b10100); // TCS

   assign rt =
      (opcode == 5'b00111) | // ADDI -- sext(5)
      (opcode == 5'b01001) ? // AND -- sext(5)
          {{(WORD_SIZE-5){i_insn[4]}}, i_insn[4:0]} : i_r2data;

   adder_module #(.WORD_SIZE(WORD_SIZE))
      adder(rs, rt, arith_mux, sub_mux, tc_mux, carry, carry_out, r_adder);
   wire [IADDR:0] next_pc = i_pc + {{2{i_insn[8]}}, i_insn[8:0]};

   assign float_out = (opcode == 5'b11000) ? float - 1 :
                      (opcode == 5'b11001) ? i_r1data[8:0] : float;

   assign o_result =
      (opcode == 5'b00000  | // NOP
       opcode == 5'b00001  | // BRz
       opcode == 5'b00010  | // BRzp
       opcode == 5'b00011  | // BRnp
       opcode == 5'b00100  | // BRnz
       opcode == 5'b01000) ? // JSR
          {{(WORD_SIZE-(IADDR+1)){1'b0}}, next_pc} :

      (opcode == 5'b00101) | // ADD
      (opcode == 5'b00110) | // SUB
      (opcode == 5'b00111) | // ADDI
      (opcode == 5'b10110) ? // ADDc
          r_adder :

      (opcode == 5'b01001) ? // AND
          (rs & rt) :

      (opcode == 5'b01010) ? // RTI
          rs :

      (opcode == 5'b01011) ? // CONST
          {{(WORD_SIZE-9){i_insn[8]}}, i_insn[8:0]} :

      (opcode == 5'b01100) ? // SLL
          rs << i_insn[3:0] : // TODO should combine with other >>
      (opcode == 5'b01101) ? // SRL
          (rs >> ((i_insn[3:0] == 4'd15) ? 255 :
                (i_insn[3:0] == 4'd14) ? 252 :
                i_insn[3:0])) :
      (opcode == 5'b01110) ? // SDRH
          rs >> 1 : // TODO should combine with other >>
      (opcode == 5'b01111) ? // SDRL
          {rs[0], rt[WORD_SIZE-1:1]} :
      (opcode == 5'b10010) ? // SDL
          {rs[WORD_SIZE-2:0], rt[WORD_SIZE-1]} :

      (opcode == 5'b10000) ? // CHKL
          {WORD_SIZE{rs[0]}} :

      (opcode == 5'b10011) ? // CHKH
            rs :

      (opcode == 5'b10100) | // TCS
      (opcode == 5'b10101) ? // TCDH
          r_adder :
      (opcode == 5'b10111) ?
          {{(WORD_SIZE-1){1'b0}}, carry} : // GCAR
      (opcode == 5'b11000) |
      (opcode == 5'b11001) ?
          float_out :
          16'hDEED;

endmodule

module adder_module(i_r1data, i_r2data, i_arith_mux, i_sub_mux, i_tc_mux, carry,carry_out, o_adder);
   parameter WORD_SIZE = 64;
   input [WORD_SIZE-1:0] i_r1data;
   input [WORD_SIZE-1:0] i_r2data;
   input [1:0] i_arith_mux; // Arith or TC or ADDC
   input i_sub_mux; // SUB or ADD
   input i_tc_mux; // TCS or TCDH
   input carry;
   output carry_out;
   wire [WORD_SIZE:0] adder;
   output [WORD_SIZE-1:0] o_adder;

   wire [WORD_SIZE:0] r1tc = (~i_r1data) + 1;
   wire [WORD_SIZE:0] r2tc = (~i_r2data) + 1;

   wire [WORD_SIZE:0] adder_in = (i_sub_mux) ? r2tc : {1'b0,i_r2data};
   wire [WORD_SIZE:0] r1adder_in = {1'b0,i_r1data};

   assign adder =
      (i_arith_mux === 2'b10) ? r1adder_in + carry : // ADDC!! TODO FIX  me
      (i_arith_mux === 2'b1) ? (r1adder_in + adder_in) :
      (i_tc_mux) ? r1tc : // TCS
      (carry) ?  r1tc : ~r1adder_in; // TCDH
  assign carry_out = adder[WORD_SIZE];
  assign o_adder = adder[WORD_SIZE-1:0];
endmodule
