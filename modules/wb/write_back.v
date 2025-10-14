module wb(
  input [31:0] IR_mx , ALU ,LMD,
  output [31:0] data, IR_wb
);
  wire[5:0] opcode ;
  assign opcode = IR_mx[31:0]; 
  assign IR_wb = IR_mx;
  assign data = (opcode[5:1]==5'b11000)?LMD:ALU;
endmodule
