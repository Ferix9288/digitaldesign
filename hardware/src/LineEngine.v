module LineEngine(
  input                 clk,
  input                 rst,
  output                LE_ready,
  // 8-bit each for RGB, and 8 bits zeros at the top
  input [31:0]          LE_color,
  input [19:0]          LE_point,
  // Valid signals for the inputs
  input                 LE_color_valid,
  input                 LE_point0_valid,
  input                 LE_point1_valid,
		  
  //input                 LE_x0_valid,
  //input                 LE_y0_valid,
  //input                 LE_x1_valid,
  //input                 LE_y1_valid,
  // Trigger signal - line engine should
  // Start drawing the line
  input                 LE_trigger,
  // FIFO connections
  input                 af_full,
  input                 wdf_full,

  output reg [30:0]     af_addr_din,
  output reg            af_wr_en,
  output [127:0]        wdf_din,
  output reg [15:0]     wdf_mask_din,
  output                wdf_wr_en,
  //for testing
  output reg               steep,

  input [31:0] 		LE_frame_base,
		  input pixel_af_wr_en,
		  input [3:0] fifo_access,
		  input line_reserved,
		  input fifo_af_full,
		  input fifo_wdf_full
);

   //FSM for LE to operate (6 states)
   //Note: Need two write stages (each writing 4 pixels)

   localparam IDLE = 3'b000;
   localparam SET_UP = 3'b001;
   localparam LINE_FUNCTION = 3'b010;
   localparam WRITE_1 = 3'b011;
   localparam WRITE_2 = 3'b100;
   
   reg [2:0] 		curState, nextState;
   reg [9:0] 		x0, y0, x1, y1;
   reg [9:0] 		x, y, next_y, next_x;
   wire 		done;
   reg [15:0] 		error, next_error, temp_error;

   reg [15:0] 		next_deltay, deltay, next_ABS_deltay, ABS_deltay;
   reg [15:0] 		next_deltax, deltax, next_ABS_deltax, ABS_deltax;
   
   reg [23:0] 		store_color, next_color;

   reg [2:0] 		mask;
   reg [31:0] 		next_LE_Frame, LE_Frame;
   

   //--SET UP FOR LINE_FUNCTION STATE AND WRITE-- (Bresenham's Algorithm)
   //#define ABSOLUTE VALUES

   
   //wire 		steep;
   reg [9:0] 		ystep, next_ystep;

   wire [31:0] 		addr_div8;
   wire [5:0] 		frameBuffer_addr;
   assign addr_div8 = LE_Frame >> 3;
   assign frameBuffer_addr = addr_div8[24:19];
   //--------------------------------------------------
   
   reg [9:0] 		temp;
   reg [9:0] 		next_x0, next_y0, next_x1, next_y1;

   wire [31:0] 		color_word;
   assign color_word = {8'b0, store_color};
   assign wdf_din = {color_word, color_word, color_word, color_word};
   assign done = (x == x1);

   /*
    * af_addr_din = (steep)? {6'b0, frameBuffer_addr, x, y[9:3], 2'b0}:
			{6'b0, frameBuffer_addr, y, x[9:3], 2'b0};
    */
   reg 		next_steep;

   //Current state and point updates
   always@(posedge clk) begin
      if (rst) begin
	 curState <= IDLE;
	 x0 <= 0;
	 y0 <= 0;
	 x1 <= 0;
	 y1 <= 0;
	 error <= 0;
	 store_color <= 0;
	 steep <= 0;
	 deltax <= 0;
	 deltay <= 0;
	 ABS_deltax <= 0;
	 ABS_deltay <= 0;
	 ystep <= 0;
	 af_addr_din <= 0;
	 mask <= 0;
	 LE_Frame <= 0;
	 
      end else begin // if (rst)
	 af_addr_din <= (next_steep)? 
			{6'b0, frameBuffer_addr, next_x, next_y[9:3], 2'b0}:
			{6'b0, frameBuffer_addr, next_y, next_x[9:3], 2'b0};
	 mask <= (next_steep)? next_y[2:0] : next_x[2:0];

	 curState <= nextState;
	 x0 <= next_x0;
	 y0 <= next_y0;
	 x1 <= next_x1;
	 y1 <= next_y1;
	 error <= next_error;
	 store_color <= next_color;
	 steep <= next_steep;
	 deltax <= next_deltax;
	 deltay <= next_deltay;
	 ABS_deltax <= next_ABS_deltax;	 
	 ABS_deltay <= next_ABS_deltay;
	 ystep <= next_ystep;
	 LE_Frame <= next_LE_Frame;
	 
	 
	 
	 
      end
   end

   assign wdf_wr_en = (curState == WRITE_1 || curState == WRITE_2);
   
   //NEXT-STATE LOGIC
   always@(*) begin

      af_wr_en = 0;
      next_color = store_color;
      next_x0 = x0;
      next_y0 = y0;
      next_x1 = x1;
      next_y1 = y1;
      next_y = y;
      next_error = error;
      wdf_mask_din =  16'hFFFF;
      next_steep = steep;
      temp_error = error;
      next_deltax = deltax;
      next_deltay = deltay;
      next_ABS_deltax = ABS_deltax;
      next_ABS_deltay = ABS_deltay;
      next_ystep = ystep;
      next_x = x;
      next_LE_Frame = LE_Frame;
      
      
      case (curState)
	IDLE: begin
	   next_color = (LE_color_valid)? LE_color[23:0]: store_color;
	   nextState = (LE_color_valid)? SET_UP: curState;
	end

	SET_UP: begin
	   next_x0 = (LE_point0_valid)? LE_point[19:10]: x0;
	   next_y0 = (LE_point0_valid)? LE_point[9:0]: y0;
	   next_x1 = (LE_point1_valid)? LE_point[19:10]: x1;
	   next_y1 = (LE_point1_valid)? LE_point[9:0]: y1;
	   next_LE_Frame = (LE_trigger)? LE_frame_base: LE_Frame;
	   nextState = (LE_trigger)? LINE_FUNCTION: curState;	   
	end
  
	LINE_FUNCTION: begin
	   next_deltay = y1 - y0;
	   next_ABS_deltay = ($signed(next_deltay) < 0)? 
			     (~next_deltay + 1) : next_deltay;
	   next_deltax = x1 - x0;
	   next_ABS_deltax = ($signed(next_deltax) < 0)? 
			     (~next_deltax + 1) :  next_deltax;
	   
	   next_steep = (next_ABS_deltay > next_ABS_deltax)? 1: 0;
	   
	   if (next_steep) begin
	      //SWAP x0, y0
	      next_x0 = y0;
	      next_y0 = x0;
	      //SWAP x1, y1
	      next_x1 = y1;
	      next_y1 = x1;
	   end else begin
	      next_x0 = x0;
	      next_y0 = y0;
	      next_x1 = x1;
	      next_y1 = y1;
	   end
	   
	   if (next_x0 > next_x1) begin
	      //SWAP x0, x1
	      temp = next_x0;
	      next_x0 = next_x1;
	      next_x1 = temp;
	      //SWAP y0, y1
	      temp = next_y0;
	      next_y0 = next_y1;
	      next_y1 = temp;
	   end 
	   
	   next_deltax = next_x1 - next_x0;
	   next_deltay = next_y1 - next_y0;
	   next_ABS_deltay = ($signed(next_deltay) < 0)?
			     (~next_deltay + 1) : next_deltay;
	   next_y =  next_y0;
	   next_ystep = /*(next_y0 < next_y1)?*/ ($signed(next_deltay) > 0)? 1: -1;
	   next_error = next_deltax / 2;
	   nextState = WRITE_1;
	end
	
	//af_wr_en HIGH - first batch of 4 pixels
	WRITE_1: begin
	   af_wr_en = 1'b1;
	   if (!af_full & !wdf_full) begin
	      //logic for wdf_mask_din  
	      case (mask)
		4'h0:
		  wdf_mask_din = 16'h0FFF;
		4'h1:
		  wdf_mask_din = 16'hF0FF;
		4'h2:
		  wdf_mask_din = 16'hFF0F;
		4'h3:
		  wdf_mask_din = 16'hFFF0;
		default:
		  wdf_mask_din = 16'hFFFF;
	      endcase // case (mask)
	      nextState = WRITE_2;
	   end else begin // if (wdf_wr_en)
	      nextState = curState;
	   end
	end

	//af_wr_en LOW - second batch of 4 pixels
	//only go back to WRITE_1 if sucessfully wrote data
	WRITE_2: begin
	   af_wr_en = 0;
	  // if (!af_full & !wdf_full) begin
	   temp_error = error - ABS_deltay;
	   if (!wdf_full) begin
	      next_x = x + 1;
	      if ($signed(temp_error) < 0) begin
		 next_y = y + ystep;
		 next_error = temp_error + deltax;
	      end else begin
		 next_error = temp_error;
	      end
	      
	      case (mask)
		4'h4:
		  wdf_mask_din = 16'h0FFF;
		4'h5:
		  wdf_mask_din = 16'hF0FF;
		4'h6:
		  wdf_mask_din = 16'hFF0F;
		4'h7:
		  wdf_mask_din = 16'hFFF0;
		default:
		  wdf_mask_din = 16'hFFFF;
	      endcase // case (mask)
	   end // if (!wdf_full)
	   nextState = (!wdf_full)? 
		       ((done)? IDLE : WRITE_1):
		       curState;
	   
	end // case: WRITE_2
   
      endcase // case (curState)
   end // always@ (*)

   //For x and y increments
   always@(posedge clk) begin
      if (rst) begin
	 x <= 0;
	 y <= 0;
      end else if (curState == LINE_FUNCTION) begin
	 x <= next_x0;
	 y <= next_y0;
      end else if (curState == WRITE_2) begin
	 x <= next_x;
	 y <= next_y;
      end else begin
	 x <= x;
	 y <= y;
      end
   end // always@ (posedge clk)

   
    assign LE_ready = (curState == IDLE) || (curState == SET_UP);


   /*
    * wire [35:0] chipscope_control;
   chipscope_icon icon(
		       .CONTROL0(chipscope_control)
		       );
   chipscope_ila ila(
   		     .CONTROL(chipscope_control),
		     .CLK(clk),
		     .TRIG0({fifo_wdf_full, fifo_af_full, fifo_access, line_reserved, pixel_af_wr_en, wdf_full, af_full, ABS_deltay, deltay, deltax, rst, af_wr_en, wdf_wr_en, LE_ready, steep, LE_color_valid, LE_point0_valid, LE_point1_valid, LE_trigger, curState, nextState, error, x, y, x0, y0, x1, y1, store_color, af_addr_din, wdf_mask_din})
		     ); 
    */
   
endmodule
