//fetch--------------------------------------------------------------------------------------------------------------------
module ifetch(
  input clk,rst,   
  input [31:0]NPC_alu,
  input sel,
  output [31:0]NPC,
  output [31:0]IR
);
  reg [31:0] mem [1023:0] ;
  reg [31:0] PC = 0;
  reg [31:0]Ir;
  always@(posedge clk,posedge rst)begin
    if (~rst) begin
      PC = sel?NPC_alu:(PC+1);
      Ir = mem[PC];
    end
    else begin 
      PC = 0;
      Ir = 0;
    end
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
  output[31:0] IR_id,
  output hlt
);
  reg halt = 0;
  reg [31:0] reg_b [31:0];//register bank
  wire [5:0] op;
  wire [4:0] rd,rs1,rs2;
  assign NPC_id = NPC_if;
  assign IR_id = IR_if;
  assign op = IR_if[31:26];
  assign rd = IR_if[25:21];
  assign rs1 = IR_if[20:16];
  assign rs2 = IR_if[15:11];
  assign Imm = {{16{IR_if[15]}},IR_if[15:0]};
  assign A = reg_b[rs1];
  assign B = reg_b[rs2];
  assign D = reg_b[rd];  
  always@(*)begin
    reg_b[rd_w] = LMD;
    halt = (op == 6'b111111)?1:0;
    reg_b[0] = 32'b0;//R0 hard wired to 0
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
  assign a=A;
  assign b=(opcode[4])?Imm:B;
  
  always@(*) begin// Alu block
    if(~opcode[5])begin
      case(opcode[3:0])
        4'd0: ALU_out = a+b;
        4'd1: ALU_out = a-b;
        4'd2: ALU_out = a^b;
        4'd3: ALU_out = a&b;
        4'd4: ALU_out = a|b;
        4'd5: ALU_out = a>b?1:0;
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
 // assign NPC_ex = (cond)?ALU_out:NPC_id; //redundant
  assign NPC_ex = NPC_id + Imm ;
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
  assign opcode = IR_mx[31:26]; 
  assign IR_wb = IR_mx;
  assign data = (opcode[5:1]==5'b11000)?LMD:ALU;
endmodule
// RISC-V module-------------------------------------------------------------------------------------------------------------------------------------------------------
module mips32(
  input clk_x,rst
);
  wire clk,clk1,clk2,clk3,hlt;
  wire [31:0] NPC_if,IR_if;//fetch output
  reg [31:0] NPC_Id,IR_Id;//fetch to decode
  wire [31:0] A,B,D,Imm,NPC_id,IR_id,Ds,w_data;//decode output
  wire [4:0] rd_addr;//from writeback
  reg [31:0] Ax,Bx,Ix,NPCx,IRx, Dsx,hltidex;//decode to excecute
  wire [31:0] irx, alux, Bex;//excecute output 
  reg [31:0] IrX,AluX,Dsm,hltxmx;//excecute to memory access
  wire[31:0] IR_mem, LMD, ALU_mem;//memory access output 
  reg[31:0] IR_mx ,ALUmx ,LMDx,hltmxwb;//memory access to writeback
  wire [31:0]  IR_wb;//wwriteback output
  
  
  reg [31:0] npcx;
  reg sel;
  
  ifetch i_f (
    .clk(clk),.rst(rst),
    .NPC_alu(ld_hzd?(NPC_id-1):npcx),//from alu
    .sel(sel|ld_hzd),//from alu
    
    .NPC(NPC_if),
    .IR(IR_if)
  );
  
  
  assign clk = clk_x&~hlt; // clock gating when halted
  always@(negedge clk or posedge rst)begin 
    if (rst) begin
      NPC_Id <= 0;
      IR_Id <= 0;
    end
    else begin
      NPC_Id <= NPC_if;
      IR_Id <= IR_if;
    end
  end
  
  
  
  decode id(
    .NPC_if(NPC_Id),
    .IR_if(IR_Id),
    .LMD(w_data),//from writeback
    .rd_w(rd_addr),//from writeback
    
    .A(A),
    .B(B),
    .D(Ds),//to memax
    .Imm(Imm),
    .NPC_id(NPC_id),
    .IR_id(IR_id),
    .hlt(hlt)
  );
  
  reg ld_hzd = 1'b0;
  always@(*)begin //load hazard detection
    if(((IRx[25:21]==IR_Id[20:16])|(IRx[25:21]==IR_Id[15:11]))&(IRx[31:26]==6'b110000))begin
      ld_hzd = 1'b1;      
    end
    else begin
      ld_hzd = 1'b0;     
    end
  end
  
 
  assign clk1 = clk_x&~hltidex;
  always@(negedge clk1 or posedge rst)begin
    if (rst|ld_hzd|sel)begin//sends nop when ld hazard detected
      Ax <= 0;
      Bx <= 0;
      Ix <= 0;
      NPCx <= 0;
      IRx <= 0;
      Dsx <= 0;
    end
    else begin
      if(IRx[25:21]==IR_Id[20:16]) Ax<=alux; //forwarding logic 
      else if(IR_mem[25:21]==IR_Id[20:16]) 
        Ax<=(IR_mem[31:26]==6'b110000)?LMD:ALU_mem; //forwarding logic 
      else Ax <= A;
      if(IRx[25:21]==IR_Id[15:11]) Bx<=alux; //forwarding logic
      else if(IR_mem[25:21]==IR_Id[15:11]) 
        Bx<=(IR_mem[31:26]==6'b110000)?LMD:ALU_mem; //forwarding logic          
      else Bx <= B;
      Ix <= Imm;
      NPCx <= NPC_id;
      IRx <= IR_id;
      if(IRx[25:21]==IR_Id[25:21]) Dsx<=alux; //forwarding logic 
      else if(IR_mem[25:21]==IR_Id[25:21]) Dsx<=ALU_mem; //forwarding logic 
      else Dsx <= Ds;
    end
    hltidex <= hlt; 
  end  
  
 
  
  exe ex(
    .A(Ax),
    .B(Bx),
    .Imm(Ix),
    .NPC_id(NPCx),
    .IR_id(IRx),    
    
    .IR_ex(irx),
    .ALU_res(alux),
    //.B_ex(Bex),
    .NPC_ex(npcx),//to inst fetch
    .sel(sel)//to inst fetch
  );
  
  assign clk2 = clk_x&~hltxmx;
  always@(negedge clk2 or posedge rst)begin
    if(rst) begin
      IrX<= 0;
      AluX<= 0;
      Dsm <= 0;
    end
    else begin 
      IrX<=irx;
      AluX<=alux;
      Dsm <= Dsx;
    end 
    hltxmx <= hltidex;
  end
  
  
  
  memax max(
    .IR_ex(IrX), .ALU_ex(AluX), .D_ex(Dsm),
    .IR_mem(IR_mem), .LMD(LMD), .ALU_mem(ALU_mem)
  );
  
  assign clk3 = clk_x&~hltmxwb;
  always@(negedge clk3 or posedge rst)begin
    if(rst) begin
      IR_mx<=0;
      ALUmx<=0;
      LMDx<=0;
    end
    else begin
      IR_mx<=IR_mem;
      ALUmx<=ALU_mem;
      LMDx<=LMD;
    end
    hltmxwb <= hltxmx;
  end 
  
  
  wb w_b(
    .IR_mx(IR_mx) , .ALU(ALUmx) ,.LMD(LMDx),
    .data(w_data), .IR_wb(IR_wb)// to inst decode
  );  
  assign rd_addr = IR_wb[25:21];  

  
endmodule
