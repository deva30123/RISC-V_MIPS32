`timescale 1ns/1ps

module wb_tb;

  // -------------------
  // Testbench signals
  // -------------------
  reg  [31:0] IR_mx;
  reg  [31:0] ALU;
  reg  [31:0] LMD;
  wire [31:0] data;
  wire [31:0] IR_wb;

  // -------------------
  // DUT instantiation
  // -------------------
  wb uut (
    .IR_mx(IR_mx),
    .ALU(ALU),
    .LMD(LMD),
    .data(data),
    .IR_wb(IR_wb)
  );

  // -------------------
  // Test sequence
  // -------------------
  initial begin
    $display("------ Starting WB Testbench ------");

    // Initialize signals
    IR_mx = 32'b0;
    ALU   = 32'b0;
    LMD   = 32'b0;
    #5;

    // Test 1: opcode does NOT match 11000 → data = ALU
    IR_mx = 32'b000000_00000000000000000000000000;  // opcode[5:1] = 00000
    ALU   = 32'hAAAA_BBBB;
    LMD   = 32'hCCCC_DDDD;
    #5;
    $display("T=%0t | opcode=%b | data=%h (Expect ALU)", 
              $time, IR_mx[31:26], data);

    // Test 2: opcode[5:1] = 11000 → data = LMD
    IR_mx = 32'b11000_0_0000000000000000000000000; // opcode bits[5:1]=11000
    ALU   = 32'h1234_5678;
    LMD   = 32'h8765_4321;
    #5;
    $display("T=%0t | opcode=%b | data=%h (Expect LMD)", 
              $time, IR_mx[31:26], data);

    // Test 3: Random opcode patterns
    repeat (5) begin
      #5;
      IR_mx = $urandom;
      ALU   = $urandom;
      LMD   = $urandom;
      #1;
      $display("T=%0t | opcode=%b | data=%h | ALU=%h | LMD=%h", 
                $time, IR_mx[31:26], data, ALU, LMD);
    end

    // Test 4: Edge case — all ones
    #5;
    IR_mx = 32'hFFFF_FFFF;
    ALU   = 32'h1111_2222;
    LMD   = 32'h3333_4444;
    #5;
    $display("T=%0t | opcode=%b | data=%h | (Expect LMD since opcode[5:1]=11111≠11000)", 
              $time, IR_mx[31:26], data);

    // Done
    #10;
    $display("------ WB Testbench Completed ------");
    $finish;
  end

  // -------------------
  // Waveform dump
  // -------------------
  initial begin
    $dumpfile("wb_tb.vcd");
    $dumpvars(0, wb_tb);
  end

endmodule
