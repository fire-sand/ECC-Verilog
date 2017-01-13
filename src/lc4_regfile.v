/*
 Aasif Versi - versia
 Renyao Wei - renyaow
 Dong Young Kim - kido

 * lc4_regfile.v
 * Implements an 8-register register file parameterized on word size.
 *
 * TODO: Contributions of each group member to this file

 */

`timescale 1ns / 1ps

module lc4_regfile(clk, gwe, rst, r1sel, r1data, r2sel, r2data, wsel, wdata, we);
   /* DO NOT MODIFY THIS CODE */
   parameter n = 16; // default number of bits in the register

   input clk, gwe, rst;            // clock, global write enable, reset
   input [2:0] r1sel, r2sel, wsel; // register 1 and 2 selectors, and write-back register

   input [n-1:0]  wdata;           // data to write if we is set
   input          we;              // write-enable
   output [n-1:0] r1data, r2data;  // data read out of r1 and r2

   // register readout wires for each register in the register file
   wire [n-1:0]   r0, r1, r2, r3, r4, r5, r6, r7;
   /* END DO NOT MODIFY THIS CODE */

   /***********************
    * TODO YOUR CODE HERE *
    ***********************/
   wire r0_decoder, r1_decoder, r2_decoder, r3_decoder, r4_decoder, r5_decoder, r6_decoder, r7_decoder;
   one_hot_decoder decoder_m (wsel, r0_decoder, r1_decoder, r2_decoder, r3_decoder, r4_decoder, r5_decoder, r6_decoder, r7_decoder);
   Nbit_reg #(n) r0_m (wdata, r0, clk, r0_decoder & we, gwe, rst);
   Nbit_reg #(n) r1_m (wdata, r1, clk, r1_decoder & we, gwe, rst);
   Nbit_reg #(n) r2_m (wdata, r2, clk, r2_decoder & we, gwe, rst);
   Nbit_reg #(n) r3_m (wdata, r3, clk, r3_decoder & we, gwe, rst);
   Nbit_reg #(n) r4_m (wdata, r4, clk, r4_decoder & we, gwe, rst);
   Nbit_reg #(n) r5_m (wdata, r5, clk, r5_decoder & we, gwe, rst);
   Nbit_reg #(n) r6_m (wdata, r6, clk, r6_decoder & we, gwe, rst);
   Nbit_reg #(n) r7_m (wdata, r7, clk, r7_decoder & we, gwe, rst);
   Nbit_mux8to1 #(n) mux1 (r1sel, r0, r1, r2, r3, r4, r5, r6, r7, r1data);
   Nbit_mux8to1 #(n) mux2 (r2sel, r0, r1, r2, r3, r4, r5, r6, r7, r2data);    

endmodule

module one_hot_decoder(rd, r0_decoder, r1_decoder, r2_decoder, r3_decoder, r4_decoder, r5_decoder, r6_decoder, r7_decoder);

   input [2:0] rd;
   output r0_decoder, r1_decoder, r2_decoder, r3_decoder, r4_decoder, r5_decoder, r6_decoder, r7_decoder;
   
   assign r0_decoder = (rd == 3'd0) ? 1'b1 : 1'b0;
   assign r1_decoder = (rd == 3'd1) ? 1'b1 : 1'b0; 
   assign r2_decoder = (rd == 3'd2) ? 1'b1 : 1'b0;
   assign r3_decoder = (rd == 3'd3) ? 1'b1 : 1'b0;
   assign r4_decoder = (rd == 3'd4) ? 1'b1 : 1'b0; 
   assign r5_decoder = (rd == 3'd5) ? 1'b1 : 1'b0;
   assign r6_decoder = (rd == 3'd6) ? 1'b1 : 1'b0; 
   assign r7_decoder = (rd == 3'd7) ? 1'b1 : 1'b0; 

endmodule

module Nbit_mux8to1(s, i_0, i_1, i_2, i_3, i_4, i_5, i_6, i_7, out);
   parameter N = 16;
   input [2:0] s;
   input [N-1:0] i_0, i_1, i_2, i_3, i_4, i_5, i_6, i_7;
   output [N-1:0] out;
   
   assign out = (s == 3'd0) ? i_0 : 
                ((s == 3'd1) ? i_1 :
                ((s == 3'd2) ? i_2 :
                ((s == 3'd3) ? i_3 :
                ((s == 3'd4) ? i_4 : 
                ((s == 3'd5) ? i_5 : 
                ((s == 3'd6) ? i_6 : i_7))))));
endmodule