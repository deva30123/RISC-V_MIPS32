`timescale 1ns/1ps
module tb_decode();

  // Testbench signals
  reg  [31:0] NPC_if;
  reg  [31:0] IR_if;
  reg  [31:0] LMD;
  reg  [4:0]  rd_w;
  wire [31:0] A;
  wire [31:0] B;
  wire [31:0] D;
  wire [31:0] Imm;
  wire [31:0] NPC_id;
  wire [31:0] IR_id;
  wire hlt;

  // DUT instantiation
  decode uut (
    .NPC_if(NPC_if),
    .IR_if(IR_if),
    .LMD(LMD),
    .rd_w(rd_w),
    .A(A),
    .B(B),
    .D(D),
    .Imm(Imm),
    .NPC_id(NPC_id),
    .IR_id(IR_id),
    .hlt(hlt)
  );

  // Test stimulus
  initial begin
    $dumpfile("decode_tb.vcd");
    $dumpvars(0, tb_decode);

    // Initialize inputs
    NPC_if = 0;
    IR_if  = 0;
    LMD    = 0;
    rd_w   = 0;
    #10;
    
    // Test Case 0 filling up the reg bank
    for(int i=0;i<32;i++)begin
      uut.reg_b[i] = $random;      
      $display("T=%0t | R%d = 0x%h ",$time, i, uut.reg_b[i]); 
    end


    // Test case 1: simple instruction load
    NPC_if = 32'h00000004;
    IR_if  = 32'h20100005; // example instruction
    LMD    = 32'hAAAAAAAA;
    rd_w   = 5'd2;
    #10$display("T=%0t | NPC_if=0x%h IR_if=0x%h LMD=0x%h | A=0x%h B=0x%h D=0x%h Imm=0x%h NPC_id=0x%h IR_id=0x%h halt = %b",
             $time, NPC_if, IR_if, LMD, A, B, D, Imm, NPC_id, IR_id, hlt); 
    #10;

    // Test case 2: another instruction
    NPC_if = 32'h00000008;
    IR_if  = 32'h8C120004; // lw $18,4($0)
    LMD    = 32'h12345678;
    rd_w   = 5'd18;
    #10$display("T=%0t | NPC_if=0x%h IR_if=0x%h LMD=0x%h | A=0x%h B=0x%h D=0x%h Imm=0x%h NPC_id=0x%h IR_id=0x%h halt = %b",
             $time, NPC_if, IR_if, LMD, A, B, D, Imm, NPC_id, IR_id, hlt); 
    #10;

    // Test case 3: halt simulation
    NPC_if = 32'h0000000C;
    IR_if  = 32'hFFFFFFFF; // maybe halt instruction pattern
    LMD    = 32'h00000000;
    rd_w   = 5'd0;
    #10$display("T=%0t | NPC_if=0x%h IR_if=0x%h LMD=0x%h | A=0x%h B=0x%h D=0x%h Imm=0x%h NPC_id=0x%h IR_id=0x%h halt = %b",
             $time, NPC_if, IR_if, LMD, A, B, D, Imm, NPC_id, IR_id, hlt); 
    #10;
    
    for(int i=0;i<32;i++)begin            
      $display("T=%0t | R%d = 0x%h ",$time, i, uut.reg_b[i]); 
    end

    $display("Testbench finished at time %t", $time);
    #10 $finish;
  end

endmodule
