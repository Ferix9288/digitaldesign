`timescale 1ns / 1ps
`include "Opcode.vh"
`include "ALUop.vh"

module HazardCtrTestbench();

  parameter Halfcycle = 5; //half period is 5ns

  localparam Cycle = 2*Halfcycle;

  reg Clock;

  // Clock Signal generation:
  initial Clock = 0; 
  always #(Halfcycle) Clock = ~Clock;

   reg [4:0] rsF;
   reg [4:0] rtF;
   reg [4:0] rsE;
   reg [4:0] rtE;
   reg [4:0] waM;
   reg regWriteM;

   wire FwdAfromMtoE;
   wire FwdBfromMtoE;
   wire FwdAfromMtoF;
   wire FwdBfromMtoF;
   


   reg [5:0]  testNumber;
   
   reg 	      expFwdAfromMtoE;
   reg 	      expFwdBfromMtoE;
   reg 	      expFwdAfromMtoF;
   reg 	      expFwdBfromMtoF;
   
   task checkOutput;
      input [5:0] testNumber;

      if (FwdAfromMtoE !== expFwdAfromMtoE ||
	  FwdBfromMtoE !== expFwdBfromMtoE ||
	  FwdAfromMtoF !== expFwdAfromMtoF ||
	  FwdBfromMtoF !== expFwdBfromMtoF)  begin
	 $display("FAILED - %d", testNumber);
	 
      end
      else begin
	 $display("Passed Test - %d", testNumber);
      end
   endtask // checkOutput

   HazardCtr DUT(.rsF(rsF),
		 .rtF(rtF),
		 .rsE(rsE),
		 .rtE(rtE),
		 .waM(waM),
		 .regWriteM(regWriteM),
		 .FwdAfromMtoE(FwdAfromMtoE),
		 .FwdBfromMtoE(FwdBfromMtoE),
		 .FwdAfromMtoF(FwdAfromMtoF),
		 .FwdBfromMtoF(FwdBfromMtoF)
		 );
   
      
  // Testing logic:
  initial begin

     //If regWriteM not high, then all Forward controls should be driven low
     testNumber = 0;
     rsF = 0;
     rtF = 0;
     rsE = 0;
     rtE = 0;
     waM = 1;
    
     expFwdAfromMtoE = 0;
     expFwdBfromMtoE = 0;
     expFwdAfromMtoF = 0;
     expFwdBfromMtoF = 0;
     regWriteM = 0;
     #1;
     checkOutput(testNumber);

     //All controls should be 0 if write address is 0
     testNumber = 1;

     waM = 0;
     regWriteM = 1;
     #1;
     checkOutput(testNumber);
     
     //FwdAfromMtoE should be high; others driven low
     testNumber = 2;
     rsE = 10;
     waM = 10;
    
     expFwdAfromMtoE = 1;
     #1;
     checkOutput(testNumber);

     //FwdBfromMtoE should be high; others driven low
     testNumber = 3;
     rtE = 20 ;
     waM = 20;
     
     expFwdAfromMtoE = 0;
     expFwdBfromMtoE = 1;   
     #1;
     checkOutput(testNumber);
     
     //FwdAfromMtoF should be high; others driven low
     testNumber = 4;
     rsF = 25;
     waM = 25;
     
     expFwdBfromMtoE = 0;
     expFwdAfromMtoF = 1;
     #1;
     checkOutput(testNumber);
     
     //FwdBfromMtoF should be high; others driven low
     testNumber = 5;
     rtF = 30;
     waM = 30;
     
     expFwdAfromMtoF = 0;
     expFwdBfromMtoF = 1;
     #1;
     checkOutput(testNumber);

     
    $finish();
  end
endmodule
