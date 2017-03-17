module tc (r1, r2);
  input [7:0] r1;
  output [7:0] r2;
  assign r2 = ~r1 +1;
endmodule
