`include "Opcode.vh"
`include "ALUop.vh"

module UARTCtr (input [31:0] ALUOut,
		input [5:0] opcode,
		input DataInReady,
		input DataOutValid,
		input [7:0] UARTDataOut,
		output reg DataInValid,
		output reg DataOutReady,
		output reg UARTCtr,
		output reg [31:0] UARTCtrOut
   );

   wire 		   isUART, isLoad, isStore;
   wire [3:0] 		   UARTop;
   
      
   assign isUART = (ALUOut[31:28] == 4'b1000) && (ALUOut[27:4] == 24'b0);
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
	   4'h0: begin
	      if (isLoad) begin
		 UARTCtr = 1;
		 DataInValid = 0;
		 DataOutReady = 0;
		 UARTCtrOut = {31'b0, DataInReady};
		 
	      end
	   end

	   //UART receiver control
	   4'h4: begin
	      if (isLoad) begin
		 UARTCtr = 1;
		 DataInValid = 0;
		 DataOutReady = 0;
		 UARTCtrOut = {31'b0, DataOutValid};
		 
	      end
	   end   

	   //UART transmitter data.
	   //Make sure that DataIn of UART is driven by rd2E
	   //Here, we're just validating that data to be written.
	   4'h8: begin
	      if (isStore) begin
		 UARTCtr = 0;
		 DataInValid = 1;
		 DataOutReady =0;
		 UARTCtrOut = ALUOut;
		 
	      end
	   end

	   //UART receiver data
	   4'hc: begin
	      if (isLoad) begin
		 UARTCtr = 1;
		 DataInValid = 0;
		 DataOutReady = 1;
		 UARTCtrOut = {24'b0, UARTDataOut};
		 
	      end
	   end

	   default: begin
	      UARTCtr = 0;
	      DataInValid = 0;
	      DataOutReady = 0;
	      UARTCtrOut = ALUOut;
	   end
	      

	 endcase // case (UARTop)
      end
   end // always @ (*)
   
  

endmodule
