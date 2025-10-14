// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module memax_tb;

  // -------------------
  // Testbench signals
  // -------------------
  reg  [31:0] IR_ex;
  reg  [31:0] ALU_ex;
  reg  [31:0] D_ex;

  wire [31:0] IR_mem;
  wire [31:0] LMD;
  wire [31:0] ALU_mem;

  // -------------------
  // DUT instantiation
  // -------------------
  memax uut (
    .IR_ex(IR_ex),
    .ALU_ex(ALU_ex),
    .D_ex(D_ex),
    .IR_mem(IR_mem),
    .LMD(LMD),
    .ALU_mem(ALU_mem)
  );

  // -------------------
  // Test sequence
  // -------------------
  initial begin
    $display("------ Starting memax Testbench ------");

    // Initialize all inputs
    IR_ex  = 32'b0;
    ALU_ex = 32'b0;
    D_ex   = 32'b0;
    
    //populate the memory bank
    for(int i=0;i<1024;i++)begin
      uut.data[i] = $random;      
      //$display("T=%0t | R%d = 0x%h ",$time, i, uut.reg_b[i]); 
    end
    // Wait for some cycles
    #10;

    // Wait some time before starting
    #10;

    // Test 1: Simple values
    IR_ex  = 32'h00000011;
    ALU_ex = 32'h00000022;
    D_ex   = 32'h00000033;
    #10;
    $display("T=%0t | IR_ex=%h ALU_ex=%h D_ex=%h | IR_mem=%h LMD=%h ALU_mem=%h",
              $time, IR_ex, ALU_ex, D_ex, IR_mem, LMD, ALU_mem);

    // Test 2: Randomized values
    repeat (1) begin
      #10;
      IR_ex  = $urandom;
      ALU_ex = $urandom;
      D_ex   = $urandom;
      #1;
      $display("T=%0t | IR_ex=%h ALU_ex=%h D_ex=%h | IR_mem=%h LMD=%h ALU_mem=%h",
                $time, IR_ex, ALU_ex, D_ex, IR_mem, LMD, ALU_mem);
    end

    // Test 3: load
    #10;
    IR_ex  = 32'hc0000000;
    ALU_ex = 32'h00000fe4;
    D_ex   = 32'hAA12efAA;
    #10;
    $display("T=%0t | IR_ex=%h ALU_ex=%h D_ex=%h | IR_mem=%h LMD=%h ALU_mem=%h",
              $time, IR_ex, ALU_ex, D_ex, IR_mem, LMD, ALU_mem);
    // Test 4: store
    #10;
    IR_ex  = 32'hc4000000;
    ALU_ex = 32'h000000f3;
    D_ex   = 32'hAA98bfeA;
    #10;
    $display("T=%0t | IR_ex=%h ALU_ex=%h D_ex=%h | IR_mem=%h LMD=%h ALU_mem=%h",
              $time, IR_ex, ALU_ex, D_ex, IR_mem, LMD, ALU_mem);

    // End simulation
    #10;
    $display("------ Testbench Completed ------");
    $finish;
  end

  // -------------------
  // Waveform dump
  // -------------------
  initial begin
    $dumpfile("memax_tb.vcd");
    $dumpvars(0, memax_tb);
  end

endmodule
