//`include "mem.v"
module ifetch(
  input clk,   
  input [31:0]NPC_alu,
  output [31:0]NPC,
  output [31:0]IR
);
  reg [31:0] mem [1023:0] ;
  reg [31:0] PC;
  reg [31:0]Ir;
  always@(posedge clk)begin
    PC = NPC_alu;
    Ir = mem[PC];
  end
  assign IR = Ir;
  assign NPC = PC+1;  
endmodule
/*
Ext mem block not incorporated
*/
