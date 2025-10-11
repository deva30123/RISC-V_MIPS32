module memax(
  input [31:0] IR_ex, ALU_out_ex, D_ex,
  output [31:0] IR_mem, LMD
);
  wire opcode[5:0];
  reg [31:0] data[1023:0];
  opcode[5:0] = IR_ex[31:26];
  always@(*) begin
    if (opcode[5:1]==2'b11000) begin
      case(opcode[0])
        1'b0:
    end
  end
  
endmodule
