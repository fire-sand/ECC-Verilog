/* lc4_system.v
 * DO NOT MODIFY
 */

`timescale 1ns / 1ps

module lc4_system(/*Clock input from FPGA pin*/
  CLK,
  RS232_Rx,
  SWITCH1, SWITCH2, SWITCH3, SWITCH4, SWITCH5, SWITCH6, SWITCH7, SWITCH8,
  RS232_Tx,
  LED1,
  LED2,
  LED3,
  LED4,
  led_data,
  dmem_mout_out,
);

  parameter WORD_SIZE = 64;
  input         CLK;     // System clock Default of 12 MHz
  input RS232_Rx;
  input SWITCH1, SWITCH2, SWITCH3, SWITCH4, SWITCH5, SWITCH6, SWITCH7, SWITCH8;
  output RS232_Tx;
  output LED1;
  output LED2;
  output LED3;
  output LED4;
  output [15:0] dmem_mout_out;
  assign dmem_mout_out = dmem_mout;

  wire [15:0]   seven_segment_data;
  output [7:0]    led_data;

  wire GLOBAL_RST = 1;
  wire GLOBAL_WE;
  wire dcm_reset_1 = 1'b0;
  wire dcm_reset_2 = 1'b0;
  wire proc_clk = CLK;
  wire pixel_clk = CLK;

  wire [7:0] SWITCH_IN = {SWITCH1, SWITCH2, SWITCH3, SWITCH4, SWITCH5, SWITCH6, SWITCH7, SWITCH8};

  wire          RST_BTN_IN;     // Right push button
  wire          GWE_BTN_IN;     // Down push button
  assign RST_BTN_IN = SWITCH_IN[0];
  assign GWE_BTN_IN = 1'b0;


  /* Generate "single-step clock" by one-pulsing the global
  write-enable. The one-pulse circuitry cleans up the signal edges
  for us. */
  wire          global_we_pulse;
  one_pulse clk_pulse(.clk( proc_clk ),
                     .rst( dcm_reset_1 | dcm_reset_2 ),
                     .btn( GWE_BTN_IN ), // FPGA buttons are active-low
                     .pulse_out( global_we_pulse ));

  /* Clean up trailing edges of the GLOBAL_WE switch input */
  wire          global_we_switch;

  Nbit_reg #(1, 0) gwe_cleaner(.in(SWITCH_IN[7]), // FPGA switches are active-low
                              .out( global_we_switch ),
                              .clk( proc_clk ),
                              .we( 1'b1 ),
                              .gwe( 1'b1 ),
                              .rst( GLOBAL_RST ));


  wire          i1re, i2re, dre, gwe_out;
  lc4_we_gen we_gen(.clk(proc_clk),
                   .i1re(i1re),
                   .i2re(i2re),
                   .dre(dre),
                   .gwe(gwe_out));


  assign GLOBAL_WE = global_we_pulse | (gwe_out & global_we_switch);



  /* Clean up the edges of the manual reset signal. Only the trailing
  edge should really matter, though.*/
  wire          rst_btn;
  Nbit_reg #(1, 0) reset_cleaner(.in( RST_BTN_IN ),
                .out( rst_btn ),
                                .clk( proc_clk ),
                                .we( 1'b1 ),
                                .gwe( 1'b1 ),
                                .rst( dcm_reset_1 | dcm_reset_2 ));
  or( GLOBAL_RST, dcm_reset_1, dcm_reset_2, rst_btn );

  // MEMORY INTERFACE
  // INSTRUCTIONS
  wire [15:0]   imem1_addr, imem2_addr;
  wire [15:0]   imem1_out, imem2_out;
  // DATA MEMORY
  wire [15:0]   dmem_addr;
  wire [WORD_SIZE-1:0]   dmem_in;
  wire          dmem_we;
  wire [WORD_SIZE-1:0]   dmem_mout;

  wire [13:0]   vga_addr;
  wire [WORD_SIZE-1:0]   vga_data;

  wire          kbdr = 1'b0;
  wire          kbsr = 1'b0;
  wire          tsr = 1'b0;

  // MEMORY/DEVICE MUX
  //wire [WORD_SIZE-1:0]   dmem_out = dmem_we ? 16'h0000 :
                //(dmem_addr == 16'hFE00) ? {kbsr, {15{1'b0}}} :
                //(dmem_addr == 16'hFE02) ? {8'h00, kbdr} :
                //(dmem_addr == 16'hFE08) ? {tsr, {15{1'b0}}} :
                //(dmem_addr < 16'hFE00) ? dmem_mout : 16'h0000;



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

  assign imem2_addr = 16'd0;
  assign RS232_Tx = led_data[0];
  assign LED1 = led_data[1];
  assign LED2 = led_data[2];
  assign LED3 = led_data[3];
  assign LED4 = led_data[4];

  // MEMORY

  // The memory for bit-mapped video and other I/O. Port a is a read-only
  // port for the VGA video. Port b is a read-write port for memory-mapped
  // I/O data. The addresses used in the memory are only 14 bits because the
  // most-significant bits are always 11. Port b is accessed in the memory
  // stage of a pipeline; memory-mapped I/O is implemented by executing loads
  // and stores to I/O memory.

  lc4_memory
    #(.WORD_SIZE(WORD_SIZE))
    memory (.idclk(proc_clk),
                    .i1re(i1re),
                    .i2re(i2re),
                    .dre(dre),
                    .gwe(GLOBAL_WE),
                    .rst(GLOBAL_RST),
                    .i1addr(imem1_addr),
                    .i2addr(imem2_addr),
                    .i1out(imem1_out),
                    .i2out(imem2_out),
                    .daddr(dmem_addr),
                    .din(dmem_in),
                    .dout(dmem_mout),
                    .dwe(dmem_we),
                    .vaddr({2'b11, vga_addr}),
                    .vout(vga_data),     //VGA data out
                    .vclk(pixel_clk)     //VGA clock
                    );


  // PS/2 KEYBOARD CONTROLLER
  //fake_pb_kbd fake_kbd_inst( .read_kbsr( read_kbsr ),
                            //.kbsr( kbsr ),
                            //.read_kbdr( read_kbdr ),
                            //.kbdr( kbdr ),
              //.proc_clk( proc_clk ),
              //.reset( GLOBAL_RST ),
              //.ZED_PB( ZED_PB ));


  // Timer device
  //timer_device timer(.write_interval( write_tir ),
                    //.interval_in( dmem_in ),
                    //.read_status( read_tsr ),
                    //.status_out ( tsr ),
                    //.GWE(GLOBAL_WE),
                    //.RST(GLOBAL_RST),
                    //.CLK(proc_clk));

  //vga_controller handles the VGA signals.
  // PMG: removed outputs not used on the Zedboard
  //vga_controller vga_cntrl_inst(.PIXEL_CLK(~pixel_clk),
                                //.RESET(GLOBAL_RST),
                                //.VGA_HSYNCH(VGA_HSYNCH),
                                //.VGA_VSYNCH(VGA_VSYNCH),
                                //.VGA_OUT_RED(VGA_OUT_RED),
                                //.VGA_OUT_GREEN(VGA_OUT_GREEN),
                                //.VGA_OUT_BLUE(VGA_OUT_BLUE),
                                //.VGA_ADDR(vga_addr),
                                //.VGA_DATA(vga_data[14:0]));

endmodule
