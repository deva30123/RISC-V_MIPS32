/*
memory to store instructions
1K x 32
1 read port,1 write port
*/

module inst_mem (
  input clk,
  input clr,
  input [31:0] data_in,
  input [9:0] addr_w,addr_r,
  output [31:0] data_out,
)
  reg [31:0] mem[1023:0] ,out;
  
  always@(posedge clk) begin
    if (clr==1) mem = {32768{1'b0}};
    else begin
      out <= mem[addr_r];
      mem[addr_w] <= in;
    end
  end
  assign data_out = out;
endmodule
  
  
