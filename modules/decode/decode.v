module decode(
  input[31:0] NPC_if,
  input[31:0] IR_if,  
  input [31:0] LMD,
  output [31:0] A,
  output [31:0] B,
  output [31:0] Imm,
  output[31:0] NPC_id,
  output[31:0] IR_id
);
  reg [31:0] reg_b [31:0];//register bank
  wire [4:0] op,rd,rs1,rs2;
  assign NPC_id = NPC_if;
  assign IR_id = IR_if;
  assign op = IR_if[31:26];
  assign rd = IR_if[25:21];
  assign rs1 = IR_if[20:16];
  assign rs2 = IR_if[15:11];
  assign imm = {{15{IR_if[15]}},IR_if[15:0]};
  assign A = reg_b[rs1];
  assign B = reg_b[rs2];
  always@(*) reg_b[rd] = LMD; 
endmodule
