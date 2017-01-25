`timescale 1ns / 1ps

`include "src/include/set_testcase.v"
// `ifndef MEMORY_IMAGE_FILE
// `define MEMORY_IMAGE_FILE "../../../test_data/test_all.hex"
// `endif

// Memory module
module bram(idclk, i1re, i2re, dre, gwe, rst, i1addr, i2addr, i1out, i2out, daddr, din, dout, dwe, vclk, vaddr, vout);
   input         idclk;
   input         i1re;
   input         i2re;
   input         dre;
   input         gwe;
   input         rst;
   input [15:0]  i1addr;
   input [15:0]  i2addr;
   output [15:0] i1out;
   output [15:0] i2out;
   input [15:0]  daddr;
   input [15:0]  din;
   output [15:0] dout;
   input         dwe;

   input [15:0]  vaddr;
   output [15:0] vout;
   input         vclk;

   reg [15:0]    IDRAM [65535:0];
   reg [15:0]    read_addr;
   reg [15:0]    read_daddr;

   reg [15:0]    VRAM [16383:0];
   reg [15:0]    read_vaddr;

   integer       f;
   wire [15:0]   iaddr, iout;

   // Writing on gwe doesn't work on board for some reason, but dre works
   wire          data_we = dwe && (dre || gwe);
   reg [15:0]    mem_out_i, mem_out_i2, mem_out_d;

   initial
     begin
        f = 0; // Added to avoid a synthesis warning
        $display("%s", `MEMORY_IMAGE_FILE);
      f = $fopen(`MEMORY_IMAGE_FILE, "r");
      if (f == 0)
        begin
           $display("Memory image file %s not found", `MEMORY_IMAGE_FILE);
           $stop;
        end
      $fclose(f);
      $readmemh(`MEMORY_IMAGE_FILE, IDRAM, 0, 65535);
     end


   assign iaddr = (i1re) ? i1addr : i2addr;


   always @(posedge idclk)
     begin
        //#1;
        if (data_we)
          IDRAM[daddr] <= din;
      if (data_we & daddr[15] & daddr[14])  // Only write vram if address starts with "11"
        VRAM[daddr[13:0]] <= din;
      if (i1re || i2re)
        mem_out_i <= IDRAM[iaddr];
      if (dre)
        mem_out_d <= IDRAM[daddr];
     end

   always @(posedge vclk)
     begin
        read_vaddr <= vaddr;
     end

   // Values don't come out of mem for another cycle, so we gotta adjust
   // our read enables.  We could latch our read enables for clarity,
   // but we know when the read enables strobe:
   // 1 i1re
   // 2 i2re
   // 3 dre
   // 4 gwe

   wire i1re_latched_one_cycle = i2re; // i1re + 1 clkid cycle
   wire i2re_latched_one_cycle = dre; // i2re + 1 clkid cycle
   wire [15:0] i1out_latched, i2out_latched;

   //time multiplex values by latching
   Nbit_reg #(16, 16'd0) i1out_reg (.in(mem_out_i), .out(i1out_latched), .clk(idclk), .we(i1re_latched_one_cycle), .gwe(1'b1), .rst(rst));
   Nbit_reg #(16, 16'd0) i2out_reg (.in(mem_out_i), .out(i2out_latched), .clk(idclk), .we(i2re_latched_one_cycle), .gwe(1'b1), .rst(rst));

   //bypass reg values
   assign i1out = (i1re_latched_one_cycle) ? mem_out_i : i1out_latched;
   assign i2out = (i2re_latched_one_cycle) ? mem_out_i : i2out_latched;

   assign dout = mem_out_d;
   assign vout = VRAM[read_vaddr[13:0]];

endmodule // bram
