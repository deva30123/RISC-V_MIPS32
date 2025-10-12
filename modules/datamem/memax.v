module memax(
  input [31:0] IR_ex, ALU_out_ex, D_ex,
  output [31:0] IR_mem, LMD, ALU_out_mem
);
  wire opcode[5:0];
  reg [31:0] data[1023:0];
  //reg LData;
  opcode[5:0] = IR_ex[31:26];
  always@(*) begin
    data[ALU_out_ex]=(opcode==6'b110001)?D_ex:data[ALU_out_ex];
    // if (opcode[5:1]==2'b11000) begin
    //   case(opcode[0])
    //     1'b0:LData=data[ALU_out_ex];    // load
    //     1'b0:data[ALU_out_ex]=D_ex;   //store
    //   endcase
    // end
    
  end
  assign IR_ex = IR_mem;
  assign ALU_out_ex = ALU_out_mem;
  assign LMD = data[ALU_out];
endmodule
