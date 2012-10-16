`include "Opcode.vh"
`include "ALUop.vh"

module UARTCtr (input [31:0] ALUOut,
		input DataInReady,
		input DataOutValid,
		input [7:0] UARTDataOut,
		input [5:0] opcode,
		output reg DataInValid,
		output reg DataOutReady,
		output reg [31:0] UARTCtrOut,
		output reg UARTCtr
   );

   wire 		   isUART, isLoad, isStore;
   wire [3:0] 		   UARTop;
   
      
   assign isUART = (ALUOut[31:28] == 4'b1000);
   assign UARTop = ALUOut[3:0];
   assign isLoad =  (opcode == `LB) || (opcode == `LH) ||
		    (opcode == `LW) || (opcode == `LBU) ||
		    (opcode == `LHU);
   assign isStore = (opcode == `SB) || (opcode == `SH) ||
		    (opcode == `SW);
   
   always @(*) begin

      UARTCtrOut = ALUOut;
      UARTCtr = 0;      
      DataInValid = 0;
      DataOutReady = 0;
      
      if (isUART) begin
	 case (UARTop)

	   //UART transmitter control
	   4'b0: begin
	      if (isLoad) begin
		 UARTCtrOut = {31'b0, DataInReady};
		 UARTCtr = 1;
		 DataInValid = 0;
		 DataOutReady = 0;
	      end
	   end

	   //UART receiver control
	   4'b0100: begin
	      if (isLoad) begin
		 UARTCtrOut = {31'b0, DataOutValid};
		 UARTCtr = 1;
		 DataInValid = 0;
		 DataOutReady = 0;
	      end
	   end   

	   //UART transmitter data.
	   //Make sure that DataIn of UART is driven by ALUOut
	   //Here, we're just validating that data to be written.
	   4'b1000: begin
	      if (isStore) begin
		 UARTCtrOut = ALUOut;
		 UARTCtr = 0;
		 DataInValid = 1;
		 DataOutReady =0;
	      end
	   end

	   //UART receiver data
	   4'b1100: begin
	      if (isLoad) begin
		 UARTCtrOut = {24'b0, UARTDataOut};
		 UARTCtr = 1;
		 DataInValid = 0;	   
		 DataOutReady = 1;
	      end
	   end

	   default: begin
	      UARTCtrOut = ALUOut;
	      UARTCtr = 0;      
	      DataInValid = 0;
	      DataOutReady = 0;
	   end
	     
	 endcase // case (UARTop)
      end
   end // always @ (*)
   
  

endmodule
