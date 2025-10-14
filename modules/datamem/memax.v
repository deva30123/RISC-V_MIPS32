// Code your design here
module memax(
  input [31:0] IR_ex, ALU_ex, D_ex,
  output [31:0] IR_mem, LMD, ALU_mem
);
  wire [5:0] opcode;
  reg [31:0] data[1023:0];
  //reg LData;
  assign opcode = IR_ex[31:26];
  always@(*) begin
    data[ALU_ex]=(opcode==6'b110001)?D_ex:data[ALU_ex];
    // if (opcode[5:1]==2'b11000) begin
    //   case(opcode[0])
    //     1'b0:LData=data[ALU_out_ex];    // load
    //     1'b0:data[ALU_out_ex]=D_ex;   //store
    //   endcase
    // end
    
  end
  assign IR_mem = IR_ex;
  assign ALU_mem = ALU_ex;
  assign LMD = data[ALU_ex];
endmodule
