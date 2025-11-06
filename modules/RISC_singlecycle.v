// Code your design here
//fetch--------------------------------------------------------------------------------------------------------------------
module ifetch(
  input clk,   
  input [31:0]NPC_alu,
  input sel,
  output [31:0]NPC,
  output [31:0]IR
);
  reg [31:0] mem [1023:0] ;
  reg [31:0] PC = 0;
  reg [31:0]Ir;
  always@(posedge clk)begin
    PC = sel?NPC_alu:(PC+1);
    Ir = mem[PC];
  end
  assign IR = Ir;
  assign NPC = PC+1;  
endmodule
//decode-------------------------------------------------------------------------------------------------------------
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
//excecute--------------------------------------------------------------------------------------------------------------------------------
module exe(
  input [31:0] A,
  input [31:0] B,
  input [31:0] Imm,
  input[31:0] NPC_id,
  input[31:0] IR_id,
  output [31:0] NPC_ex,
  output[31:0] IR_ex,
  output[31:0] ALU_res,
  //output[31:0] B_ex,
  output sel
);
  wire[31:0] a,b;
  reg [31:0] ALU_out;
  wire[5:0] opcode; 
  reg cond = 0;
  assign IR_ex = IR_id;
  assign opcode = IR_id[31:26];
  assign a=(opcode[5:2]==4'b1101)?NPC_id:A;
  assign b=(opcode[4])?Imm:B;
  
  always@(*) begin// Alu block
    if(~opcode[5])begin
      case(opcode[3:0])
        4'd0: ALU_out = a+b;
        4'd1: ALU_out = a-b;
        4'd2: ALU_out = a*b;
        4'd3: ALU_out = a>b?1:0;
        4'd4: ALU_out = a|b;
        4'd5: ALU_out = a&b;
      endcase
    end            // Arithmetic and logic operations
    else begin
      ALU_out = a+b; //ld, st, branch all use npc+imm
    end           //controls
  end
  always@(*) begin
    if(opcode[5:1]==5'b11010)begin
      cond = opcode[0]^((A==0)?1:0); //  branch
    end
    else cond = 0;
  end
  assign NPC_ex = (cond)?ALU_out:NPC_id; //redundant
  assign ALU_res = ALU_out;
  assign sel = cond;
endmodule
/*
Arithmetic and logic operations {opcode[5] == 0}
opcode[4] == 0 => RR addressing
opcode[4] == 0 => RImm addressing
Branch
BEQZ=>110100; BnEQZ=>110101
beqz:- if(A=0)cond = 1 else cond = 0
beqz:- if(A=0)cond = 0 else cond = 1
*/
//memory access-----------------------------------------------------------------------------------------------------------------------------------
module memax(
  input clk,
  input [31:0] IR_ex, ALU_ex, D_ex,
  output [31:0] IR_mem, LMD, ALU_mem
);
  wire [5:0] opcode;
  reg [31:0] data[1023:0];
  //reg LData;
  assign opcode = IR_ex[31:26];
  always@(posedge clk) begin
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
//write back-----------------------------------------------------------------------------------------------------------------------------------------------------------
module wb(
  input [31:0] IR_mx , ALU ,LMD,
  output [31:0] data, IR_wb
);
  wire[5:0] opcode ;
  assign opcode = IR_mx[31:26]; 
  assign IR_wb = IR_mx;
  assign data = (opcode[5:1]==5'b11000)?LMD:ALU;
endmodule
// RISC-V module-------------------------------------------------------------------------------------------------------------------------------------------------------
/*
will have 2 modes
1. code:- will write instructions into the inst mem 
2 excecute:- will excecute the instructions in the inst bank in repeat until halted
*/

module mips32(
  input clk_x
);
  wire clk,hlt;
  wire [31:0] NPC_if,IR_if;
  assign clk = clk_x&(~hlt) ; // clock gating when halted
  reg [31:0] npcx;
  reg sel;
  
  ifetch i_f (
    .clk(clk),
    .NPC_alu(npcx),//from alu
    .sel(sel),//from alu
    
    .NPC(NPC_if),
    .IR(IR_if)
  );  
 
  
  wire [31:0] A,B,D,Imm,NPC_id,IR_id,Ds;
  wire [31:0] data;
  wire [4:0] rd_addr;
  
  decode id(
    .clk(clk),
    .NPC_if(NPC_if),
    .IR_if(IR_if),
    .LMD(data),//from writeback
    .rd_w(rd_addr),//from writeback
    
    .A(A),
    .B(B),
    .D(Ds),//to memax
    .Imm(Imm),
    .NPC_id(NPC_id),
    .IR_id(IR_id),
    .hlt(hlt)
  );
  
  wire [31:0] Irx, ALUx, Bex; 
  
  exe ex(
    .A(A),
    .B(B),
    .Imm(Imm),
    .NPC_id(NPC_id),
    .IR_id(IR_id),    
    
    .IR_ex(Irx),
    .ALU_res(ALUx),
    //.B_ex(Bex),
    .NPC_ex(npcx),//to inst fetch
    .sel(sel)//to inst fetch
  );
  
  wire[31:0] IR_mem, LMD, ALU_mem; 
  
  memax max(
    .clk(clk),
    .IR_ex(Irx), .ALU_ex(ALUx), .D_ex(Ds),
    .IR_mem(IR_mem), .LMD(LMD), .ALU_mem(ALU_mem)
  );
   
  wire [31:0]ir_wb;
  wb w_b(
   
    .IR_mx(IR_mem) , .ALU(ALU_mem) ,.LMD(LMD),
    .data(data), .IR_wb(ir_wb)// to inst decode
  );
  assign rd_addr = ir_wb[25:21];
  
endmodule
