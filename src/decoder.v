`timescale 1ns / 1ps

module lc4_decoder(insn,
                   r1sel,
                   r1re,
                   r2sel,
                   r2re,
                   wsel,
                   regfile_we,
                   nzp_we,
                   select_pc_plus_one,
                   is_load,
                   is_store,
                   is_branch,
                   is_control_insn);
   
   input [15:0] insn;                 // instruction
   output [2:0] r1sel;                // rs
   output       r1re;                 // does this instruction read from rs?
   output [2:0] r2sel;                // rt
   output       r2re;                 // does this instruction read from rt?
   output [2:0] wsel;                 // rd
   output       regfile_we;           // does this instruction write to rd?
   output       nzp_we;               // does this instruction write the NZP bits?
   output       select_pc_plus_one;   // route PC+1 to the ALU instead of rs?
   output       is_load;              // is this a load instruction?
   output       is_store;             // is this a store instruction?
   output       is_branch;            // is this a branch instruction?
   output       is_control_insn;      // is this a control instruction (JSR, JSRR, RTI, JMPR, JMP, TRAP)?
   
   
   // Instruction decoder
   wire [3:0]   opcode = insn[15:12];
   assign       is_branch = (opcode == 4'b0000 & insn != 0);

   wire         is_arith = (opcode == 4'b0001);
   wire         is_add = (is_arith & (insn[5:3] == 3'b000));
   wire         is_mul = (is_arith & (insn[5:3] == 3'b001));
   wire         is_sub = (is_arith & (insn[5:3] == 3'b010));
   wire         is_div = (is_arith & (insn[5:3] == 3'b011));
   wire         is_addi = (is_arith & insn[5]);

   wire         is_compare = (opcode == 4'b0010);
   wire         is_cmp = (is_compare & (insn[8:7] == 2'b00));
   wire         is_cmpu = (is_compare & (insn[8:7] == 2'b01));
   wire         is_cmpi = (is_compare & (insn[8:7] == 2'b10));
   wire         is_cmpiu = (is_compare & (insn[8:7] == 2'b11));

   wire         is_jsr = (insn[15:11] == 5'b01001);
   wire         is_jsrr = (insn[15:11] == 5'b01000);

   wire         is_logic = (opcode == 4'b0101);
   wire         is_and = (is_logic & (insn[5:3] == 3'b000));
   wire         is_not = (is_logic & (insn[5:3] == 3'b001));
   wire         is_or = (is_logic & (insn[5:3] == 3'b010));
   wire         is_xor = (is_logic & (insn[5:3] == 3'b011));
   wire         is_andi = (is_logic & insn[5]);
   

   wire         is_ldr = (opcode == 4'b0110);
   wire         is_str = (opcode == 4'b0111);
   wire         is_rti = (opcode == 4'b1000);
   wire         is_const = (opcode == 4'b1001);

   wire         is_shift = (opcode == 4'b1010);
   wire         is_sll = (is_shift & (insn[5:4] == 2'b00));
   wire         is_sra = (is_shift & (insn[5:4] == 2'b01));
   wire         is_srl = (is_shift & (insn[5:4] == 2'b10));
   wire         is_mod = (is_shift & (insn[5:4] == 2'b11));

   
   wire         is_jmpr = (insn[15:11] == 5'b11000);
   wire         is_jmp = (insn[15:11] == 5'b11001);
   wire         is_hiconst = (opcode == 4'b1101);
   wire         is_trap = (opcode == 4'b1111);
   

   // Register file
   assign r1sel = (is_compare | is_hiconst) ? insn[11:9] :  /*rs*/
                  (is_rti) ? 3'd7 : insn[8:6];
   assign r1re = is_arith | 
                 is_compare | 
                 is_jsrr | 
                 is_logic | 
                 is_ldr | 
                 is_str | 
                 is_rti | 
                 is_shift | 
                 is_jmpr |
                 is_hiconst
                 ;
   
   
   assign r2sel = (is_str) ? insn[11:9] : insn[2:0]; /*rt*/
      
   assign r2re = is_add | is_mul |  is_sub | is_div |
                 is_cmp | is_cmpu |
                 is_and | is_or | is_xor |
                 is_str |
                 is_mod;
   
   assign wsel = (is_jsr | is_jsrr | is_trap) ? 3'd7 : insn[11:9];  /*rd*/

   assign regfile_we = is_arith | is_jsr | is_jsrr | is_logic | is_ldr | is_const | is_shift | is_hiconst | is_trap;
   assign nzp_we = regfile_we | is_compare;
   assign select_pc_plus_one = is_trap | is_jsrr | is_jsr;
   assign is_load = is_ldr;
   assign is_store = is_str;
   assign is_control_insn =  is_jsr | is_jsrr | is_rti | is_jmpr | is_jmp | is_trap;

endmodule
