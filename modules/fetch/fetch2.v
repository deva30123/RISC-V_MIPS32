module ifetch(
  input clk,rst,   
  input [31:0]NPC_alu,
  input sel,  
  input [1:0] mode,
  input [31:0] w_addr,
  input [31:0] in_data,
  output [31:0]NPC,
  output [31:0]IR
);
  reg [31:0] mem [1023:0] ;
  reg [31:0] PC = 0;
  reg [31:0]Ir;
  wire clk1 , clk2;
  assign clk1 = clk&(~mode[1]); 
  assign clk2 = clk&mode[1]&(~mode[0]);
  always@(posedge clk1,posedge rst)begin
    if (~rst) begin
      PC = sel?NPC_alu:(PC+1);
      Ir = mem[PC];
    end
    else begin 
      PC = 0;
      Ir = 0;
    end
  end
  always@(posedge clk2)begin    
    mem[w_addr]<=in_data;
  end
  assign IR = Ir;
  assign NPC = PC+1;  
endmodule
/*
mode 00 = normal operation
mode 10 = insrtuction write
*/
