// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

module RegFileTestbench();

  parameter Halfcycle = 5; //half period is 5ns

  localparam Cycle = 2*Halfcycle;

  reg Clock;

  // Clock Signal generation:
  initial Clock = 0; 
  always #(Halfcycle) Clock = ~Clock;

  // Register and wires to test the RegFile
  reg [4:0] ra1;
  reg [4:0] ra2;
  reg [4:0] wa;
  reg we;
  reg [31:0] wd;
  wire [31:0] rd1;
  wire [31:0] rd2;

   reg [31:0] RFout;
   reg [31:0] Expected;
   reg [5:0]  testNumber;
   
 
  RegFile DUT(.clk(Clock),
              .we(we),
              .ra1(ra1),
              .ra2(ra2),
              .wa(wa),
              .wd(wd),
              .rd1(rd1),
              .rd2(rd2));
  
   task checkOutput;
      input [5:0] testNumber;
      
      
      
      if (RFout !== Expected) begin
	 $display("FAILED Test %d: Incorrect result. Got: %d, Expected: %d",testNumber,  RFout, Expected);
      end
      else begin
	 $display("Passed Test # - %d", testNumber);
      end
   endtask
	 
	
      
  // Testing logic:
  initial begin
     we = 1;
     
     // Verify that writing to reg 0 is a nop
     //Ensuring that register 0 remains 0
     testNumber = 0;
     wa = 0;
     wd = 30;
     ra1 = 0;
     ra2 = 1;
     Expected = 0;
     #10;
     RFout = rd1;     
     checkOutput(testNumber);
     
    // Verify that data written to any other register is returned the same
    // cycle
     //Writing to address1, and then reading from it in same cycle
     testNumber = 1;
     wa = 1;
     wd = 40;
     Expected = 40;
     #10;
     RFout = wd;
     checkOutput(testNumber);
     
    // Verify that the we pin prevents data from being written
     testNumber = 2;
     wa = 2;
     wd = 50;
     ra2 = 2;
     Expected = 50;
     #10;
     RFout = rd2;
     checkOutput(testNumber);

     testNumber = 3;
     we = 0;
     wd = 60;
     #10;    
     checkOutput(testNumber);
     
    // Verify the reads are asynchronous
     testNumber = 4;
     wa = 3;
     we = 1;
     wd = 70;
     Expected = 70;
     ra2 = 3;
     #10;
     RFout = rd2;
     checkOutput(testNumber);
   
    $finish();
  end
endmodule
