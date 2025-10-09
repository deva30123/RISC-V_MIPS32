module exe(
  input [31:0] A,
  input [31:0] B,
  input [31:0] Imm,
  input[31:0] NPC_id,
  input[31:0] IR_id,
  output [31:0] NPC_ex,
  output[31:0] IR_ex,
  output[31:0] ALU_out,
  output[31:0] B_ex
);
  wire[31:0] a,b;
  wire[5:0] opcode;
  reg cond;
  assign opcode = IR[31:26];
  assign a=(opcode[5:2]==4'b1101)?NPC_id:A;
  assign b=(opcode[4])?Imm:B;
  
  always@(*) begin// Alu block
  end
  assign NPC_ex=(cond?)ALU_out:NPC_id;
endmodule
