`timescale 1ns / 1ps
`include "Opcode.vh"
`include "ALUop.vh"

module BranchCtrTestbench();

  parameter Halfcycle = 5; //half period is 5ns

  localparam Cycle = 2*Halfcycle;

  reg Clock;

  // Clock Signal generation:
  initial Clock = 0; 
  always #(Halfcycle) Clock = ~Clock;

   reg [5:0]  opcode;
   reg [31:0] rd1;
   reg [31:0] rd2;
   wire       branchCtr;
   
   reg [5:0]  testNumber;
   reg  Expected;

   
  
   task checkOutput;
      input [5:0] testNumber;

      if (branchCtr !== Expected) begin
	 $display("FAILED Test for this opcode - %b", opcode);
	 $display("Got %b, Expected %b", branchCtr, Expected);
	 
      end
      else begin
	 $display("Passed Test #%d for this opcode - %b", testNumber, opcode);
      end
   endtask // checkOutput

   BranchCtr DUT( .opcode(opcode),
		  .rd1(rd1),
		  .rd2(rd2),
		  .branchCtr(branchCtr)
		  );
   
   integer i;	
   localparam loops = 5;
   
  // Testing logic:
  initial begin

     //Test Default. If not any branch instruction, then branchCtr = 0
     testNumber = 0;
     opcode = `ADDIU;
     rd1 = 0;
     rd2 = 0;     
     Expected = 0;
     #1;
     checkOutput(testNumber);

     //Test BEQ. Should be true if rd1 == rd2     
     testNumber = 1;
     opcode = `BEQ;     
     rd1 = 1;
     rd2 = 1;
     Expected = 1;
     #1;
     checkOutput(testNumber);
     
     //Test BEQ. Should be false if rd1 != rd2     
     testNumber = 2;
     opcode = `BEQ;     
     rd1 = 1;
     rd2 = 0;
     Expected = 0;
     #1;
     checkOutput(testNumber);
     
     //Test BNE. Should be true if rd1 != rd2     
     testNumber = 3;
     opcode = `BNE;     
     rd1 = 1;
     rd2 = 0;
     Expected = 1;
     #1;
     checkOutput(testNumber);
  
     //Test BNE. Should be false if rd1 == rd2     
     testNumber = 4;
     opcode = `BNE;     
     rd1 = 3;
     rd2 = 3;
     Expected = 0;
     #1;
     checkOutput(testNumber);

     //Test BLEZ. Should be true if rd1 <= 0
     testNumber = 5;
     opcode = `BLEZ;     
     rd1 = 0;
     rd2 = 123123;
     Expected = 1;
     #1;
     checkOutput(testNumber);

     //Test BLEZ. Should be false if rd1 > 0
     testNumber = 6;
     opcode = `BLEZ;     
     rd1 = 1;
     rd2 = 123123;
     Expected = 0;
     #1;
     checkOutput(testNumber);

     //Test BGTZ. Should be true if rd1 > 0
     testNumber = 7;
     opcode = `BGTZ;     
     rd1 = 1;
     rd2 = 123123;
     Expected = 1;
     #1;
     checkOutput(testNumber);

     //Test BGTZ. Should be true if rd1 <= 0
     testNumber = 8;
     opcode = `BGTZ;     
     rd1 = 0;
     rd2 = 123123;
     Expected = 0;
     #1;
     checkOutput(testNumber);

     //Test BLTZ. Should be true if rd1 < 0.
     //Also must be picked if and only if rd2 == 1
     testNumber = 9;
     opcode = `BLTZ;     
     rd1 = -1;
     rd2 = 1;
     Expected = 1;
     #1;
     checkOutput(testNumber);

     //Test BLTZ. Should be false if rd1 >= 0
     testNumber = 10;
     opcode = `BLTZ;     
     rd1 = 0;
     rd2 = 1;
     Expected = 0;
     #1;
     checkOutput(testNumber);

     //Test BGEZ. Should be true if rd1 >= 0.
     //Also must be picked if and only if rd2 == 0
     testNumber = 11;
     opcode = `BGEZ;     
     rd1 = 0;
     rd2 = 0;
     Expected = 1;
     #1;
     checkOutput(testNumber);

     //Test BGEZ. Should be false if rd1 < 0
     testNumber = 12;
     opcode = `BGEZ;     
     rd1 = -1;
     rd2 = 0;
     Expected = 0;
     #1;
     checkOutput(testNumber);

     
    $finish();
  end
endmodule
