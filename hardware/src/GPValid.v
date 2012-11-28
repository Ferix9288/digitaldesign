//FSM that correctly toggles GPValid only once
module GPValid ( input clk,
		 input rst,
		 input stall,
		 input is_GP_CODE,
		 output GP_valid);

   localparam LOW = 2'b00;
   localparam HIGH = 2'b01;
   localparam WAIT_STALL_LOW = 2'b10;
   

   reg [1:0] 		curState, nextState;

   always@(posedge clk) begin
      if (rst) begin
	 curState <= LOW;
      end else begin
	 curState <= nextState;
      end
   end

   always@(*) begin
      nextState = curState;
      case (curState)
	LOW: begin
	   if (is_GP_CODE & stall)
	     nextState = WAIT_STALL_LOW;
	   else 
	     nextState = (is_GP_CODE)? HIGH: curState;
	end

	WAIT_STALL_LOW: begin
	   nextState = (!stall)? HIGH: curState;
	end
	  
	HIGH: begin
	   nextState = LOW;
	end

      endcase // case (curState)

   end // always@ (*)

   assign GP_valid = (curState == HIGH);
   
endmodule // GPValid

