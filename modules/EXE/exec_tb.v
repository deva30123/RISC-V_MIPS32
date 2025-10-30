// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module exe_tb();

  // Inputs
  reg [31:0] A;
  reg [31:0] B;
  reg [31:0] Imm;
  reg [31:0] NPC_id;
  reg [31:0] IR_id;

  // Outputs
  wire [31:0] NPC_ex;
  wire [31:0] IR_ex;
  wire [31:0] ALU_out;
  //wire [31:0] B_ex;

  // Instantiate the Unit Under Test (UUT)
  exe uut (
    .A(A),
    .B(B),
    .Imm(Imm),
    .NPC_id(NPC_id),
    .IR_id(IR_id),
    .NPC_ex(NPC_ex),
    .IR_ex(IR_ex),
    .ALU_res(ALU_out)
    //.B_ex(B_ex)
  );

  // Test stimulus
  initial begin
    $dumpfile("exe.vcd");
    $dumpvars(0, exe_tb);
    // Monitor signal changes
    $monitor("Time=%0t | A=%h | B=%h |cond = %b | ALU_out=%h", 
              $time, uut.a, uut.b, uut.cond, ALU_out);

    // Initialize inputs
    A = 0; B = 0; Imm = 0; NPC_id = 0; IR_id = 0;
    #10;

    // Test case 1: ALU operation
    NPC_id = 32'h0000_0100;
    A = 32'h0000_0005;
    B = 32'h0000_0003;
    Imm = 32'h0000_0002;
    
    #10 IR_id = 32'h00000000;
    #10 IR_id = 32'h04000000;
    #10 IR_id = 32'h08000000;
    #10 IR_id = 32'h0c000000;
    #10 IR_id = 32'h10000000;
    #10 IR_id = 32'h14000000;//rr operation 
    
    #10 IR_id = 32'h40000000;
    #10 IR_id = 32'h44000000;
    #10 IR_id = 32'h48000000;
    #10 IR_id = 32'h4c000000;
    #10 IR_id = 32'h50000000;
    #10 IR_id = 32'h54000000;//ri operation
    
    #10 IR_id = 32'hc0000000;
    #10 IR_id = 32'hc4000000;//load|store
    
    #10 IR_id = 32'hd0000000;
    #10 IR_id = 32'hd4000000;//branch (A!=0)
    
    #10 A = 32'h0000_0000;
    #10 IR_id = 32'hd0000000;
    #10 IR_id = 32'hd4000000;//branch (A==0)


    

    // End simulation
    #10
    $finish;
  end

endmodule
