`default_nettype none

module top (
  input CLK,
  input RS232_rx,
  input RS232_tx,
  input LED1,
  input LED2,
  input LED3,
  input LED4
);
parameter WORD_SIZE = 16;
  wire proc_clk;
  assign proc_clk = CLK;
  wire GLOBAL_RST = 1;
  wire GLOBAL_WE;

  wire          i1re, i2re, dre, gwe_out;
  lc4_we_gen we_gen(.clk(proc_clk),
                   .i1re(i1re),
                   .i2re(i2re),
                   .dre(dre),
                   .gwe(gwe_out));



  // PROCESSOR
  lc4_processor #(.WORD_SIZE(WORD_SIZE))
      proc_inst(.clk(proc_clk),
                          .rst(GLOBAL_RST),
                          .gwe(GLOBAL_WE),
                          .o_cur_pc(imem1_addr),
                          .i_cur_insn(imem1_out),
                          .o_dmem_addr(dmem_addr),
                          .i_cur_dmem_data(dmem_mout),
                          .o_dmem_we(dmem_we),
                          .o_dmem_towrite(dmem_in),
                          .switch_data(SWITCH_IN),
                          .seven_segment_data(seven_segment_data),
                          .led_data(led_data)
                          );

