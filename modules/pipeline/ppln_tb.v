`timescale 1ns / 1ps

module tb_mips32;

  // Clock signal
  reg clk;
  reg rst =0 ;

  // Instantiate the DUT (Device Under Test)
  mips32 uut (
    .clk_x(clk),.rst(rst)
  );

  // Clock generation: 10 ns period (100 MHz)
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  initial begin
    rst =0 ;
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
//    // Test Case 0 filling up the reg bank
//     for(int i=1;i<32;i++)begin
//       uut.id.reg_b[i] = $random;      
//       $display("T=%0t | R%d = 0x%h ",$time, i, uut.id.reg_b[i]); 
//     end
//   end  
  
//   initial begin
//     rst =0 ;
//     //fillup inst mem
//     uut.i_f.mem[1]=32'hc020_0001;//load R1 with d1
//     uut.i_f.mem[2]=32'hc040_0002;//load r2 with d2
    
//     uut.i_f.mem[3]=32'h0000_0000;//nop
//     uut.i_f.mem[4]=32'h0000_0000;//nop
//     uut.i_f.mem[5]=32'h0000_0000;//nop
//     uut.i_f.mem[6]=32'h0000_0000;//nop
    
//     uut.i_f.mem[7]=32'h0061_1000;//R3=R1+R2
        
//     uut.i_f.mem[8]=32'h0000_0000;//nop
//     uut.i_f.mem[9]=32'h0000_0000;//nop
//     uut.i_f.mem[10]=32'h0000_0000;//nop
//     uut.i_f.mem[11]=32'h0000_0000;//nop
    

//     uut.i_f.mem[12]=32'h4883_0002;//R4=R3*2
        
//     uut.i_f.mem[13]=32'h0000_0000;//nop
//     uut.i_f.mem[14]=32'h0000_0000;//nop
//     uut.i_f.mem[15]=32'h0000_0000;//nop
//     uut.i_f.mem[16]=32'h0000_0000;//nop

//     uut.i_f.mem[17]=32'hc480_0003;//store R4 in d3
    
//     uut.i_f.mem[18]=32'h0000_0000;//nop
//     uut.i_f.mem[19]=32'h0000_0000;//nop
//     uut.i_f.mem[20]=32'h0000_0000;//nop  
//     uut.i_f.mem[21]=32'h0000_0000;//nop
    
//     uut.i_f.mem[21]=32'hd000_0005;//branch
//     uut.i_f.mem[27]=32'hffff_0005;//hlt
    
//   end
  
  initial begin
    int i=1;
    rst=0;
    //fillup inst mem
    uut.i_f.mem[i++]=32'hc020_0001;//load R1 with d1
    uut.i_f.mem[i++]=32'hc040_0002;//load R2 with d2
//    uut.i_f.mem[i++]=32'h0000_0000;//nop
//    uut.i_f.mem[i++]=32'h0000_0000;//nop
//    uut.i_f.mem[i++]=32'h0000_0000;//nop
    uut.i_f.mem[i++]=32'h0061_1000;//R3=R1+R2
    uut.i_f.mem[i++]=32'h4883_0002;//R4=R3^2//alu raw
    uut.i_f.mem[i++]=32'hc480_0003;//store R4 in d3
    uut.i_f.mem[i++]=32'hd000_0005;//branch
    uut.i_f.mem[i+5]=32'hffff_0005;//hlt
  end


  // Simulation control
 
  initial begin
    rst =0 ;
    // Initialize VCD file for waveform dumping
    $dumpfile("mips32_tb.vcd");
    $dumpvars(0, tb_mips32);
//     uut.npcx = 0;
//     uut.sel = 1;
//     #10
//     uut.sel = 0;
    

    // Display message
    $display("Starting MIPS32 pipeline simulation...");
    
    $display( "R1 = 0x%h ", uut.id.reg_b[1]); 
    $display( "R2 = 0x%h ", uut.id.reg_b[2]);
    $display( "R3 = 0x%h ", uut.id.reg_b[3]); 
    $display( "R4 = 0x%h ", uut.id.reg_b[4]);

    // Run simulation for 200 ns
    #700;
    $display("results after simulation...");
    $display( "R1 = 0x%h ", uut.id.reg_b[1]); 
    $display( "R2 = 0x%h ", uut.id.reg_b[2]);
    $display( "R3 = 0x%h ", uut.id.reg_b[3]); 
    $display( "R4 = 0x%h ", uut.id.reg_b[4]);
    
    $display( "D1 = 0x%h ", uut.max.data[1]); 
    $display( "D2 = 0x%h ", uut.max.data[2]);
    $display( "D3 = 0x%h ", uut.max.data[3]); 
    rst = 1;
    #300;

    // Finish simulation
    $display("Simulation complete.");
    $finish;
  end
endmodule
