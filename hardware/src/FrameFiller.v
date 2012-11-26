module FrameFiller(//system:
  input             clk,
  input             rst,
  // fill control:
  input             valid,
  input [23:0]      color,
  // ddr2 fifo control:
  input             af_full,
  input             wdf_full,
  // ddr2 fifo outputs:
  output [127:0]    wdf_din,
  output            wdf_wr_en,
  output [30:0]     af_addr_din,
  output reg        af_wr_en,
  output reg [15:0]  wdf_mask_din,
  // handshaking:
  output             ready,
  
  input [31:0] FF_frame_base
  );

   //COLOR
   wire [31:0] color_word; 
   assign  color_word = {8'b0, color};        
   assign wdf_din = {color_word, color_word, color_word, color_word};

   //FRAME
   wire [5:0]  frameBuffer_addr;
   assign frameBuffer_addr = FF_frame_base[24:19] >> 3;

   //FSM
   localparam IDLE = 2'b00;
   localparam FILL_1 = 2'b01;
   localparam FILL_2 = 2'b10;
   
   reg [1:0] 	       curState, nextState;
   
   //X+Y Coordinates
   reg [9:0] 	       x_Cols, next_x;
   reg [9:0] 	       y_Rows, next_y;
   wire 	       xOverFlow, yOverFlow;   
   assign xOverFlow = (x_Cols == 10'd792);
   assign yOverFlow = (y_Rows == 10'd599);

   //REQUEST LOGIC
   assign wdf_wr_en = (!af_full) & (!wdf_full) & (curState != IDLE);
   wire 	       done;
   assign done = xOverFlow & yOverFlow;

   always@(posedge clk) begin
      if (rst || (curState == FILL_2 & nextState == IDLE)) begin
	 curState <= IDLE;
	 x_Cols <= 0;
	 y_Rows <= 0;
      end else begin
	 curState <= nextState;
	 x_Cols <= next_x;
	 y_Rows <= next_y;
      end
   end // always@ (posedge clk)

   //nextState Logic
   always@(*) begin
      case (curState)
	
	IDLE: begin
	   af_wr_en = 0;
	   wdf_mask_din = 16'hffff;
	   next_x = 0;
	   next_y = 0;
	   nextState = (valid)? FILL_1: IDLE;
	end

	//af_wr_en high
	//Move to Fill_2 if successful request
	FILL_1: begin
	   af_wr_en = !af_full & !wdf_full;
	   wdf_mask_din = 16'h0;
	   if (af_wr_en) begin
	      next_x = (xOverFlow)? 0: x_Cols + 8;
	      next_y = (xOverFlow)? y_Rows + 1: y_Rows;
	      nextState = FILL_2;
	   end else begin
	      next_x = x_Cols;
	      next_y = y_Rows;
	      nextState = curState;
	   end
	end

	//af_wr_en low
	//Only go back to Fill_1 if successfully wrote 2nd burst of pixels
	FILL_2: begin
	   af_wr_en = 0;
	   wdf_mask_din = 16'h0;
	   next_x = x_Cols;
	   next_y = y_Rows;
	   nextState = (done)? IDLE: 
		       (wdf_wr_en)? FILL_1: curState;
	end
	
	default: begin
	   af_wr_en = 0;
	   wdf_mask_din = 16'hffff;
	   next_x = x_Cols;
	   next_y = y_Rows;
	end
      endcase // case (curState)
   end
   
   assign af_addr_din = {6'b0, frameBuffer_addr, y_Rows, x_Cols[9:3], 2'b0};
   
   assign ready = (curState == IDLE);


   
   wire [35:0] chipscope_control;
   chipscope_icon icon(
		       .CONTROL0(chipscope_control)
		       );
   chipscope_ila ila(
   		     .CONTROL(chipscope_control),
		     .CLK(clk),
		     .TRIG0({rst, ready, done, af_full, wdf_full, curState, nextState, af_wr_en, wdf_wr_en, valid, x_Cols, y_Rows, wdf_mask_din})
		     ); //frameBuffer_addr was in btw af_wr_en and ic
   

endmodule
