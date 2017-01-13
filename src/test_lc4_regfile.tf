/* test_lc4_regfile
 *
 * Testbench for teh register file
 */

`timescale 1ns / 1ps

`define EOF 32'hFFFF_FFFF
`define NEWLINE 10
`define NULL 0

`include "include/set_testcase.v"


module testbench_v;

   integer     input_file, output_file, errors, linenum;


   // Inputs
   reg         wen;
   reg         rst;
   reg         clk;
   reg         gwe;
   
   reg [2:0]   rsel1;
   reg [2:0]   rsel2;
   reg [2:0]   wsel;
   
   reg [15:0]  wdata;
   
   // Outputs
   wire [15:0] rdata1;
   wire [15:0] rdata2;
   
   // Instantiate the Unit Under Test (UUT)
   
   lc4_regfile regfile (.r1sel(rsel1),
                        .r2sel(rsel2),
                        .wsel(wsel),
                        .r1data(rdata1),
                        .r2data(rdata2), 
                        .wdata(wdata),
                        .we(wen),
                        .gwe(gwe),
                        .rst(rst),
                        .clk(clk)
                        );
   
   reg [15:0]  expectedValue1;
   reg [15:0]  expectedValue2;
   
   always #5 clk <= ~clk;
   
   initial begin
      
      // Initialize Inputs
      rsel1 = 0;
      rsel2 = 0;
      wsel = 0;
      wen = 0;
      rst = 1;
      wdata = 0;
      clk = 0;
      gwe = 1;

      errors = 0;
      linenum = 0;
      output_file = 0;

      // open the test inputs
      input_file = $fopen(`REGISTER_INPUT, "r");
      if (input_file == `NULL) begin
         $display("Error opening file: ", `REGISTER_INPUT);
         $finish;
      end

      // open the output file
`ifdef REGISTER_OUTPUT
      output_file = $fopen(`REGISTER_OUTPUT, "w");
      if (output_file == `NULL) begin
         $display("Error opening file: ", `REGISTER_OUTPUT);
         $finish;
      end
`endif
      
      // Wait for global reset to finish
      #100;
      
      #5 rst = 0;
      
      #2;         

      while (7 == $fscanf(input_file, "%d %d %d %b %h %h %h", rsel1, rsel2, wsel, wen, wdata, expectedValue1, expectedValue2)) begin
         
         #8;
         
         linenum = linenum + 1;
         
         // $display("linenum: ", linenum);
         
         if (output_file) begin
            $fdisplay(output_file, "%d %d %d %b %h %h %h", rsel1, rsel2, wsel, wen, wdata, rdata1, rdata2);
         end

         if (rdata1 !== expectedValue1) begin
            $display("Error at line %d: Value of register %b on output 1 should have been %h, but was %h instead", linenum, rsel1, expectedValue1, rdata1);
            errors = errors + 1;
         end
         
         if (rdata2 !== expectedValue2) begin
            $display("Error at line %d: Value of register %b on output 2 should have been %h, but was %h instead", linenum, rsel2, expectedValue2, rdata2);
            errors = errors + 1;
         end
         
         #2;         
         
      end // end while
      
      if (input_file) $fclose(input_file); 
      if (output_file) $fclose(output_file);
      $display("Simulation finished: %d test cases %d errors [%s]", linenum, errors, `REGISTER_INPUT);
      $finish;
   end
   
endmodule
