module UARTRequest (input clk,
		    input reset,
		    input signal,
		    output reg UARTRequest);

   localparam STATE_Low = 1'b0,
     STATE_High = 1'b1;

   reg 			   CurrentState, NextState;

   always@(posedge clk) begin
      if (reset)
	CurrentState <= STATE_Low;
      else
	CurrentState <= NextState;
   end

   always@(*) begin
      case(CurrentState)
	STATE_Low: begin
	   UARTRequest = (signal)? 1 : 0;
	   NextState = (signal)? STATE_High : CurrentState;
	end

	STATE_High: begin
	   UARTRequest = 0;
	   NextState = (!signal)? STATE_Low: CurrentState;
	end
	
	default: begin
	   UARTRequest = 0;
	   NextState = CurrentState;
	end
      endcase
   end

endmodule
