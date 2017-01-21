/* register.v
 * A parameterized-width positive-edge-trigged register, with synchronous reset. 
 * The value to take on after a reset is the 2nd parameter.
 * 
 * DO NOT MODIFY
 */

`timescale 1ns / 1ps


module Nbit_reg(in, out, clk, we, gwe, rst);
   parameter n = 1;
   parameter r = 0;
   
   output [n-1:0] out;
   input [n-1:0]  in;   
   input          clk;
   input          we;
   input          gwe;
   input          rst;      

   reg [n-1:0] state;

   assign #(1) out = state;

   always @(posedge clk) 
     begin 
       if (gwe & rst) 
         state = r;
       else if (gwe & we) 
         state = in; 
     end
endmodule
