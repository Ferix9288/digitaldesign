module UARTCtrOut (input [31:0] ALUOutM,
		   input isLoadM,
		   input DataInReady,
		   input DataOutValid,
		   input [7:0] UARTDOut,
		   output reg [31:0] UARTCtrOutM);
   


  //Determining UART Control Out
  wire 				 isUARTM;
   wire [3:0] 			 UARTopM;
   
   assign isUARTM = (ALUOutM[31:28] == 4'b1000);
   assign UARTopM = ALUOutM[3:0];
   
   //assign isLoadM =  (opcodeM == `LB) || (opcodeM == `LH) ||
//		     (opcodeM == `LW) || (opcodeM == `LBU) ||
//		     (opcodeM == `LHU);
   
   always@(*) begin
      UARTCtrOutM = ALUOutM;
      
      if (isUARTM) begin
	 case (UARTopM)

	   //UART transmitter control
	   4'b0: begin
	      if (isLoadM) begin
		 UARTCtrOutM = {31'b0, DataInReady};
	      end
	   end

	   //UART receiver control
	   4'b0100: begin
	      if (isLoadM) begin
		 UARTCtrOutM = {31'b0, DataOutValid};
	      end
	   end   

	   //UART receiver data
	   4'b1100: begin
	      if (isLoadM) begin
		 UARTCtrOutM = {24'b0, UARTDOut};
	      end
	   end
	   
	 endcase // case (UARTop)
      end // if (isUART)
   end // always@ (*)
endmodule
