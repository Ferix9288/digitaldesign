`timescale 1ns / 1ps
`include "Opcode.vh"
`include "ALUop.vh"

module UARTCtrTestbench();

  parameter Halfcycle = 5; //half period is 5ns

  localparam Cycle = 2*Halfcycle;

  reg Clock;

  // Clock Signal generation:
  initial Clock = 0; 
  always #(Halfcycle) Clock = ~Clock;

   reg [31:0] ALUOut;
   reg 	DataInReady;
   reg 	DataOutValid;
   reg [7:0] UARTDataOut;
   reg [5:0]  opcode;

   wire       DataInValid;
   wire       DataOutReady;
   wire [31:0] UARTCtrOut;
   wire        UARTCtr;
   
   reg [5:0]  testNumber;
   
   reg 	      expDataInValid;
   reg 	      expDataOutReady;
   reg [31:0] expUARTCtrOut;
   reg 	      expUARTCtr;
   

   
  
   task checkOutput;
      input [5:0] testNumber;

      if (DataInValid !== expDataInValid ||
	  DataOutReady !== expDataOutReady ||
	  UARTCtrOut !== expUARTCtrOut ||
	  UARTCtr !== expUARTCtr) begin
	 $display("FAILED - %d", testNumber);
	 
      end
      else begin
	 $display("Passed Test - %d", testNumber);
      end
   endtask // checkOutput

   UARTCtr DUT(.ALUOut(ALUOut),
	       .DataInReady(DataInReady),
	       .DataOutValid(DataOutValid),
	       .UARTDataOut(UARTDataOut),
	       .opcode(opcode),
	       .DataInValid(DataInValid),
	       .DataOutReady(DataOutReady),
	       .UARTCtrOut(UARTCtrOut),
	       .UARTCtr(UARTCtr)
	       );
      
  // Testing logic:
  initial begin

     //Test Default. If not UART address @ all, do nothing
     testNumber = 0;
     ALUOut = 32'h0fffffff;
     DataInReady = 0;
     DataOutValid = 0;
     UARTDataOut = 0;
     opcode = `ADDIU;

     expDataInValid = 0;
     expDataOutReady = 0;
     expUARTCtrOut = ALUOut;
     expUARTCtr = 0;
     #1;
     checkOutput(testNumber);

     //Test Default # 2. If it is UART address but not correct op, do nothing     
     testNumber = 1;
     ALUOut = 32'h80000007;    
     opcode = `SW;
     expUARTCtrOut = ALUOut;
     
     #1;
     checkOutput(testNumber);
     
     //Test Default # 3. If correct UART address and op 
     // but incorrect OPCODE, do nothing
     testNumber = 2;
     opcode = `SW;     
     ALUOut = 32'h80000004;
     expUARTCtrOut = ALUOut;
     
     #1;
     checkOutput(testNumber);

     //Test UART transmitter control.
     testNumber = 3;
     ALUOut = 32'h8ffffff0;
     DataInReady = 1;
     opcode = `LW;
     
     expDataInValid = 0;
     expDataOutReady = 0;
     expUARTCtrOut = {31'b0, DataInReady};
     expUARTCtr = 1;
     #1;
     checkOutput(testNumber);
 
    //Test UART receiver control.
     testNumber = 4;
     ALUOut = 32'h8ffffff4;
     DataInReady = 1;
     DataOutValid = 0;     
     opcode = `LB;
     
     expDataInValid = 0;
     expDataOutReady = 0;
     expUARTCtrOut = 32'b0;
     expUARTCtr = 1;
     #1;
     checkOutput(testNumber);

     //Test UART transmitter data.
     testNumber = 5;
     ALUOut = 32'h8ffffff8;    
     opcode = `SB;
     
     expDataInValid = 1;
     expDataOutReady = 0;
     expUARTCtrOut = ALUOut;
     expUARTCtr = 0;
     #1;
     checkOutput(testNumber);

     //Test UART receiver data.
     testNumber = 6;
     ALUOut = 32'h8ffffffc;    
     opcode = `LHU;
     UARTDataOut = 8'hc4;
     		   
     expDataInValid = 0;
     expDataOutReady = 1;
     expUARTCtrOut = {24'b0, UARTDataOut};
     expUARTCtr = 1;
     #1;
     checkOutput(testNumber);
     
  

     
    $finish();
  end
endmodule
