module decode(
  input clk,
  input[31:0] NPC_if,
  input[31:0] IR_if,  
  input [31:0] LMD, //Data writeback
  input [4:0] rd_w, // Data writeback
  output [31:0] A,
  output [31:0] B,
  output [31:0] D,
  output [31:0] Imm,
  output[31:0] NPC_id,
  output[31:0] IR_id,
  output hlt
);
  reg halt = 0;
  reg [31:0] reg_b [31:0];//register bank
  wire [5:0] op;
  wire [4:0] rd,rs1,rs2,sh;
  assign NPC_id = NPC_if;
  assign IR_id = IR_if;
  assign op = IR_if[31:26];
  assign rd = IR_if[25:21];
  assign rs1 = IR_if[20:16];
  assign rs2 = IR_if[15:11];
  assign sh  = IR_if[10:6];
  assign Imm = {{16{IR_if[15]}},IR_if[15:0]};
  assign A = reg_b[rs1];
  assign B = reg_b[rs2]<<sh;
  assign D = reg_b[rd];  
  always@(*)begin
    //reg_b[rd_w] = LMD;
    halt = (op == 6'b111111)?1:0;
    reg_b[0] = 32'b0;//R0 hard wired to 0
  end
  always@(posedge clk )begin
    reg_b[rd_w] <= LMD;
    //halt = (op == 6'b111111)?1:0;
    //reg_b[0] = 32'b0;//R0 hard wired to 0
  end
  assign hlt = halt; 
endmodule
