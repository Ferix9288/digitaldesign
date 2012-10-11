`timescale 1ns / 1ps
`include "Opcode.vh"
`include "ALUop.vh"

module WriteEnCtrTestbench();

  parameter Halfcycle = 5; //half period is 5ns

  localparam Cycle = 2*Halfcycle;

  reg Clock;

  // Clock Signal generation:
  initial Clock = 0; 
  always #(Halfcycle) Clock = ~Clock;

  // Register and wires to test the RegFile
   reg [5:0]  opcode;
   reg [1:0]  byteOffset;
   wire [3:0] writeEn;
   
   reg [5:0]  testNumber;
   reg [3:0] Expected;

   
  
   task checkOutput;
      input [5:0] testNumber;

      if (writeEn !== Expected) begin
	 $display("FAILED Test for this opcode - %b - and byteOffset - %b", opcode, byteOffset);
	 $display("Got %b, Expected %b", writeEn, Expected);
	 
      end
      else begin
	 $display("Passed Test #%d for this opcode - %b - and byteOffset - %b", testNumber, opcode, byteOffset);
      end
   endtask // checkOutput

   WriteEnCtr DUT( .opcode(opcode),
		   .byteOffset(byteOffset),
		   .writeEn(writeEn)
		   );
   
   integer i;	
   localparam loops = 5;
   
  // Testing logic:
  initial begin
     testNumber = 0;

     //If not store instruction, then writeEnable should be driven low
     opcode = `ADDIU;
     byteOffset = 2'b0;
     Expected = 4'b0000;
     #1;

     checkOutput(testNumber);
     
     testNumber = 1;
     
     
     //Store byte @ offset 00 => 1000 for write enable
     opcode = `SB;
     byteOffset = 2'b0;
     Expected = 4'b1000;
     #1;

     checkOutput(testNumber);
     testNumber = 2;
     

     //Store byte @ offset 01 => 0100 for write enable
     opcode = `SB;
     byteOffset = 2'b01;
     Expected = 4'b0100;
     #1;

     checkOutput(testNumber);
     testNumber = 3;
     

     
     
     
     //Store byte @ offset 10 => 0010 for write enable
     opcode = `SB;
     byteOffset = 2'b10;
     Expected = 4'b0010;
     #1;

     checkOutput(testNumber);
     testNumber = 4;
     

     
     //Store byte @ offset 11  => 0001 for write enable
     opcode = `SB;
     byteOffset = 2'b11;
     Expected = 4'b0001;
     #1;

     checkOutput(testNumber);
     testNumber = 5;
     
    //Store half-word @ offset 00  => 1100 for write enable
     opcode = `SH;
     byteOffset = 2'b00;
     Expected = 4'b1100;
     #1;

     checkOutput(testNumber);
     testNumber = 6;
     
     
     //Store half-word @ offset 11  => 0011 for write enable
     opcode = `SH;
     byteOffset = 2'b11;
     Expected = 4'b0011;
     #1;

     checkOutput(testNumber);
     testNumber = 7;
     
     //Store word @ offset w/e  => 1111 for write enable
     opcode = `SW;
     byteOffset = 2'b10;
     Expected = 4'b1111;
     #1;

     checkOutput(testNumber);
     testNumber = 8;
  
      
    $finish();
  end
endmodule
