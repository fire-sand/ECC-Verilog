`timescale 1ns / 1ps

`ifndef INSN_CACHE
`define INSN_CACHE 0  // False
`endif

module lc4_memory(idclk,
                  i1re,
                  i2re,
                  dre,
                  gwe,
                  rst,
                  i1addr,
                  i2addr,
                  i1out,
                  i2out,
                  daddr,
                  din,
                  dout,
                  dwe,
                  vaddr,
                  vout,
                  vclk
                  );

  parameter WORD_SIZE = 16;
  input       idclk;
  input       i1re;
  input       i2re;
  input       dre;
  input       gwe;
  input       rst;
  input [15:0]  i1addr;
  input [15:0]  i2addr;
  output [15:0]   i1out;
  output [15:0]   i2out;
  input [15:0]  daddr;
  input [WORD_SIZE-1:0]  din;
  output [WORD_SIZE-1:0]   dout;
  input       dwe;
  input [15:0]  vaddr;
  output [15:0] vout;
  input vclk;

   wire [15:0] i1out_not_delayed;
   wire [15:0] i2out_not_delayed;

   bram #(.WORD_SIZE(WORD_SIZE))
     memory (.idclk(idclk),
                .i1re(i1re),
                .i2re(i2re),
                .dre(dre),
                .gwe(gwe),
                .rst(rst),
                .i1addr(i1addr),
                .i2addr(i2addr),
                .i1out(i1out_not_delayed),
                .i2out(i2out_not_delayed),
                .daddr(daddr),
                .din(din),
                .dout(dout),
                .dwe(dwe),
                .vaddr(vaddr),
                .vout(vout),
                .vclk(vclk)
                );

   wire [15:0] i1out_delayed;
   wire [15:0] i2out_delayed;

   delay_eight_cycles #(16) delayer1 (.clk(idclk),
                          .gwe(gwe),
                          .rst(rst),
                          .in_value(i1out_not_delayed),
                          .out_value(i1out_delayed));

   delay_eight_cycles #(16) delayer2 (.clk(idclk),
                          .gwe(gwe),
                          .rst(rst),
                          .in_value(i2out_not_delayed),
                          .out_value(i2out_delayed));

   assign i1out = `INSN_CACHE ? i1out_delayed : i1out_not_delayed;
   assign i2out = `INSN_CACHE ? i2out_delayed : i2out_not_delayed;

endmodule
