module UATransmit(
  input   Clock,
  input   Reset,

  input   [7:0] DataIn,
  input         DataInValid,
  output        DataInReady,

		  output        SOut
);
  // for log2 function
  `include "util.vh"

  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq         =   100_000_000;
  parameter   BaudRate          =   115_200;

  // See diagram in the lab guide
  localparam  SymbolEdgeTime    =   ClockFreq / BaudRate;
  localparam  ClockCounterWidth =   log2(SymbolEdgeTime);

  //--|Solution|----------------------------------------------------------------
   wire 	Start;
   wire 	SymbolEdge;
   wire 	isRunning;   
   
   reg [3:0] 	BitCounter;
   reg [9:0] 	TXShift;
   reg 		tmp;
   
   //reg 		reachedEnd;
   reg [ClockCounterWidth-1:0] ClockCounter;
   
 
   //Signal-Assignments

   //Goes high @ every symbol edge
   assign SymbolEdge = (ClockCounter == SymbolEdgeTime - 1);

   //Goes high when it's ready to start receiving new data from source
   assign Start = DataInValid && !isRunning;

   //Currently receiving a character
   assign isRunning = BitCounter != 4'd10;

   //Outputs
   assign DataInReady = !isRunning;

   // Counts cycles until a single symbol is done
   always @ (posedge Clock) begin
      ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter + 1;
   end


   //Going down each of the 8 bits of the byte
   always @ (posedge Clock) begin
      if (Reset) begin
	 BitCounter <= 10;
      end else if (Start) begin
	 BitCounter <= 0;
      end else if (SymbolEdge && isRunning) begin
	 BitCounter <= BitCounter + 1;
	 tmp <= TXShift[BitCounter];
	 
      end
   end   

   assign SOut = tmp;
   
   
   //Shift Register

   always @(posedge Clock) begin
      if (Start) TXShift <= {1'b1, DataIn, 1'b0};
   end
	
endmodule
