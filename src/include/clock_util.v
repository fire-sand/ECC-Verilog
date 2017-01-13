`timescale 1ns / 1ps

// VERSION 1.1

module count(clk, out);
  parameter n = 2;
  input clk;
  output [n-1:0] out;

  reg [n-1:0]q;

   initial begin
      q = 0;
   end

  always @(posedge clk)    
     begin      
          q = (q==2**n) ? 0 : q+1;
     end 
	  assign #(1) out = q;
	  
	
endmodule 

module lc4_we_gen(clk, i1re, i2re, dre, gwe);
    input clk;
    output i1re;
	 output i2re;
    output dre;
    output gwe;


	//generate gwe, ire, and dre signals by counting the small clock
   wire [1:0] clk_counter;
	
   count #(2) global_we_count(.clk( clk ), 
                              .out( clk_counter ));
	
	assign i1re = (clk_counter == 2'd0);
	assign i2re = (clk_counter == 2'd1);
	assign dre = (clk_counter == 2'd2);
	assign gwe = (clk_counter == 2'd3);
	



 


endmodule