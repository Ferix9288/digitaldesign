
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
  output reg            wdf_wr_en,
  //for testing
  output reg            steep,

  input [31:0] 		LE_frame_base
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
   reg [9:0] 		x, y, next_y;
   wire 		done;
   reg [15:0] 		error, next_error;

   reg [15:0] 		deltay, ABS_deltay;
   reg [15:0] 		deltax, ABS_deltax;
   
   reg [23:0] 		store_color, next_color;


   
   reg [2:0] 		mask;

   //--SET UP FOR LINE_FUNCTION STATE AND WRITE-- (Bresenham's Algorithm)
   //#define ABSOLUTE VALUES

   
   //wire 		steep;
   reg [9:0] 		ystep;

   wire [31:0] 		addr_div8;
   wire [5:0] 		frameBuffer_addr;
   assign addr_div8 = LE_frame_base >> 3;
   assign frameBuffer_addr = addr_div8[24:19];
   //--------------------------------------------------
   
   reg [9:0] 		temp;
   reg [9:0] 		next_x0, next_y0, next_x1, next_y1;
    
   assign wdf_din = {store_color, store_color, store_color, store_color};
   assign done = (x == x1);
   
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
      end else begin
	 curState <= nextState;
	 x0 <= next_x0;
	 y0 <= next_y0;
	 x1 <= next_x1;
	 y1 <= next_y1;
	 error <= next_error;
	 store_color <= next_color;
      end
   end

   //NEXT-STATE LOGIC
   always@(*) begin

      af_wr_en = 0;
      wdf_wr_en = 0;
      next_color = store_color;
      next_x0 = x0;
      next_y0 = y0;
      next_x1 = x1;
      next_y1 = y1;
      next_error = error;
      wdf_mask_din =  16'hFFFF;
      af_addr_din = {6'b0, frameBuffer_addr, y, x[9:3], 2'b0};

      
      case (curState)
	IDLE: begin
	   next_y = y;
	   next_color = (LE_color_valid)? LE_color[23:0]: store_color;
	   nextState = (LE_color_valid)? SET_UP: curState;
	end

	SET_UP: begin
	   next_y = y;
	   next_error = error;
	   next_x0 = (LE_point0_valid)? LE_point[19:10]: x0;
	   next_y0 = (LE_point0_valid)? LE_point[9:0]: y0;
	   next_x1 = (LE_point1_valid)? LE_point[19:10]: x1;
	   next_y1 = (LE_point1_valid)? LE_point[9:0]: y1;
	   nextState = (LE_trigger)? LINE_FUNCTION: curState;
	end
  
	LINE_FUNCTION: begin
	   deltay = y1 - y0;
	   ABS_deltay = ($signed(deltay) < 0)? (~deltay + 1) : deltay;
	   deltax = x1 - x0;
	   ABS_deltax = ($signed(deltax) < 0)? (~deltax + 1) : deltax;
	   steep = (ABS_deltay > ABS_deltax)? 1: 0;
	   
	   if (steep) begin
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
	   
	   deltax = next_x1 - next_x0;
	   deltay = next_y1 - next_y0;
	   ABS_deltay = ($signed(deltay) < 0)? (~deltay + 1) : deltay;
	   next_y =  next_y0;
	   ystep = (next_y0 < next_y1)? 1: -1;
	   next_error = deltax / 2;
	   nextState = WRITE_1;
	end
	
	//af_wr_en HIGH - first batch of 4 pixels
	WRITE_1: begin
	   af_wr_en = 1'b1;
	   wdf_wr_en = !af_full & !wdf_full;
	   
	   if (wdf_wr_en) begin
	      //REPLACE for loop by updating x SYNCHRONOUSLY
	      if (x <= x1) begin
		 if (steep) begin
		    //plot (y, x)
		    af_addr_din = {6'b0, frameBuffer_addr, y, x[9:3], 2'b0};
		    mask = x[2:0];
		 end else begin
		    //plot (x, y)
		    af_addr_din = {6'b0, frameBuffer_addr, x, y[9:3], 2'b0};
		    mask = y[2:0];
		 end
		 
		 next_error = $signed(error) - ABS_deltay;		 
		 if ($signed(next_error) < 0) begin
		    next_y = y + ystep;
		    next_error = $signed(next_error) + deltax;
		 end
	      end // if (x <= x1 && curState == WRITE_1)

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
	      next_y = y;
	      wdf_mask_din = 16'hFFFF;
	      nextState = curState;
	   end
	end

	//af_wr_en LOW - second batch of 4 pixels
	//only go back to WRITE_1 if sucessfully wrote data
	WRITE_2: begin
	   af_wr_en = 0;
	   wdf_wr_en = !af_full & !wdf_full;
	   next_y = next_y;
	   if (wdf_wr_en) begin
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
	      nextState = (done)? IDLE: WRITE_1;
	   end else begin
	      wdf_mask_din = 16'hFFFF;
	      nextState = (done)? IDLE: curState;
	   end // else: !if(wdf_wr_en)
	end // case: WRITE_2
	
      endcase // case (curState)
   end // always@ (*)

   //For x and y increments
   always@(posedge clk) begin
      if (rst || curState == LINE_FUNCTION) begin
	 x <= next_x0;
	 y <= next_y0;
      end else if (curState == WRITE_2 & wdf_wr_en) begin
	 y <= next_y;
	 x <= x + 1;
      end else begin
	 x <= x;
	 y <= y;
      end
   end // always@ (posedge clk)

   
    assign LE_ready = (curState == IDLE) || (curState == SET_UP);

   /*
    *
   wire [35:0] chipscope_control;
   chipscope_icon icon(
		       .CONTROL0(chipscope_control)
		       );
   chipscope_ila ila(
   		     .CONTROL(chipscope_control),
		     .CLK(clk),
		     .TRIG0({LE_frame_base, rst, rdf_valid, af_wr_en, wdf_wr_en, LE_ready, steep, LE_color_valid, LE_point0_valid, LE_point1_valid, LE_trigger, curState, nextState, error, x, y, x0, y0, x1, y1, store_color, af_addr_din, wdf_mask_din})
		     ); 
    */
   
endmodule
