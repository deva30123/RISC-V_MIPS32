`timescale 1ns / 1ps

module tb_mips32;

  // Clock signal
  reg clk;

  // Instantiate the DUT (Device Under Test)
  mips32 uut (
    .clk_x(clk)
  );

  // Clock generation: 10 ns period (100 MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  initial begin
    //fillup data mem
     for(int i=0;i<1024;i++)begin
      uut.max.data[i] = $random;      
      //$display("T=%0t | R%d = 0x%h ",$time, i, uut.reg_b[i]); 
    end
    $display( "R1 = 0x%h ", uut.max.data[1]); 
    $display( "R2 = 0x%h ", uut.max.data[2]);
    $display( "R2 = 0x%h ", uut.max.data[3]);    
  end
  initial begin
    //fillup inst mem
    uut.i_f.mem[0]=32'hc020_0001;
    uut.i_f.mem[1]=32'hc040_0002;
    uut.i_f.mem[0]=32'h0061_1000;
    uut.i_f.mem[0]=32'hc480_0003;
    end
  end

  // Simulation control
  initial begin
    // Initialize VCD file for waveform dumping
    $dumpfile("mips32_tb.vcd");
    $dumpvars(0, tb_mips32);

    // Display message
    $display("Starting MIPS32 pipeline simulation...");
    
    $display( "R1 = 0x%h ", uut.id.reg_b[1]); 
    $display( "R2 = 0x%h ", uut.id.reg_b[2]);
    $display( "R3 = 0x%h ", uut.id.reg_b[3]); 
    $display( "R4 = 0x%h ", uut.id.reg_b[4]);

    // Run simulation for 200 ns
    #200;
    $display( "R1 = 0x%h ", uut.id.reg_b[1]); 
    $display( "R2 = 0x%h ", uut.id.reg_b[2]);
    $display( "R3 = 0x%h ", uut.id.reg_b[3]); 
    $display( "R4 = 0x%h ", uut.id.reg_b[4]);
    
    $display( "D1 = 0x%h ", uut.max.data[1]); 
    $display( "D2 = 0x%h ", uut.max.data[2]);
    $display( "D3 = 0x%h ", uut.max.data[3]); 

    // Finish simulation
    $display("Simulation complete.");
    $finish;
  end

endmodule
