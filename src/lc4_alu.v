`timescale 1ns / 1ps

module lc4_alu(i_insn, i_pc, i_r1data, i_r2data, o_result);
   input [15:0] i_insn, i_pc, i_r1data, i_r2data;
   output [15:0] o_result;
   wire [15:0] r_arith, r_logical, r_shift, r_const, r_cmp;
   wire [3:0] insn;
   wire [15:0] pcJSR, pcTRAP, shifted;
   
   arith ari0 (i_insn, i_pc, i_r1data, i_r2data, r_arith);
   logical log0 (i_insn, i_pc, i_r1data, i_r2data, r_logical);
   shifter shift0 (i_insn, i_pc, i_r1data, i_r2data, r_shift);
   constant const0 (i_insn, i_pc, i_r1data, i_r2data, r_const);
   compare cmp0 (i_insn, i_pc, i_r1data, i_r2data, r_cmp);
   
   leftShift shift1 ({5'b0, i_insn[10:0]}, 16'd4, shifted);
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
   input [15:0] i_insn, i_pc, i_r1data, i_r2data;
   output [15:0] o_result;
   wire [15:0] quotient, remainder;
   
   //assign r2 = i_insn[15:12] == 4'b0 ? i_pc + 1'b1 : 1_r2data;
   lc4_divider div0 (i_r1data, i_r2data, remainder, quotient);
   assign o_result = i_insn[15:9] == 7'b0 ? i_pc + 16'b1 + {{7{i_insn[8]}}, i_insn[8:0]}:              //NOP
                     (i_insn[15:13] == 3'b011 ? i_r1data + {{10{i_insn[5]}}, i_insn[5:0]} :  //ldr, str
                     (i_insn[5:4] == 2'b11 && i_insn[15:12] == 4'b1010 ? remainder :      //mod
                     (i_insn[15:12] == 4'b0 ? {{7{i_insn[8]}}, i_insn[8:0]} + i_pc + 16'b1 :  //BR    
                     (i_insn[15:11] == 5'b11001 ? {{5{i_insn[10]}}, i_insn[10:0]} + i_pc + 16'b1 :  // JMP
                     (i_insn[5:3] == 3'b0 ? i_r1data + i_r2data :    //add
                     (i_insn[5:3] == 3'b1 ? i_r1data * i_r2data :          //mul
                     (i_insn[5:3] == 3'b010 ? i_r1data - i_r2data :  //sub
                     (i_insn[5:3] == 3'b011 ? quotient :             //div
                     (i_insn[5] == 1'b1 ? i_r1data + {{11{i_insn[4]}}, i_insn[4:0]} : 16'b0))))))))) ; //add 
   
endmodule

module logical(i_insn, i_pc, i_r1data, i_r2data, o_result);
   input [15:0] i_insn, i_pc, i_r1data, i_r2data;
   output [15:0] o_result;
   
   assign o_result = i_insn[5:3] == 3'b0 ? i_r1data & i_r2data :    //and
                        (i_insn[5:3] == 3'b1 ? ~i_r1data :          //not
                        (i_insn[5:3] == 3'b010 ? i_r1data | i_r2data :  //or
                        (i_insn[5:3] == 3'b011 ? i_r1data ^ i_r2data :          //xor
                        (i_insn[5] == 1'b1 ? i_r1data & {{11{i_insn[4]}}, i_insn[4:0]}: 16'b0)))); //AND
   
endmodule

module constant(i_insn, i_pc, i_r1data, i_r2data, o_result);
   input [15:0] i_insn, i_pc, i_r1data, i_r2data;
   output [15:0] o_result;
   wire [15:0] r;
   // call left shift module here
   assign r = i_r1data & 16'hFF;
   assign o_result = i_insn[15:12] == 4'b1001 ? {{7{i_insn[8]}}, i_insn[8:0]} :
                    (i_insn[15:12] == 4'b1101 ? {r[15:8] | i_insn[7:0], r[7:0]} : 16'b0 ) ;
endmodule


//0010
module compare(i_insn, i_pc, i_r1data, i_r2data, o_result);
   input [15:0] i_insn, i_pc, i_r1data, i_r2data;
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
   input [15:0] i_insn, i_pc, i_r1data, i_r2data;
   output [15:0] o_result;
   wire [15:0] sll, sra, srl;
   
   leftShift shift0 (i_r1data, {12'b0, i_insn[3:0]}, sll);
   rightShiftLogical shift1 (i_r1data, {12'b0, i_insn[3:0]}, srl);
   rightShiftAri shift2 (i_r1data, {12'b0, i_insn[3:0]}, sra);
   assign o_result = i_insn[5:4] == 2'b0 ? sll : 
                     (i_insn[5:4] == 2'b1 ? sra : 
                     (i_insn[5:4] == 2'b10 ? srl : 16'b0)); 
endmodule

//barrel shifter
module leftShift(i_value, i_shift, out);
   input [15:0] i_value, i_shift;
   output [15:0] out;
   wire [15:0] shift8, shift4, shift2, shift1;
   wire [15:0] s1, s2, s3;
     
   assign shift8 = {i_value[7:0], 8'b0}; 
   assign s1 = i_shift[3] ? shift8 : i_value;
   assign shift4 = {s1[11:0], 4'b0};
   assign s2 = i_shift[2] ? shift4 : s1;
   assign shift2 = {s2[13:0], 2'b0};
   assign s3 = i_shift[1] ? shift2 : s2;
   assign shift1 = {s3[14:0], 1'b0};
   assign out = i_shift[0] ? shift1 : s3;
   
 endmodule
 
 module rightShiftLogical(i_value, i_shift, out);
    input [15:0] i_value, i_shift;
    output [15:0] out;
    wire [15:0] shift8, shift4, shift2, shift1;
    wire [15:0] s1, s2, s3;
      
    assign shift8 = {8'b0, i_value[15:8]}; 
    assign s1 = i_shift[3] ? shift8 : i_value;
    assign shift4 = {4'b0, s1[15:4]};
    assign s2 = i_shift[2] ? shift4 : s1;
    assign shift2 = {2'b0, s2[15:2]};
    assign s3 = i_shift[1] ? shift2 : s2;
    assign shift1 = {1'b0, s3[15:1]};
    assign out = i_shift[0] ? shift1 : s3;
 endmodule
  
  //arithmetic right shift
  module rightShiftAri(i_value, i_shift, out);
      input [15:0] i_value, i_shift;
      output [15:0] out;
      wire [15:0] shift8, shift4, shift2, shift1;
      wire [15:0] s1, s2, s3;
      wire msb;
      
      assign msb = i_value[15];
      assign shift8 = {{8{msb}}, i_value[15:8]}; 
      assign s1 = i_shift[3] ? shift8 : i_value;
      assign shift4 = {{4{msb}}, s1[15:4]};
      assign s2 = i_shift[2] ? shift4 : s1;
      assign shift2 = {{2{msb}}, s2[15:2]};
      assign s3 = i_shift[1] ? shift2 : s2;
      assign shift1 = {{1{msb}}, s3[15:1]};
      assign out = i_shift[0] ? shift1 : s3;
 endmodule