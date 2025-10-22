//fetch--------------------------------------------------------------------------------------------------------------------
module ifetch(
  input clk,   
  input [31:0]NPC_alu,
  input sel,
  output [31:0]NPC,
  output [31:0]IR
);
  reg [31:0] mem [1023:0] ;
  reg [31:0] PC;
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
  input[31:0] NPC_if,
  input[31:0] IR_if,  
  input [31:0] LMD, //Data writeback
  input [4:0] rd_w, // Data writeback
  output [31:0] A,
  output [31:0] B,
  output [31:0] D,
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
  assign Imm = {{116{IR_if[15]}},IR_if[15:0]};
  assign A = reg_b[rs1];
  assign B = reg_b[rs2];
  assign D = reg_b[rd];
  always@(*) reg_b[rd_w] = LMD; 
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
  reg cond;
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

//write back-----------------------------------------------------------------------------------------------------------------------------------------------------------
module wb(
  input [31:0] IR_mx , ALU ,LMD,
  output [31:0] data, IR_wb
);
  wire[5:0] opcode ;
  assign opcode = IR_mx[31:0]; 
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
  input clk
);
 
  wire [31:0] NPC_if,IR_if;
  ifetch i_f (
    .clk(clk)
    .NPC_alu(npcx),//from alu
    .sel(sel),//from alu
    
    .NPC(NPC_if),
    .IR(IR_if),
  );
  reg [31:0] NPC_id,IR_id,npcx,sel;
  always@(posedge clk)begin
    NPC_id <= NPC_if;
    IR_id <= IR_if;
  end
  
  wire [31:0] A,B,D,Imm,NPC_id,IR_id,Ds; 
  decode id(
    .NPC_if(NPC_id),
    .IR_if(IR_id),
    .LMD(data),//from writeback
    .rd_w(rd_addr),//from writeback
    
    .A(A),
    .B(B),
    .D(Ds),//to memax
    .Imm(Imm),
    .NPC_id(NPC_id),
    .IR_id(IR_id),
  );
  reg [31:0] Ax,Bx,Ix,NPCx,IRx, data,rd_addr,Dsx;
  always@(posedge clk)begin
    Ax <= A;
    Bx <= B;
    Ix <= Imm;
    NPCx <= NPC_id;
    IRx <= IR_id;
    Dsx <= Ds;
  end  
  
  wire [31:0] Irx, ALUx, Bex,Dsx;  
  exe ex(
    .A(Ax),
    .B(Bx),
    .Imm(Ix),
    .NPC_id(NPCx),
    .IR_id(IRx),    
    
    .IR_ex(Irx),
    .ALU_res(ALUx),
    //.B_ex(Bex),
    .NPC_ex(npcx),//to inst fetch
    .sel(sel)//to inst fetch
  );
  reg [31:0] IrX,AluX,Dsm;
  always@(posedge clk)begin
    IrX<=Irx;
    AluX<=ALUx;
    Dsm <= Dsx;
  end
  
  wire[31:0] IR_mem, LMD, ALU_mem; 
  memax max(
    .IR_ex(IrX), .ALU_ex(AluX), .D_ex(Dsm),
    .IR_mem(IR_mem), .LMD(LMD), .ALU_mem(ALU_mem)
  );
  reg[31:0] IR_mx ,ALUmx ,LMDx;
  always@(posedge clk)begin
    IR_mx<=IR_mem;
    ALUmX<=ALU_mem;
    LMDx<=LMD;
  end  
  wire [31:0] w_data, rdaddr;
  wb w_b(
    .IR_mx(IR_mx) , .ALU(ALUmx) ,.LMD(LMDx),
    .data(w_data), .IR_wb(rdaddr)// to inst decode
  );
  always@(posedge clk)begin
    data<=w_data;
    rd_addr<=rdaddr;    
  end
  
endmodule
