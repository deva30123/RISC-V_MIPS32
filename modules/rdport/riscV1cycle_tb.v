`timescale 1ns / 1ps

module tb_mips32;

  // Clock signal
  reg clk,rst;
  reg [1:0]mode=0;
  reg[31:0] w_addr,in_data;
  
  // Instantiate the DUT (Device Under Test)
  mips32 uut (
    .clk_x(clk),
    .rst(rst),
    .mode(mode),.w_addr(w_addr),.in_data(in_data)
  );

  // Clock generation: 10 ns period (100 MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  initial begin
    rst=0;
    //fillup data mem
     for(int i=0;i<1024;i++)begin
      uut.max.data[i] = $random;      
      //$display("T=%0t | R%d = 0x%h ",$time, i, uut.reg_b[i]); 
    end
    $display( "D1 = 0x%h ", uut.max.data[1]); 
    $display( "D2 = 0x%h ", uut.max.data[2]);
    $display( "D3 = 0x%h ", uut.max.data[3]);    
  end
//   initial begin
//     rst=0;
//     //fillup inst mem
//     uut.i_f.mem[1]=32'hc020_0001;//LD R1,mem[R0+1]
//     uut.i_f.mem[2]=32'hc040_0002;//LD R2,mem[R0+2]
//     uut.i_f.mem[3]=32'h0061_1000;//AD R3,R1,R1
//     uut.i_f.mem[4]=32'h4883_0002;//XR R4,R3,2
//     uut.i_f.mem[5]=32'hc480_0003;//ST R4,mem[R0+3]
//     uut.i_f.mem[6]=32'hd000_0005;//branch
//     uut.i_f.mem[12]=32'hffff_0005;//hlt 
//   end

  // Simulation control
 
  initial begin
    rst=0;
   
    
    // Initialize VCD file for waveform dumping
    $dumpfile("mips32_tb.vcd");
    $dumpvars(0, tb_mips32);
//     uut.npcx = 0;
//     uut.sel = 1;
//     #10
//     uut.sel = 0;
    
     
    mode = 2'b10;//inst write
    #10 w_addr = 32'h0000_0001;
        in_data = 32'hc020_0001;//LD R1,mem[R0+1]
    #10 w_addr = 32'h0000_0002;
    	in_data = 32'hc040_0002;;//LD R2,mem[R0+2]
    #10 w_addr = 32'h0000_0003;
    	in_data = 32'h0061_1000;//AD R3,R1,R1
    #10 w_addr = 32'h0000_0004;
    	in_data = 32'h4883_0002;//XR R4,R3,2
    #10 w_addr = 32'h0000_0005;
    	in_data = 32'hc480_0003;//ST R4,mem[R0+3]
    #10 w_addr = 32'h0000_0006;
    	in_data = 32'hd000_0005;//branch
    #10 w_addr = 32'd0000_0012;
    	in_data = 32'hffff_0005;//hlt      
    #10 mode = 2'b00;
    $display( "IR1 = 0x%h ", uut.i_f.mem[1]); 
    $display( "IR2 = 0x%h ", uut.i_f.mem[2]);
    $display( "IR3 = 0x%h ", uut.i_f.mem[3]); 
    $display( "IR4 = 0x%h ", uut.i_f.mem[4]);
    $display( "IR5 = 0x%h ", uut.i_f.mem[5]); 
    $display( "IR6 = 0x%h ", uut.i_f.mem[6]);
    $display( "IR12 = 0x%h ", uut.i_f.mem[12]); 
    
    // Display message
    $display("Starting MIPS32 pipeline simulation...");
    
    $display( "R1 = 0x%h ", uut.id.reg_b[1]); 
    $display( "R2 = 0x%h ", uut.id.reg_b[2]);
    $display( "R3 = 0x%h ", uut.id.reg_b[3]); 
    $display( "R4 = 0x%h ", uut.id.reg_b[4]);

    // Run simulation for 200 ns
    #180;
    $display("results after simulation...");
    $display( "R1 = 0x%h ", uut.id.reg_b[1]); 
    $display( "R2 = 0x%h ", uut.id.reg_b[2]);
    $display( "R3 = 0x%h ", uut.id.reg_b[3]); 
    $display( "R4 = 0x%h ", uut.id.reg_b[4]);
    
    $display( "D1 = 0x%h ", uut.max.data[1]); 
    $display( "D2 = 0x%h ", uut.max.data[2]);
    $display( "D3 = 0x%h ", uut.max.data[3]);
    rst = 1;
    #20;
    

    // Finish simulation
    $display("Simulation complete.");
    $finish;
  end

endmodule
