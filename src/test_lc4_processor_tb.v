`timescale 1ns / 1ps
`default_nettype none

`define EOF 32'hFFFF_FFFF
`define NEWLINE 10
`define NULL 0

`include "src/include/set_testcase.v"

// `include "src/include/lc4_prettyprint_errors.v"

// `ifndef INPUT_FILE
// `define INPUT_FILE "/home/bjbrown/cis371/hw/lab2/ref_impl/test_data/test_all.trace"
// `endif

// `ifndef OUTPUT_FILE
// `define OUTPUT_FILE "/home/bjbrown/cis371/hw/lab2/ref_impl/test_data/test_all.output"
// `endif

module test_lc4_processor_tb();

   parameter WORD_SIZE = 256;
   parameter REG_ADDR_BITS = 5;
   parameter INSN = 19;
   parameter IADDR = 10;

   integer     input_file, output_file, errors, linenum;
   integer     num_cycles;
   integer     num_exec, num_cache_stall, num_branch_stall, num_load_stall;

   integer     next_instruction;

   // Inputs
   reg clk;
   reg rst;
   wire [INSN:0] cur_insn;
   wire [WORD_SIZE-1:0] cur_dmem_data;

   // Outputs
   wire [IADDR:0] cur_pc;
   wire [REG_ADDR_BITS-1:0] dmem_raddr;
   wire [REG_ADDR_BITS-1:0] dmem_waddr;
   wire [WORD_SIZE-1:0] dmem_tworite;
   wire        dmem_we;

   wire [1:0]  test_stall;       // Testbench: is this is stall cycle? (don't compare the test values)
   wire [IADDR:0] test_pc;          // Testbench: program counter
   wire [INSN:0] test_insn;        // Testbench: instruction bits
   wire        test_regfile_we;  // Testbench: register file write enable
   wire [REG_ADDR_BITS-1:0]  test_wsel; // Testbench: which register to write in the register file
   wire [WORD_SIZE-1:0] test_wdata;  // Testbench: value to write into the register file
   wire        test_nzp_we;      // Testbench: NZP condition codes write enable
   wire [2:0]  test_nzp_new_bits;      // Testbench: value to write to NZP bits
   wire        test_dmem_we;     // Testbench: data memory write enable
   wire [REG_ADDR_BITS-1:0] test_dmem_addr;   // Testbench: address to write memory
   wire [WORD_SIZE-1:0] test_dmem_data;  // Testbench: value to write memory

   reg  [IADDR:0] verify_pc;
   reg  [INSN:0] verify_insn;
   reg         verify_regfile_we;
   reg  [REG_ADDR_BITS-1:0]  verify_wsel;
   reg  [WORD_SIZE-1:0] verify_wdata;
   reg         verify_nzp_we;
   reg  [2:0]  verify_nzp_new_bits;
   reg [15:0]  file_status;



   always #5 clk <= ~clk;

   // Produce gwe and other we signals using same modules as lc4_system
   wire        i1re, i2re, dre, gwe;
   lc4_we_gen we_gen(.clk(clk),
         .i1re(i1re),
         .i2re(i2re),
         .dre(dre),
         .gwe(gwe));


   // Data and video memory block
   lc4_memory #(.WORD_SIZE(WORD_SIZE)) memory (.idclk(clk),
          .i1re(i1re),
          .i2re(i2re),
          .dre(dre),
          .gwe(gwe),
          .rst(rst),
                      .i1addr(cur_pc),
          .i2addr(16'd0),      // Not used for scalar jrocessor
                      .i1out(cur_insn),
                      .draddr(dmem_raddr),
                      .dwaddr(dmem_waddr),
          .din(dmem_tworite),
                      .dout(cur_dmem_data),
                      .dwe(dmem_we)
          );


   // Instantiate the Unit Under Test (UUT)
   lc4_processor #(.WORD_SIZE(WORD_SIZE)) proc_inst (.clk(clk),
                            .rst(rst),
                            .gwe(gwe),
                            .o_cur_pc(cur_pc),
                            .i_cur_insn(cur_insn),
                            .o_dmem_raddr(dmem_raddr),
                            .o_dmem_waddr(dmem_waddr),
                            .o_dmem_towrite(dmem_tworite),
                            .i_cur_dmem_data(cur_dmem_data),
                            .o_dmem_we(dmem_we),
                            .test_pc(test_pc),
                            .test_insn(test_insn),
                            .test_regfile_we(test_regfile_we),
                            .test_wsel(test_wsel),
                            .test_wdata(test_wdata),
                            .test_nzp_we(test_nzp_we),
                            .test_nzp_new_bits(test_nzp_new_bits)
                            );

   initial begin
      // Initialize Inputs
      clk = 0;
      rst = 1;
      linenum = 0;
      errors = 0;
      num_cycles = 0;
      num_exec = 0;
      num_cache_stall = 0;
      num_branch_stall = 0;
      num_load_stall = 0;
      file_status = 10;


      // open the test inputs
      input_file = $fopen(`INPUT_FILE, "r");
      if (input_file == `NULL) begin
         $display("Error opening file: %s", `INPUT_FILE);
         $finish;
      end

      // open the output file
`ifdef OUTPUT_FILE
      output_file = $fopen(`OUTPUT_FILE, "w");
      if (output_file == `NULL) begin
         $display("Error opening file: %s", `OUTPUT_FILE);
         $finish;
      end
`endif


      #80
      // Wait for global reset to finish
      rst = 0;
      #32;
      //10 == $fscanf(input_file, "%h %b %h %h %h %h %h %h %h %h",
                           //verify_pc,
                           //verify_insn,
                           //verify_regfile_we,
                           //verify_regfile_reg,
                           //verify_regfile_in,
                           //verify_nzp_we,
                           //verify_nzp_new_bits,
                           //verify_dmem_we,
                           //verify_dmem_addr,
                           //verify_dmem_data)
      while (7 == $fscanf(input_file, "%h %b %h %h %b %b %b"
                                          , verify_pc
                                          , verify_insn
                                          , verify_wdata
                                          , verify_wsel
                                          , verify_regfile_we
                                          , verify_nzp_we
                                          , verify_nzp_new_bits)) begin
         linenum = linenum + 1;

         if (linenum % 10000 == 0) begin
            $display("Instruction number: %d", linenum);
         end
         next_instruction = 0;
         while (!next_instruction) begin

         //if (output_file) begin
            //$fdisplay(output_file, "%h %b %h %h %h %h %h %h %h %h",
                      //verify_pc,
                      //verify_insn,
                      //verify_regfile_we,
                      //verify_wsel,
                      //verify_regfile_in,
                      //verify_nzp_we,
                      //verify_nzp_new_bits,
                      //verify_dmem_we,
                      //verify_dmem_addr,
                      //verify_dmem_data);
         //end
            next_instruction = 1;  // true

            if (next_instruction) begin

               // Check it before fetching the next instruction

               // pc
               if (verify_pc !== test_pc) begin
                  $display( "Error at line %d: pc should be %h (but was %h)",
                            linenum, verify_pc, test_pc);
                  errors = errors + 1;
                  $finish;
               end

               // insn
               if (verify_insn !== test_insn) begin
                  $write("Error at line %d: insn should be %h (", linenum, verify_insn);
                  // pinstr(verify_insn);
                  $write(") but was %h (", test_insn);
                  // pinstr(test_insn);
                  $display(")");
                  errors = errors + 1;
                  $finish;
               end

               // regfile_we
               if (verify_regfile_we !== test_regfile_we) begin
                  $display( "Error at line %d: regfile_we should be %h (but was %h)",
                            linenum, verify_regfile_we, test_regfile_we);
                  errors = errors + 1;
                  $finish;
               end

               // wsel
               if (verify_regfile_we && verify_wsel !== test_wsel) begin
                  $display( "Error at line %d: wsel should be %h (but was %h)",
                            linenum, verify_wsel, test_wsel);
                  errors = errors + 1;
                  $finish;
               end

               // wdata
               if (verify_regfile_we && verify_wdata !== test_wdata) begin
                  $display( "Error at line %d: wdata should be %h (but was %h)",
                            linenum, verify_wdata, test_wdata);
                  errors = errors + 1;
                  $finish;
               end

               // verify_nzp_we
               if (verify_nzp_we !== test_nzp_we) begin
                  $display( "Error at line %d: nzp_we should be %h (but was %h)",
                            linenum, verify_nzp_we, test_nzp_we);
                  errors = errors + 1;
                  $finish;
               end

               // verify_nzp_new_bits
               if (verify_nzp_we && verify_nzp_new_bits !== test_nzp_new_bits) begin
                  $display( "Error at line %d: nzp_new_bits should be %h (but was %h)",
                            linenum, verify_nzp_new_bits, test_nzp_new_bits);
                  errors = errors + 1;
                  $finish;
               end
               if (test_insn === 20'h88000) begin
                  $display("Hit done instruction");
                  //$finish;
               end
            end // if (next_instruction)

            // Advanced to the next cycle
            num_cycles = num_cycles + 1;

      #40;  // Next cycle

         end // while (!next_instruction)

      end // while (10 == $fscanf(input_file, "%h %b %h %h %h %h %h %h %h %h",...

      if (input_file) $fclose(input_file);
      if (output_file) $fclose(output_file);
      $display("Simulation finished: %d test cases %d errors [%s]", linenum, errors, `INPUT_FILE);

      if (linenum != num_cycles) begin
         $display("  Instructions:         %d", linenum);
         $display("  Total Cycles:         %d", num_cycles);
         $display("  CPI x 1000: %d", 1000 * num_cycles / linenum);
         $display("  IPC x 1000: %d", 1000 * linenum / num_cycles);

         $display("  Execution:          %d", num_exec);
         if (num_cache_stall > 0) begin
        $display("  Cache stalls:       %d", num_cache_stall);
         end
         if (num_branch_stall > 0) begin
      $display("  Branch stalls:      %d", num_branch_stall);
         end
         if (num_load_stall > 0) begin
      $display("  Load stalls:        %d", num_load_stall);
         end
      end

      $finish;
   end // initial begin

endmodule
