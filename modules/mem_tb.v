/*
testbench for 32bit word addressable memory setup
*/
`timescale 1ns / 1ps

module tb_inst_mem();

  // Testbench signals
  reg clk;
 
  reg [31:0] data_in;
  reg [9:0] addr_w, addr_r;
  wire [31:0] data_out;

  // Instantiate the memory module
  inst_mem uut (
    .clk(clk),
   
    .data_in(data_in),
    .addr_w(addr_w),
    .addr_r(addr_r),
    .data_out(data_out)
  );

  // Clock generation: 10ns period (100MHz)
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    // Initialize signals
    clk = 0;
  
    data_in = 0;
    addr_w = 0;
    addr_r = 0;



    // Write a few values into memory
    $display("Writing data into memory...");
    write_mem(10'd0, 32'hAAAA_BBBB);
    write_mem(10'd1, 32'h1234_5678);
    write_mem(10'd2, 32'hDEAD_BEEF);

    // Read back the data
    $display("Reading data from memory...");
    read_mem(10'd0);
    read_mem(10'd1);
    read_mem(10'd2);

    // Test overwrite
    $display("Overwriting data at address 1...");
    write_mem(10'd1, 32'hFFFF_0000);
    read_mem(10'd1);

    $display("--- Memory Test Completed ---\n");
    $finish;
  end

  // Task to write data to memory
  task write_mem(input [9:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      addr_w <= addr;
      data_in <= data;      
      $display("Time %0t: WRITE addr=%0d data=0x%08h", $time, addr, data);
    end
  endtask

  // Task to read data from memory
  task read_mem(input [9:0] addr);
    begin
      @(posedge clk);
      addr_r <= addr;
      $display("Time %0t: READ  addr=%0d data=0x%08h", $time, addr, data_out);
    end
  endtask

endmodule
