//`include "mem.v"
module ifetch(
  input clk,
  input [31:0]ALU,
  input sel,
  input [31:0]NPC_mem,
  output [31:0]NPC,
  output [31:0]IR
);
  reg [31:0] mem [1023:0] ;
  reg [31:0] PC;
  reg [31:0]IR;
  assign NPC = sel?ALU:(PC+1);  
endmodule
/*
Ext mem block not incorporated
*/
