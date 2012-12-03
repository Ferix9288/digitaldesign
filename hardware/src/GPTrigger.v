module GPTrigger( input clk,
		  input rst,
		  input interrupt,
		  input frame_ready,
		  output GP_trigger);

   

   localparam IDLE = 1'b0;
   localparam WAIT_HANDSHAKE = 1'b1;
   
   reg 			 curState, nextState;
  
   always@(posedge clk) begin
      if (rst) 
	curState <= IDLE;
      else
	curState <= nextState;
   end

   always@(*) begin
      case(curState)
	IDLE: begin
	  nextState = (interrupt)? WAIT_HANDSHAKE : curState;
	end
	
	WAIT_HANDSHAKE: begin
	  nextState = (interrupt)? curState:
		      (frame_ready)? IDLE:
		      curState;
	end
      endcase // case (curState)
   end // always@ (*)

   assign GP_trigger = (curState == WAIT_HANDSHAKE);
   
endmodule
	
