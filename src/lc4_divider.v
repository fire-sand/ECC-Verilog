/*Aasif Versi/versia*/
`timescale 1ns / 1ps

module lc4_divider(i_dividend, i_divisor, o_remainder, o_quotient);
   
   input  [15:0] i_dividend,  i_divisor;
   output [15:0] o_remainder, o_quotient;
   wire [15:0] iter1_o_dividend, iter1_o_quotient, iter1_o_remainder;
   wire [15:0] iter2_o_dividend, iter2_o_quotient, iter2_o_remainder;
   wire [15:0] iter3_o_dividend, iter3_o_quotient, iter3_o_remainder;
   wire [15:0] iter4_o_dividend, iter4_o_quotient, iter4_o_remainder;
   wire [15:0] iter5_o_dividend, iter5_o_quotient, iter5_o_remainder;
   wire [15:0] iter6_o_dividend, iter6_o_quotient, iter6_o_remainder;
   wire [15:0] iter7_o_dividend, iter7_o_quotient, iter7_o_remainder;
   wire [15:0] iter8_o_dividend, iter8_o_quotient, iter8_o_remainder;
   wire [15:0] iter9_o_dividend, iter9_o_quotient, iter9_o_remainder;
   wire [15:0] iter10_o_dividend, iter10_o_quotient, iter10_o_remainder;
   wire [15:0] iter11_o_dividend, iter11_o_quotient, iter11_o_remainder;
   wire [15:0] iter12_o_dividend, iter12_o_quotient, iter12_o_remainder;
   wire [15:0] iter13_o_dividend, iter13_o_quotient, iter13_o_remainder;
   wire [15:0] iter14_o_dividend, iter14_o_quotient, iter14_o_remainder;
   wire [15:0] iter15_o_dividend, iter15_o_quotient, iter15_o_remainder;
   wire [15:0] iter16_o_dividend, iter16_o_quotient, iter16_o_remainder;

   /*** YOUR CODE HERE ***/
   //Place 16 modules of lc4_divider_one_iter
   lc4_divider_one_iter iter1 (.i_dividend(i_dividend), .i_divisor(i_divisor), .i_remainder(16'b0), .i_quotient(16'b0), .o_dividend(iter1_o_dividend), .o_remainder(iter1_o_remainder), .o_quotient(iter1_o_quotient));
   lc4_divider_one_iter iter2 (.i_dividend(iter1_o_dividend), .i_divisor(i_divisor), .i_remainder(iter1_o_remainder), .i_quotient(iter1_o_quotient), .o_dividend(iter2_o_dividend), .o_remainder(iter2_o_remainder), .o_quotient(iter2_o_quotient));
   lc4_divider_one_iter iter3 (.i_dividend(iter2_o_dividend), .i_divisor(i_divisor), .i_remainder(iter2_o_remainder), .i_quotient(iter2_o_quotient), .o_dividend(iter3_o_dividend), .o_remainder(iter3_o_remainder), .o_quotient(iter3_o_quotient));
   lc4_divider_one_iter iter4 (.i_dividend(iter3_o_dividend), .i_divisor(i_divisor), .i_remainder(iter3_o_remainder), .i_quotient(iter3_o_quotient), .o_dividend(iter4_o_dividend), .o_remainder(iter4_o_remainder), .o_quotient(iter4_o_quotient));
   lc4_divider_one_iter iter5 (.i_dividend(iter4_o_dividend), .i_divisor(i_divisor), .i_remainder(iter4_o_remainder), .i_quotient(iter4_o_quotient), .o_dividend(iter5_o_dividend), .o_remainder(iter5_o_remainder), .o_quotient(iter5_o_quotient));
   lc4_divider_one_iter iter6 (.i_dividend(iter5_o_dividend), .i_divisor(i_divisor), .i_remainder(iter5_o_remainder), .i_quotient(iter5_o_quotient), .o_dividend(iter6_o_dividend), .o_remainder(iter6_o_remainder), .o_quotient(iter6_o_quotient));
   lc4_divider_one_iter iter7 (.i_dividend(iter6_o_dividend), .i_divisor(i_divisor), .i_remainder(iter6_o_remainder), .i_quotient(iter6_o_quotient), .o_dividend(iter7_o_dividend), .o_remainder(iter7_o_remainder), .o_quotient(iter7_o_quotient));
   lc4_divider_one_iter iter8 (.i_dividend(iter7_o_dividend), .i_divisor(i_divisor), .i_remainder(iter7_o_remainder), .i_quotient(iter7_o_quotient), .o_dividend(iter8_o_dividend), .o_remainder(iter8_o_remainder), .o_quotient(iter8_o_quotient));
   lc4_divider_one_iter iter9 (.i_dividend(iter8_o_dividend), .i_divisor(i_divisor), .i_remainder(iter8_o_remainder), .i_quotient(iter8_o_quotient), .o_dividend(iter9_o_dividend), .o_remainder(iter9_o_remainder), .o_quotient(iter9_o_quotient));
   lc4_divider_one_iter iter10 (.i_dividend(iter9_o_dividend), .i_divisor(i_divisor), .i_remainder(iter9_o_remainder), .i_quotient(iter9_o_quotient), .o_dividend(iter10_o_dividend), .o_remainder(iter10_o_remainder), .o_quotient(iter10_o_quotient));
   lc4_divider_one_iter iter11 (.i_dividend(iter10_o_dividend), .i_divisor(i_divisor), .i_remainder(iter10_o_remainder), .i_quotient(iter10_o_quotient), .o_dividend(iter11_o_dividend), .o_remainder(iter11_o_remainder), .o_quotient(iter11_o_quotient));
   lc4_divider_one_iter iter12 (.i_dividend(iter11_o_dividend), .i_divisor(i_divisor), .i_remainder(iter11_o_remainder), .i_quotient(iter11_o_quotient), .o_dividend(iter12_o_dividend), .o_remainder(iter12_o_remainder), .o_quotient(iter12_o_quotient));
   lc4_divider_one_iter iter13 (.i_dividend(iter12_o_dividend), .i_divisor(i_divisor), .i_remainder(iter12_o_remainder), .i_quotient(iter12_o_quotient), .o_dividend(iter13_o_dividend), .o_remainder(iter13_o_remainder), .o_quotient(iter13_o_quotient));
   lc4_divider_one_iter iter14 (.i_dividend(iter13_o_dividend), .i_divisor(i_divisor), .i_remainder(iter13_o_remainder), .i_quotient(iter13_o_quotient), .o_dividend(iter14_o_dividend), .o_remainder(iter14_o_remainder), .o_quotient(iter14_o_quotient));
   lc4_divider_one_iter iter15 (.i_dividend(iter14_o_dividend), .i_divisor(i_divisor), .i_remainder(iter14_o_remainder), .i_quotient(iter14_o_quotient), .o_dividend(iter15_o_dividend), .o_remainder(iter15_o_remainder), .o_quotient(iter15_o_quotient));
   lc4_divider_one_iter iter16 (.i_dividend(iter15_o_dividend), .i_divisor(i_divisor), .i_remainder(iter15_o_remainder), .i_quotient(iter15_o_quotient), .o_dividend(iter16_o_dividend), .o_remainder(iter16_o_remainder), .o_quotient(iter16_o_quotient));    
   //Check to see if divisor == 0 at end to see what should be assigned to outputs
   assign o_quotient = (i_divisor  == 16'h0000) ? 16'h0000 : iter16_o_quotient; 
   assign o_remainder = (i_divisor  == 16'h0000) ? 16'h0000 : iter16_o_remainder;
endmodule

module lc4_divider_one_iter(i_dividend, i_divisor, i_remainder, i_quotient, 
                            o_dividend, o_remainder, o_quotient);
   
   input  [15:0] i_dividend, i_divisor, i_remainder, i_quotient;
   output [15:0] o_dividend, o_remainder, o_quotient;
   
   /*** YOUR CODE HERE ***/
   wire [15:0] t_remainder;
   wire [15:0] i_L1_remainder;
   assign i_L1_remainder = {i_remainder[14:0], 1'b0};
   assign t_remainder = (({i_remainder[14:0], 1'b0}) | (i_dividend[15]) & 1'b1);
   assign o_quotient = (t_remainder < i_divisor) ? (({i_quotient[14:0], 1'b0}) | 1'b0) : ({i_quotient[14:0], 1'b0} | 1'b1);   
   assign o_remainder = (t_remainder < i_divisor) ? (t_remainder) : (t_remainder - i_divisor);
   assign o_dividend = ({i_dividend[14:0], 1'b0});
endmodule