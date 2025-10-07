`include "mem.v"
module ifetch(
  input clk,
  input ALU,
  input sel,
  output NPC,
  output IR
);
  reg [9:0] PC;
  reg [31:0]IR;
  assign NPC = sel?ALU:(PC+1);
  mem inst(.clk(clk), 
           .addr_w(),
           .data_in(),
           .addr_r(PC),          
           .data_out(IR)
          ); 
endmodule
/*leave unconnected ports unconnected*/
