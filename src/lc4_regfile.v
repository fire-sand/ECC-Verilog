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

module lc4_regfile(clk, gwe, rst, r1sel, r1data, wsel, wdata, we);
   /* DO NOT MODIFY THIS CODE */
   parameter WORD_SIZE = 16;
   parameter DADDR = 4;
   parameter n = WORD_SIZE; // default number of bits in the register

   input clk, gwe, rst;            // clock, global write enable, reset
   input [DADDR:0] r1sel, wsel; // register 1 and 2 selectors, and write-back register

   input [n-1:0]  wdata;           // data to write if we is set
   input          we;              // write-enable
   output [n-1:0] r1data;  // data read out of r1 and r2

   // register readout wires for each register in the register file
   wire [n-1:0]   r0, r1;
   /* END DO NOT MODIFY THIS CODE */

   /***********************
    * TODO YOUR CODE HERE *
    ***********************/
   wire r0_decoder, r1_decoder;
   assign r0_decoder = (wsel === 5'b0);
   assign r1_decoder = (wsel === 5'b1);
   Nbit_reg #(n) r0_m (wdata, r0, clk, r0_decoder & we, gwe, rst);
   Nbit_reg #(n) r1_m (wdata, r1, clk, r1_decoder & we, gwe, rst);
   assign r1data = (r1sel === 5'b0) ? r0 : r1;

endmodule

