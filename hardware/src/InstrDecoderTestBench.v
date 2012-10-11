// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

module InstrDecoderTestBench();

  parameter Halfcycle = 5; //half period is 5ns

  localparam Cycle = 2*Halfcycle;

  reg Clock;

  // Clock Signal generation:
  initial Clock = 0; 
  always #(Halfcycle) Clock = ~Clock;

  // Register and wires to test the RegFile
   reg [31:0] instruction;
   wire [4:0] rs;
   wire [4:0] rt;
   wire [4:0] rd;
   wire [4:0] shamt;
   wire [5:0] opcode;
   wire [5:0] funct;
   wire [15:0] immediate;
   wire [25:0] target;

   reg [4:0]   rsOut;
   reg [4:0]  rtOut;
   reg [4:0]  rdOut;
   reg [4:0]  shamtOut;
   reg [5:0]  opcodeOut;
   reg [5:0]  functOut;
   reg [15:0] immediateOut;
   reg [25:0] targetOut;
   
   reg [5:0]  testNumber;
   reg [31:0] rand_32;
 
   
   InstrDecoder DUT(
		    .instruction(instruction),
		    .opcode(opcode),
		    .funct(funct),
		    .rs(rs),
		    .rt(rt),
		    .rd(rd),
		    .shamt(shamt),
		    .immediate(immediate),
		    .target(target)
		    );
   
   task checkOutput;
      input [31:0] instruction1;
      // input [5:0]  opcode, funct;
      

      if (opcodeOut !== opcode ||
	 
	  rsOut !== rs ||
	  rtOut !== rt || 
	  rdOut !== rd ||
	  shamtOut !== shamt ||
	  functOut !== funct ||
	  immediateOut !== immediate ||
	  targetOut !== target) 
	 
	begin
	   $display("FAILED Test for this instruction - %h", instruction1);
	   
	end
      else begin
	 $display("Passed Test for this instruction - %h", instruction1);
      end
   endtask
	 
   integer i;	
   localparam loops = 25;
   
  // Testing logic:
  initial begin
     for(i = 0; i < loops; i = i + 1)
       begin
	  rand_32 = {$random} & 32'hFFFFFFFF;
	  instruction = rand_32;
	  opcodeOut = instruction[31:26];
	  rsOut = instruction[25:21];
	  rtOut = instruction[20:16];
	  rdOut = instruction[15:11];
	  shamtOut = instruction[10:6];
	  functOut = instruction[5:0];
	  immediateOut = instruction[15:0];
	  targetOut = instruction[25:0];
	  #1;
	  checkOutput(instruction);
//, opcodeOut, functOut);
       end
    $finish();
  end
endmodule
