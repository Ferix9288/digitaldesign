`timescale 1ns / 1ps
`include "Opcode.vh"
`include "ALUop.vh"

module DataOutMaskTestbench();

  parameter Halfcycle = 5; //half period is 5ns

  localparam Cycle = 2*Halfcycle;

  reg Clock;

  // Clock Signal generation:
  initial Clock = 0; 
  always #(Halfcycle) Clock = ~Clock;

  // Register and wires to test the RegFile
   reg [31:0] DataOutMem;
   reg [5:0]  opcode;
   reg [1:0]  byteOffset;
   wire [31:0] DataOutMasked;
   
   reg [5:0]  testNumber;
   reg [31:0] Expected;
   reg [31:0] rand_32;
   reg [30:0] rand_31;
   
  
   task checkOutput;
      input [5:0] testNumber;

      if (DataOutMasked !== Expected) begin
	 $display("FAILED Test for this opcode - %b - and DataOutMem - %h", opcode, DataOutMem);
	 $display("Got %h, Expected %h", DataOutMasked, Expected);
	 
      end
      else begin
	 $display("Passed Test for this opcode - %b - and DataOutMem - %h, DataOutMasked - %h, Expected %h", opcode, DataOutMem, DataOutMasked, Expected);
      end
   endtask // checkOutput

   DataOutMask DUT( .DataOutMem(DataOutMem),
		    .opcode(opcode),
		    .byteOffset(byteOffset),
		    .DataOutMasked(DataOutMasked)
		    );
   
   integer i;	
   localparam loops = 5;
   
  // Testing logic:
  initial begin
     testNumber = 0;

     //LoadByte Instruction; should sign extend
     DataOutMem = 32'hffffffff;
     opcode = `LB;
     byteOffset = 2'b0;
     Expected = {24'hffffff, DataOutMem[30:23]};
     #1;

     checkOutput(testNumber);

     
     //If not a load instruction, then just return what DataOutMem is 
     opcode = `ADDIU;
     DataOutMem = 32'h4;
     Expected = 4;
     #1;
     
     checkOutput(testNumber);
     
     
     //LoadByte (signed extended) where byte offset is @ 00
     for(i = 0; i < loops; i = i + 1)
       begin
	  rand_31 = {$random} & 31'hFFFFFFFF;
	  DataOutMem = {1'b1, rand_31};
	  opcode = `LB;
	  byteOffset = 2'b0;
	  Expected = {24'hffffff, DataOutMem[31:24]};
	  #1; 
	  checkOutput(testNumber);
       end
    
     //LoadByte (signed extended) where byteoffset is @ 10
     for(i = 0; i < loops; i = i + 1)
       begin
	  rand_31 = {$random} & 31'hFFFFFFFF;
	  DataOutMem = {rand_31[30:15], 1'b1, rand_31[14:0]};
	  opcode = `LB;
	  byteOffset = 2'b10;
	  Expected = {24'hffffff, DataOutMem[15:8]};
	  #1;
	  
	  checkOutput(testNumber);
       end // for (i = 0; i < loops; i = i + 1)

     //LoadByte (signed extended) where byte offset is @10 (but the actual byte is positive)
     for(i = 0; i < loops; i = i + 1)
       begin
	  rand_31 = {$random} & 31'hFFFFFFFF;
	  DataOutMem = {rand_31[30:15], 1'b0, rand_31[14:0]};
	  opcode = `LB;
	  byteOffset = 2'b10;
	  Expected = {24'b0, DataOutMem[15:8]};
	  #1;
	  
	  checkOutput(testNumber);
       end // for (i = 0; i < loops; i = i + 1)

     //LoadByteUnsigned where byteoffset is @10 (byte is 'signed' but treats it as unsigned)
     for(i = 0; i < loops; i = i + 1)
       begin
	  rand_31 = {$random} & 31'hFFFFFFFF;
	  DataOutMem = {rand_31[30:15], 1'b1, rand_31[14:0]};
	  opcode = `LB;
	  byteOffset = 2'b10;
	  Expected = {24'hffffff, DataOutMem[15:8]};
	  #1;
	  
	  checkOutput(testNumber);
       end // for (i = 0; i < loops; i = i + 1)

     //Check LoadHalf (signed extended) where byte offset is 1 (therefore takes lower 16 bits)
     //Additionally, lower bit should be a 0 because it's half-word alligned
     for(i = 0; i < loops; i = i + 1)
       begin
	  rand_31 = {$random} & 31'hFFFFFFFF;
	  DataOutMem = {rand_31[30:15], 1'b1, rand_31[14:0]};
	  opcode = `LH;
	  byteOffset = 2'b01;
	  Expected = {15'hffff, DataOutMem[15:0], 1'b0};
	  #1;

	  checkOutput(testNumber);
       end

     //Check LoadHalf Unsigned where byte offset is 1
     for(i = 0; i < loops; i = i + 1)
       begin
	  rand_31 = {$random} & 31'hFFFFFFFF;
	  DataOutMem = {rand_31[30:15], 1'b1, rand_31[14:0]};
	  opcode = `LHU;
	  byteOffset = 2'b01;
	  Expected = {15'b0, DataOutMem[15:0], 1'b0};
	  #1;

	  checkOutput(testNumber);
       end // for (i = 0; i < loops; i = i + 1)

     //Check LoadWord (passes the top 30 bits and concatenates two zeros @ end to make it word aligned)
     for(i = 0; i < loops; i = i + 1)
       begin
	  rand_31 = {$random} & 31'hFFFFFFFF;
	  DataOutMem = {rand_31[30:15], 1'b1, rand_31[14:0]};
	  opcode = `LW;
	  byteOffset = 2'b11;
	  Expected = {DataOutMem[31:2], 2'b0};
	  #1;

	  checkOutput(testNumber);
       end // for (i = 0; i < loops; i = i + 1) 
     
  
      
    $finish();
  end
endmodule
