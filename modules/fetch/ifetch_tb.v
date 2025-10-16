// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module ifetch_tb;

  // -------------------
  // Testbench signals
  // -------------------
  reg clk; 
  reg [31:0] NPC_mem;
  reg sel;
  wire [31:0] NPC;
  wire [31:0] IR;

  // -------------------
  // DUT instantiation
  // -------------------
  ifetch uut (
    .clk(clk),
    .NPC_alu(NPC_mem),
    .sel(sel),
    .NPC(NPC),
    .IR(IR)
  );
  

  // -------------------
  // Clock generation
  // -------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10 ns clock period
  end

  // -------------------
  // Test sequence
  // -------------------
  initial begin
    // Initialize signals
    
    NPC_mem = 0;
    sel = 1;
    
     // Test Case 0 filling up the reg bank
    for(int i=0;i<1024;i++)begin
      uut.mem[i] = $random;      
      //$display("T=%0t | R%d = 0x%h ",$time, i, uut.reg_b[i]); 
    end
    // Wait for some cycles
    #10;

//     // Test 1: select NPC_mem
//     for(int i=0;i<10;i++)begin
//       #10 NPC_mem = $urandom % 1024;     
//       $display("T=%0t | PC=%h : IR=0x%h | NPC=%h ",$time, uut.PC , IR , NPC); 
//     end
    
    #10;
    // Test 2: branch & increment
    $display("T=%0t | PC=%h : IR=0x%h | NPC=%h ",$time, uut.PC , IR , NPC); 
    #10 sel = 0;
    #10 $display("T=%0t | PC=%h : IR=0x%h | NPC=%h ",$time, uut.PC , IR , NPC);
    NPC_mem = $urandom % 1024;
    #10 $display("T=%0t | PC=%h : IR=0x%h | NPC=%h ",$time, uut.PC , IR , NPC);
    #10 sel = 1;
    #10 $display("T=%0t | PC=%h : IR=0x%h | NPC=%h ",$time, uut.PC , IR , NPC);
    #10 sel = 0;
    #10 $display("T=%0t | PC=%h : IR=0x%h | NPC=%h ",$time, uut.PC , IR , NPC);
    #10 $display("T=%0t | PC=%h : IR=0x%h | NPC=%h ",$time, uut.PC , IR , NPC);
    #10 $display("T=%0t | PC=%h : IR=0x%h | NPC=%h ",$time, uut.PC , IR , NPC);

    // End simulation
    $finish;
  end

  // -------------------
  // Waveform dump for viewing
  // -------------------
  initial begin
    $dumpfile("ifetch_tb.vcd");
    $dumpvars(0, ifetch_tb);
  end

endmodule
