module mem (
  input clk,  
  input [31:0] data_in,
  input [9:0] addr_w,addr_r,
  output [31:0] data_out
);
  reg [31:0] mem [1023:0] ;
  reg [31:0] out;
  
  always@(posedge clk) begin
    
      out <= mem[addr_r];
      mem[addr_w] <= data_in;
    
  end
  assign data_out = out;
endmodule
//fetch....................................................................................................................................................................................
module ifetch(
  input clk,   
  input [31:0]NPC_alu,
  input sel,
  output [31:0]NPC,
  output [31:0]IR
);
  reg [31:0] mem [1023:0] ;
  reg [31:0] PC;
  reg [31:0]Ir;
  mem tnstmem(
    .clk(clk),  
  .data_in,
    .addr_w(),
    .addr_r(),
  .data_out);
  always@(posedge clk)begin
    PC = sel?NPC_alu:(PC+1);
    Ir = mem[PC];
  end
  assign IR = Ir;
  assign NPC = PC+1;  
endmodule
