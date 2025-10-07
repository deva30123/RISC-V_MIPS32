`include "mem.v"
module ifetch(
  input clk,
  input ALU,
  input sel,
  output NPC,
  output IR
);
  assign NPC = sel?ALU:(PC+1);
  mem inst(.clk(clk),
           .addr_r(PC),
           .data_out(IR)
          );
  reg [9:0] PC;
  reg [31:0]IR;
  
  
endmodule
