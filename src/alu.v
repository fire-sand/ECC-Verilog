`timescale 1ns / 1ps


module lc4_alu(i_insn, i_pc, i_r1data, i_r2data, o_result);
   parameter WORD_SIZE = 16;
   input [15:0] i_insn, i_pc;
   input [WORD_SIZE-1:0] i_r1data, i_r2data;
   output [WORD_SIZE-1:0] o_result;


   wire [WORD_SIZE-1:0] r_arith, r_logical, r_shift, r_const, r_cmp;
   wire [3:0] insn;
   wire [WORD_SIZE-1:0] pcJSR, pcTRAP, shifted;

   arith #(.WORD_SIZE(WORD_SIZE))
      ari0 (i_insn, i_pc, i_r1data, i_r2data, r_arith);
   logical #(.WORD_SIZE(WORD_SIZE))
      log0 (i_insn, i_pc, i_r1data, i_r2data, r_logical);
   shifter #(.WORD_SIZE(WORD_SIZE))
      shift0 (i_insn, i_pc, i_r1data, i_r2data, r_shift);
   constant #(.WORD_SIZE(WORD_SIZE))
      const0 (i_insn, i_pc, i_r1data, i_r2data, r_const);
   compare #(.WORD_SIZE(WORD_SIZE))
      cmp0 (i_insn, i_pc, i_r1data, i_r2data, r_cmp);
   leftShift #(.WORD_SIZE(WORD_SIZE))
      shift1 ({5'b0, i_insn[10:0]}, 16'd4, shifted);
   assign pcJSR = (i_pc & 16'h8000) | shifted;
   assign pcTRAP = 16'h8000 | {8'b0, i_insn[7:0]};

   assign insn = i_insn[15:12];
   assign o_result = insn == 4'b0 || insn == 4'b1 || (insn == 4'b1010 && i_insn[5:4] == 2'b11)
                     || i_insn[15:13] == 3'b011 || i_insn[15:11] == 5'b11001 ? r_arith :
                     (i_insn[15:11] == 5'b11000 || i_insn[15:11] == 5'b01000 || insn == 4'b1000 ? i_r1data :      //JMPR, JSRR, RTI
                     (i_insn[15:11] == 5'b01001 ? pcJSR :                                      //JSR
                     (insn == 4'b1111 ? pcTRAP :                                               //TRAP
                     (insn == 4'b0010 ? r_cmp :
                     (insn == 4'b0101 ? r_logical :
                     (insn == 4'b1001 || insn == 4'b1101 ? r_const :
                     (insn == 4'b1010 ? r_shift : 16'b0))))))) ;

endmodule

//ldr,str

//arithmetic, BR, NOP, LDR, STR, JMP,
module arith(i_insn, i_pc, i_r1data, i_r2data, o_result);
   parameter WORD_SIZE = 16;
   input [15:0] i_insn, i_pc;
   input [WORD_SIZE-1:0] i_r1data, i_r2data;
   output [WORD_SIZE-1:0] o_result;

   //assign r2 = i_insn[15:12] == 4'b0 ? i_pc + 1'b1 : 1_r2data;
   assign o_result = i_insn[15:9] == 7'b0 ? i_pc + 16'b1 + {{7{i_insn[8]}}, i_insn[8:0]}:              //NOP
                     (i_insn[15:13] == 3'b011 ? i_r1data + {{10{i_insn[5]}}, i_insn[5:0]} :  //ldr, str
                     (i_insn[15:12] == 4'b0 ? {{7{i_insn[8]}}, i_insn[8:0]} + i_pc + 16'b1 :  //BR
                     (i_insn[15:11] == 5'b11001 ? {{5{i_insn[10]}}, i_insn[10:0]} + i_pc + 16'b1 :  // JMP
                     (i_insn[5:3] == 3'b0 ? i_r1data + i_r2data :    //add
                     (i_insn[5:3] == 3'b1 ? 0 :// i_r1data * i_r2data :          //mul
                     (i_insn[5:3] == 3'b010 ? i_r1data - i_r2data :  //sub
                     (i_insn[5] == 1'b1 ? i_r1data + {{11{i_insn[4]}}, i_insn[4:0]} : 16'b0))))))); //add

endmodule

module logical(i_insn, i_pc, i_r1data, i_r2data, o_result);
   parameter WORD_SIZE = 16;
   input [15:0] i_insn, i_pc;
   input [WORD_SIZE-1:0] i_r1data, i_r2data;
   output [WORD_SIZE-1:0] o_result;

   assign o_result = i_insn[5:3] == 3'b0 ? i_r1data & i_r2data :    //and
                        (i_insn[5:3] == 3'b1 ? ~i_r1data :          //not
                        (i_insn[5:3] == 3'b010 ? i_r1data | i_r2data :  //or
                        (i_insn[5:3] == 3'b011 ? i_r1data ^ i_r2data :          //xor
                        (i_insn[5] == 1'b1 ? i_r1data & {{11{i_insn[4]}}, i_insn[4:0]}: 16'b0)))); //AND

endmodule

module constant(i_insn, i_pc, i_r1data, i_r2data, o_result);
   parameter WORD_SIZE = 16;
   input [15:0] i_insn, i_pc;
   input [WORD_SIZE-1:0] i_r1data, i_r2data;
   output [WORD_SIZE-1:0] o_result;
   wire [WORD_SIZE-1:0] r;
   // call left shift module here
   assign r = i_r1data & 16'hFF; // TODO NEED TO PAD WITH 0's to fill out word_size
   assign o_result = i_insn[15:12] == 4'b1001 ? {{7{i_insn[8]}}, i_insn[8:0]} : // CONST
                    (i_insn[15:12] == 4'b1101 ? {r[15:8] | i_insn[7:0], r[7:0]} : 16'b0 ); // HIGH CONST
endmodule


//0010
module compare(i_insn, i_pc, i_r1data, i_r2data, o_result);
   parameter WORD_SIZE = 16;
   input [15:0] i_insn, i_pc;
   input [WORD_SIZE-1:0] i_r1data, i_r2data;
   output [15:0] o_result;
   wire [15:0] r2;
   wire [16:0] ext1, ext2, s;

   assign r2 = i_insn[8] == 0 ? i_r2data : (i_insn[7] == 0 ? {{9{i_insn[6]}}, i_insn[6:0]} : {9'b0, i_insn[6:0]});
   // if bit 7 is 0, signed comparison
   assign ext1 = i_insn[7] == 1'b0 ? {i_r1data[15], i_r1data[15:0]} : {1'b0, i_r1data[15:0]};
   assign ext2 = i_insn[7] == 1'b0 ? {r2[15], r2[15:0]} : {1'b0, r2[15:0]};
   assign s = ext1 - ext2;
   assign o_result = s[16] == 1 ? 16'hFFFF  : (s == 0 ? 16'b0 : 16'h1);
endmodule

module shifter(i_insn, i_pc, i_r1data, i_r2data, o_result);
   parameter WORD_SIZE = 16;
   input [15:0] i_insn, i_pc;
   input [WORD_SIZE-1:0] i_r1data, i_r2data;
   output [15:0] o_result;
   wire [WORD_SIZE-1:0] sll, sra, srl;

   leftShift #(.WORD_SIZE(WORD_SIZE)) shift0 (i_r1data, {12'b0, i_insn[3:0]}, sll);
   rightShiftLogical #(.WORD_SIZE(WORD_SIZE)) shift1 (i_r1data, {12'b0, i_insn[3:0]}, srl);
   rightShiftAri #(.WORD_SIZE(WORD_SIZE)) shift2 (i_r1data, {12'b0, i_insn[3:0]}, sra);
   assign o_result = i_insn[5:4] == 2'b0 ? sll :
                     (i_insn[5:4] == 2'b1 ? sra :
                     (i_insn[5:4] == 2'b10 ? srl : 16'b0));
endmodule

//barrel shifter
module leftShift(i_value, i_shift, out);
   parameter WORD_SIZE = 16;
   input [WORD_SIZE-1:0] i_value;
   input [15:0] i_shift;
   output [WORD_SIZE-1:0] out;

   assign out = i_value << i_shift;

endmodule

module rightShiftLogical(i_value, i_shift, out);
   parameter WORD_SIZE = 16;
   input [WORD_SIZE-1:0] i_value;
   input [15:0] i_shift;
   output [WORD_SIZE-1:0] out;

   assign out = i_value >> i_shift;
endmodule

  //arithmetic right shift
module rightShiftAri(i_value, i_shift, out);
   parameter WORD_SIZE = 16;
   input [WORD_SIZE-1:0] i_value;
   input [15:0] i_shift;
   output [WORD_SIZE-1:0] out;

   assign out = $signed(i_value) >> i_shift;
 endmodule
