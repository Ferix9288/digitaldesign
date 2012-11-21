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
  output            af_wr_en,
  output [15:0]     wdf_mask_din,
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
   localparam IDLE = 1'b0;
   localparam FILLING = 1'b1;
   reg 	       curState, nextState;
   
   //X+Y Coordinates
   reg [9:0] 	       x_Cols;
   reg [9:0] 	       y_Rows;
   wire 	       xOverFlow, yOverFlow;   
   assign xOverFlow = (x_Cols == 10'd792);
   assign yOverFlow = (y_Rows == 10'd599);

   //REQUEST LOGIC
   assign wdf_wr_en = (!af_full) & (!wdf_full) & (curState == FILLING);
   assign af_wr_en = (!af_full) & (!wdf_full) & (curState == FILLING);
  
   always@(posedge clk) begin
      if (rst || (curState == FILLING & nextState == IDLE)) begin
	 curState <= IDLE;
	 x_Cols <= 0;
	 y_Rows <= 0;
      end else begin
	 curState <= nextState;
	 if (af_wr_en) begin
	    x_Cols <= (xOverFlow)? 0: x_Cols + 8;
	    y_Rows <= (xOverFlow)? y_Rows + 1: y_Rows;
	 end else begin
	    x_Cols <= x_Cols;
	    y_Rows <= y_Rows;
	 end
      end
   end // always@ (posedge clk)

   //nextState Logic
   always@(*) begin
      case (curState)
	
	IDLE:
	  nextState = (valid)? FILLING: IDLE;
	
	FILLING: begin
	   if (xOverFlow & yOverFlow) begin
	      nextState = IDLE;
	   end else begin
	      nextState = FILLING;
	   end
	end
	   
      endcase // case (curState)
   end
   
   assign af_addr_din = {6'b0, frameBuffer_addr, y_Rows, x_Cols[9:3], 2'b0};
   
   assign ready = (curState == IDLE);
   

endmodule
