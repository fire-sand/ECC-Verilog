`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:58:29 01/17/2014 
// Design Name: 
// Module Name:    fake_pb_kbd 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module fake_pb_kbd(
			read_kbsr,
			kbsr,
			read_kbdr,
			kbdr,
			proc_clk,
			reset,
			ZED_PB
    );
		
		input read_kbsr;
		output kbsr;
		input read_kbdr;
		output [7:0] kbdr;
		input proc_clk;
		input reset;
		
		// In order, 4: up, 3: left, 2: down, 1: right, 0: center
		input [4:0] ZED_PB;
		// One-pulsed and reg'ed version of the push button input
		wire [4:0] zed_pb_op;
		
		onepulse_fsm op_u(.I(ZED_PB[4]), .O(zed_pb_op[4]), .clk(proc_clk),
								.reset(reset));
		onepulse_fsm op_l(.I(ZED_PB[3]), .O(zed_pb_op[3]), .clk(proc_clk),
								.reset(reset));
		onepulse_fsm op_d(.I(ZED_PB[2]), .O(zed_pb_op[2]), .clk(proc_clk),
								.reset(reset));
		onepulse_fsm op_r(.I(ZED_PB[1]), .O(zed_pb_op[1]), .clk(proc_clk),
								.reset(reset));
		onepulse_fsm op_c(.I(ZED_PB[0]), .O(zed_pb_op[0]), .clk(proc_clk),
								.reset(reset));
		
		// Set the Keyboard status register whenever a key is released,
		// and clear it only when KBDR is read.
		wire key_pressed = zed_pb_op[4] | zed_pb_op[3] | zed_pb_op[2] |
									zed_pb_op[1] | zed_pb_op[0];
		
		wire kbsr_in;
		assign kbsr_in = read_kbdr ? 1'b0 : key_pressed | kbsr;
		Nbit_reg #(1,0) kbsr_reg(.in(kbsr_in), .out(kbsr), .clk(proc_clk),
										.we(1'b1), .gwe(1'b1), .rst(reset));
										
		// Store the most recently released key in the KBDR.
		// The buttons are translated as follows:
		//
		wire [7:0] kbdr_in, kbdr;
		assign kbdr_in = (key_pressed == 1'b0) ? kbdr :
							  (zed_pb_op[4]) ? 8'h69 : // ASCII 'i'
							  (zed_pb_op[3]) ? 8'h6A : // ASCII 'j'
							  (zed_pb_op[2]) ? 8'h6B : // ASCII 'k'
							  (zed_pb_op[1]) ? 8'h6C : // ASCII 'l'
							  (zed_pb_op[0]) ? 8'h20 : // ASCII space
							  8'h00;
		
		Nbit_reg #(8,0) kbdr_reg(.in(kbdr_in), .out(kbdr), .clk(proc_clk),
										.we(1'b1), .gwe(1'b1), .rst(reset));
		

endmodule

module onepulse_fsm(
				I,
				O,
				clk,
				reset
			);
			
			input I;
			output O;
			input clk;
			input reset;
			
			wire [2:0] state, next_state;
			Nbit_reg #(2,0) state_reg(.in(next_state), .out(state),
											  .clk(clk), .we(1'b1),
											  .gwe(1'b1), .rst(reset));
											
			assign next_state = (state == 2'b00 && I == 1'b1) ? 2'b01 :
										(state == 2'b01) ? 2'b10 :
										(state == 2'b10 && I == 1'b0) ? 2'b00 :
										2'b00;
										
			assign O = (state == 2'b10 && I == 1'b0) ? 1'b1 : 1'b0;
			
endmodule
