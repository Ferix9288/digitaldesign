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

   reg [5:0]  opcode;
   reg [1:0]  byteOffset;
   reg [3:0]  AddrPartition;
   reg [31:0] ALUOut;
   
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
		   .AddrPartition(AddrPartition),
		   .ALUOut(ALUOut),
		   .writeEn(writeEn)
		   );
   
   integer i;	
   localparam loops = 5;
   
  // Testing logic:
  initial begin
     //If not store instruction, then writeEnable should be driven low
     testNumber = 0;
     opcode = `ADDIU;
     byteOffset = 2'b0;
     AddrPartition = 4'b0??1;
     ALUOut = 32'h3000ffff;   
     Expected = 4'b0000;
     #1;
     checkOutput(testNumber);

     //If doesn't match correct address partition, then writeEnable -> 0
     testNumber = 1;
     opcode = `SB;
     byteOffset = 2'b10;
     ALUOut = 32'h4fffffff;
     #1;
     checkOutput(testNumber);
     
     
     
     //Store byte @ offset 00 => 1000 for write enable
     testNumber = 2;
     opcode = `SB;
     byteOffset = 2'b0;
     ALUOut = 32'h3fffffff;     
     Expected = 4'b1000;
     #1;
     checkOutput(testNumber);
     
     //Store byte @ offset 01 => 0100 for write enable
     testNumber = 3;
     opcode = `SB;
     byteOffset = 2'b01;
     Expected = 4'b0100;
     #1;
     checkOutput(testNumber);
    
     //Store byte @ offset 10 => 0010 for write enable
     testNumber = 4;
     opcode = `SB;
     byteOffset = 2'b10;
     Expected = 4'b0010;
     #1;
     checkOutput(testNumber);
     

     
     //Store byte @ offset 11  => 0001 for write enable
     testNumber = 5;
     opcode = `SB;
     byteOffset = 2'b11;
     Expected = 4'b0001;
     #1;
     checkOutput(testNumber);
     
    //Store half-word @ offset 00  => 1100 for write enable
     testNumber = 6;
     opcode = `SH;
     byteOffset = 2'b00;
     Expected = 4'b1100;
     #1;
     checkOutput(testNumber);
     
     //Store half-word @ offset 11  => 0011 for write enable
     testNumber = 7;
     opcode = `SH;
     byteOffset = 2'b11;
     Expected = 4'b0011;
     #1;
     checkOutput(testNumber);
     
     //Store word @ offset w/e  => 1111 for write enable
     testNumber = 8;     
     opcode = `SW;
     byteOffset = 2'b10;
     Expected = 4'b1111;
     #1;
     checkOutput(testNumber);
  
      
    $finish();
  end
endmodule
