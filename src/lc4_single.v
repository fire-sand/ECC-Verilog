/*  
 Aasif Versi - versia
 Renyao Wei - renyaow
 Dong Young Kim - kido
 *
 * lc4_single.v
 * Implements a single-cycle data path
 *
 * TODO: Contributions of each group member to this file
 */

`timescale 1ns / 1ps

module lc4_processor(clk, rst, gwe,
                     o_cur_pc, i_cur_insn, o_dmem_addr,
                     i_cur_dmem_data, o_dmem_we, o_dmem_towrite,
                     test_stall, test_cur_pc, test_cur_insn,
                     test_regfile_we, test_regfile_wsel, test_regfile_data,
                     test_nzp_we, test_nzp_new_bits,
                     test_dmem_we, test_dmem_addr, test_dmem_data,
                     switch_data, seven_segment_data, led_data
                     );

   /* DO NOT MODIFY THIS CODE */
   input         clk;                // Main clock
   input         rst;                // Global reset
   input         gwe;                // Global we for single-step clock
   
   output [15:0] o_cur_pc;           // Address to read from instruction memory
   input  [15:0] i_cur_insn;         // Output of instruction memory
   output [15:0] o_dmem_addr;        // Address to read/write from/to data memory; SET TO 0x0000 FOR NON LOAD/STORE INSNS
   input  [15:0] i_cur_dmem_data;    // Output of data memory
   output        o_dmem_we;          // Data memory write enable
   output [15:0] o_dmem_towrite;     // Value to write to data memory
   
   output [1:0]  test_stall;         // Testbench: is this is stall cycle? (don't compare the test values)
   output [15:0] test_cur_pc;        // Testbench: program counter
   output [15:0] test_cur_insn;      // Testbench: instruction bits
   output        test_regfile_we;    // Testbench: register file write enable
   output [2:0]  test_regfile_wsel;  // Testbench: which register to write in the register file 
   output [15:0] test_regfile_data;  // Testbench: value to write into the register file
   output        test_nzp_we;        // Testbench: NZP condition codes write enable
   output [2:0]  test_nzp_new_bits;  // Testbench: value to write to NZP bits
   output        test_dmem_we;       // Testbench: data memory write enable
   output [15:0] test_dmem_addr;     // Testbench: address to read/write memory
   output [15:0] test_dmem_data;     // Testbench: value read/writen from/to memory
   
   input  [7:0]  switch_data;        // Current settings of the Zedboard switches
   output [15:0] seven_segment_data; // Data to display to the Zedboard LCD
   output [7:0]  led_data;           // Which Zedboard LEDs should be turned on?

   // Always execute one instruction each cycle
   assign test_stall = 2'b0; 

   // pc wires attached to the PC register's ports
   wire [15:0]   pc;      // Current program counter (read out from pc_reg)
   wire [15:0]   next_pc; // Next program counter (you compute this and feed it into next_pc)

   // Program counter register, starts at 8200h at bootup
   Nbit_reg #(16, 16'h8200) pc_reg (.in(next_pc), .out(pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   

   /* END DO NOT MODIFY THIS CODE */
   
    /*******************************
    * TODO: INSERT YOUR CODE HERE *
    *******************************/
   //Decoder Module    
   wire [2:0] r1sel;                // rs
   wire       r1re;                 // does this instruction read from rs?
   wire [2:0] r2sel;                // rt
   wire       r2re;                 // does this instruction read from rt?
   wire [2:0] wsel;                 // rd
   wire       regfile_we;           // does this instruction write to rd?
   wire       nzp_we;               // does this instruction write the NZP bits?
   wire       select_pc_plus_one;   // route PC+1 to the ALU instead of rs?
   wire       is_load;              // is this a load instruction?
   wire       is_store;             // is this a store instruction?
   wire       is_branch;            // is this a branch instruction?
   wire       is_control_insn;      // is this a control instruction (JSR, JSRR, RTI, JMPR, JMP, TRAP)?
   lc4_decoder lc4decoder (i_cur_insn, r1sel, r1re, r2sel, r2re, wsel, regfile_we, nzp_we, select_pc_plus_one, is_load, is_store, is_branch, is_control_insn);
   
   //Registers
   wire[15:0] r1data, r2data, wdata;
   //(clk, gwe, rst, r1sel, r1data, r2sel, r2data, wsel, wdata, we);
   lc4_regfile lc4regfile (clk, gwe, rst, r1sel, r1data, r2sel, r2data, wsel, wdata, regfile_we);
   
   //PC_plus_one
   wire[15:0] pc_plus_one;
   assign pc_plus_one = pc + 1;
   
   
   //ALU
   wire[15:0] alu_out;
   //(i_insn, i_pc, i_r1data, i_r2data, o_result)
   lc4_alu lc4alu (i_cur_insn, pc, r1data, r2data, alu_out);
   
   //select_pc_plus_one,  PC+1 into R7 
   wire[15:0] control_mux_out;
   control_mux controlmux (select_pc_plus_one, alu_out, pc_plus_one, control_mux_out);
   
   //Register input Mux
   wire[15:0] reg_input_mux_out;
   //takes in is_load and choses between control_mux_out or memory_out(i_cur_dmem_data)
   //only need to assign wire wdata write enable and select are taken care of by decoder
   //assign wd to ^
   reg_input_mux reginputmux (is_load, control_mux_out, i_cur_dmem_data, reg_input_mux_out);
   assign wdata = reg_input_mux_out;
   
   //NZP Calculator module based on reg_input_mux_out
   wire[2:0] nzp_calc_out;
   nzp_calculator nzpcalculator (reg_input_mux_out, nzp_calc_out);
   
   wire[2:0] nzp_reg_out;
   Nbit_reg #(3) nzp_reg (nzp_calc_out, nzp_reg_out, clk, nzp_we, gwe, rst);
   
   wire[2:0] nzp_out;
   assign nzp_out = (nzp_we == 1'b1) ? nzp_calc_out : nzp_reg_out;
   
   
   //Branch
   //takes in, is_branch, nzp_reg_out and INSN anc compares to set control for branch mux to chose next pc
   wire branch_out;
   branch_logic branchlogic (is_branch, is_control_insn, nzp_out, i_cur_insn, branch_out);
   
   
   //Branch_mux uses branch_out to chose between PC+1 and ALU out.
   //assign output to wire next_pc, already made by previous code
   branch_mux branchmux (branch_out, alu_out, pc_plus_one, next_pc);
   
   
   //Memory input mux takes in control_mux_out and passes output or gives 0x0000 if non load/store
   //takes in is_load, is_store, control_mux_out
   //output memory_input_mux_out
   wire [15:0] memory_addr;
   assign memory_addr = ((is_load | is_store) == 1'b1) ? control_mux_out : 16'b0;
   
   //Memory is an ouptut of this file
   //ADDR input port is output of mumory_input_mux
   // in input port is r2data
   wire [15:0] memory_input;
   assign memory_input = r2data;
   
   //dmem data for testing
   wire[15:0] dmem_data;
   assign dmem_data = is_store ? memory_input : (is_load ? i_cur_dmem_data : 16'b0);
   
   //assign outputs
      assign o_cur_pc = pc;           // Address to read from instruction memory
      assign o_dmem_addr = memory_addr;        // Address to read/write from/to data memory; SET TO 0x0000 FOR NON LOAD/STORE INSNS
      assign o_dmem_we = is_store;          // Data memory write enable
      assign o_dmem_towrite = memory_input;     // Value to write to data memory
      
      assign test_cur_pc = pc;        // Testbench: program counter
      assign test_cur_insn = i_cur_insn;      // Testbench: instruction bits
      assign test_regfile_we = regfile_we;    // Testbench: register file write enable
      assign test_regfile_wsel = wsel;  // Testbench: which register to write in the register file 
      assign test_regfile_data = wdata;  // Testbench: value to write into the register file
      assign test_nzp_we = nzp_we;        // Testbench: NZP condition codes write enable
      assign test_nzp_new_bits = nzp_out;  // Testbench: value to write to NZP bits
      assign test_dmem_we = is_store;       // Testbench: data memory write enable
      assign test_dmem_addr = memory_addr;     // Testbench: address to read/write memory
      assign test_dmem_data = dmem_data;     // Testbench: value read/writen from/to memory
   
   
   // For in-simulator debugging, you can use code such as the code
   // below to display the value of signals at each clock cycle.
   // (Note: You are free to modify this code however you like.)

//`define DEBUG
`ifdef DEBUG
   always @(posedge gwe) begin
      $display("%d %h %b %h", $time, pc, insn, alu_out_pre_mux);
   end
`endif

   // For on-board debugging, the LEDs and segment-segment display can
   // be configured to display useful information.  The below code
   // assigns the four hex digits of the seven-segment display to either
   // the PC or instruction, based on how the switches are set.
   
   assign seven_segment_data = (switch_data[6:0] == 7'd0) ? pc :
                               (switch_data[6:0] == 7'd1) ? i_cur_insn :
                               (switch_data[6:0] == 7'd2) ? o_dmem_addr :
                               (switch_data[6:0] == 7'd3) ? i_cur_dmem_data :
                               (switch_data[6:0] == 7'd4) ? o_dmem_towrite :
                               /*else*/ 16'hDEAD;
   assign led_data = switch_data;
   
endmodule

module control_mux (is_control, alu_out, pc_plus_one, control_out);
    input is_control;
    input [15:0] alu_out, pc_plus_one;
    output [15:0] control_out;
    
    assign control_out = (is_control == 1'b0) ? alu_out : pc_plus_one;
endmodule

module reg_input_mux (is_load, control_mux_out, memory_out, reg_input_mux_out);
    input is_load;
    input[15:0] control_mux_out, memory_out;
    output[15:0] reg_input_mux_out;
    
    assign reg_input_mux_out = (is_load == 1'b0) ? control_mux_out : memory_out;
endmodule

module nzp_calculator (nzp_in, nzp_calculator_out);
    input [15:0] nzp_in;
    output [2:0] nzp_calculator_out;
    
    assign nzp_calculator_out = (nzp_in[15] == 1'b1) ? 3'b100 :
                                (nzp_in == 16'b0) ? 3'b010 :
                                3'b001;                           
endmodule



module branch_logic (is_branch, is_control_insn, nzp_reg_out, insn, branch_out);
    input is_branch;
    input is_control_insn;
    input [2:0] nzp_reg_out;
    input [15:0] insn;
    output branch_out;
    
    wire [2:0] nzp;
    assign nzp = nzp_reg_out & insn[11:9];
    assign branch_out = ((nzp != 3'b0) && is_branch || is_control_insn) ? 1'b1 : 1'b0;

endmodule

module branch_mux (branch_out, alu_mux_out, pc_plus_one, branch_mux_out);
    input branch_out;
    input [15:0] alu_mux_out, pc_plus_one;
    output [15:0] branch_mux_out;
    
    assign branch_mux_out = (branch_out == 1'b0) ? pc_plus_one : alu_mux_out;
endmodule




