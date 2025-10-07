// Code your design here
/*
memory to store instructions
1K x 32
1 read port,1 write port
*/

module inst_mem (
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
  
  
