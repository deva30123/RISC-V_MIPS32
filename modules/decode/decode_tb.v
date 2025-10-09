`timescale 1ns / 1ps

module tb_decode();

  // Declare inputs as regs
  reg [31:0] NPC_if;
  reg [31:0] IR_if;
  reg [31:0] ALU_out;

  // Declare outputs as wires
  wire [31:0] A;
  wire [31:0] B;
  wire [31:0] Imm;
  wire [31:0] NPC_id;
  wire [31:0] IR_id;

  // Instantiate the module under test (UUT)
  decode uut (
    .NPC_if(NPC_if),
    .IR_if(IR_if),
    .ALU_out(ALU_out),
    .A(A),
    .B(B),
    .Imm(Imm),
    .NPC_id(NPC_id),
    .IR_id(IR_id)
  );

  // Stimulus generation
  initial begin
    $display("\n--- Starting Decode Module Test ---\n");

    // Initialize inputs
    NPC_if = 0;
    IR_if  = 0;
    ALU_out = 0;

    // Wait for signals to settle
    #10;
    // Test Case 0 filling up the reg bank
    for(int i=0;i<32;i++)begin
      uut.reg_b[i] = $random;      
      $display("T=%0t | R%d = 0x%h ",$time, i, uut.reg_b[i]); 
    end

    // Test Case 1
    NPC_if = 32'h0000_0004;
    IR_if  = 32'h1234_5678;
    ALU_out = 32'hAAAA_BBBB;
    #10;
     $display("T=%0t | NPC_if=0x%h IR_if=0x%h ALU_out=0x%h | A=0x%h B=0x%h Imm=0x%h NPC_id=0x%h IR_id=0x%h",
             $time, NPC_if, IR_if, ALU_out, A, B, Imm, NPC_id, IR_id);    
   
    // Test Case 2
    NPC_if = 32'h0000_0008;
    IR_if  = 32'hDEAD_BEEF;
    ALU_out = 32'h1111_2222;
    #10;
    $display("T=%0t | NPC_if=0x%h IR_if=0x%h ALU_out=0x%h | A=0x%h B=0x%h Imm=0x%h NPC_id=0x%h IR_id=0x%h",
             $time, NPC_if, IR_if, ALU_out, A, B, Imm, NPC_id, IR_id);

    // Test Case 3
    NPC_if = 32'h0000_000C;
    IR_if  = 32'h00FF_00FF;
    ALU_out = 32'hFFFF_0000;
    #10;
    $display("T=%0t | NPC_if=0x%h IR_if=0x%h ALU_out=0x%h | A=0x%h B=0x%h Imm=0x%h NPC_id=0x%h IR_id=0x%h",
             $time, NPC_if, IR_if, ALU_out, A, B, Imm, NPC_id, IR_id);
     // Test Case 4 checks if rd write is working properly
    NPC_if = 32'h0000_0010;
    IR_if  = 32'h0021_0800;
    ALU_out = 32'hAAAA_BBBB;
    #10;
     $display("T=%0t | NPC_if=0x%h IR_if=0x%h ALU_out=0x%h | A=0x%h B=0x%h Imm=0x%h NPC_id=0x%h IR_id=0x%h",
             $time, NPC_if, IR_if, ALU_out, A, B, Imm, NPC_id, IR_id); 

    // End of simulation
    #10;
    $display("\n--- Decode Module Test Completed ---\n");
    $finish;
  end

endmodule
