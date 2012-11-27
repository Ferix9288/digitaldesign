
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
  output                steep,

  input [31:0] 		LE_frame_base
);

   //FSM for LE to operate (6 states)
   //Note: Need two write stages (each writing 4 pixels)

   localparam IDLE = 3'b000;
   localparam SET_UP = 3'b001;
   localparam LINE_FUNCTION = 3'b010;
   localparam WRITE_1 = 3'b011;
   localparam WRITE_2 = 3'b100;
   
   reg [2:0] 		curState, nextState, prevState;
   reg [9:0] 		x0_init, y0_init, x1_init, y1_init;
   reg [9:0] 		x0, y0, x1, y1;
   reg [10:0] 		x, y;
   wire 		done;
   reg [15:0] 		error;

   //Current state and point updates
   always@(posedge clk) begin
      if (rst) begin
	 curState <= IDLE;
	 prevState <= IDLE;

	 
      end else begin
	 prevState <= curState;
	 curState <= nextState;

	 
      end
   end

   assign wdf_din = {LE_color, LE_color, LE_color, LE_color};
   assign done = (x > x1);
   
   reg [2:0] 		mask;

   //--SET UP FOR LINE_FUNCTION STATE AND WRITE-- (Bresenham's Algorithm)
   //#define ABSOLUTE VALUES
   wire [15:0] 		deltay_init, ABS_deltay_init;
   assign deltay_init = y1_init - y0_init;
   assign ABS_deltay_init = ($signed(deltay_init) < 0)? (~deltay_init + 1) : deltay_init;
   reg [15:0] 		deltay, ABS_deltay;
   
   
   wire [15:0] 		deltax_init, ABS_deltax_init;
   assign deltax_init = x1_init - x0_init;
   assign ABS_deltax_init = ($signed(deltax_init) < 0)? (~deltax_init + 1) : deltax_init;
   reg [15:0] 		deltax;
   
   wire [15:0] 		error_init;
   
   //wire 		steep;
   assign steep = (ABS_deltay_init > ABS_deltax_init)? 1: 0;
   reg [9:0] 		ystep;

   wire [5:0] 		frameBuffer_addr;
   assign frameBuffer_addr = LE_frame_base[24:19] >> 3;
   //--------------------------------------------------
   
   reg [9:0] 		temp;
   
   //NEXT-STATE LOGIC
   always@(*) begin
      
      case (curState)
	IDLE: begin
	   af_wr_en = 0;
	   wdf_wr_en = 0;
	   nextState = (LE_color_valid)? SET_UP: curState;
	   
	end

	SET_UP: begin
	   x0_init = (LE_point0_valid)? LE_point[19:10]: x0_init;
	   y0_init = (LE_point0_valid)? LE_point[9:0]: y0_init;
	   x1_init = (LE_point1_valid)? LE_point[19:10]: x1_init;
	   y1_init = (LE_point1_valid)? LE_point[9:0]: y1_init;
	   nextState = (LE_trigger)? LINE_FUNCTION: curState;
	end

	LINE_FUNCTION: begin
	   if (steep) begin
	      //SWAP x0, y0
	      x0 = y0_init;
	      y0 = x0_init;
	      //SWAP x1, y1
	      x1 = y1_init;
	      y1 = x1_init;
	   end else begin
	      x0 = x0_init;
	      y0 = y0_init;
	      x1 = x1_init;
	      y1 = y1_init;
	   end
	   
	   if (x0 > x1) begin
	      //SWAP x0, x1
	      temp = x0;
	      x0 = x1;
	      x1 = temp;
	      //SWAP y0, y1
	      temp = y0;
	      y0 = y1;
	      y1 = temp;
	   end else begin
	      x0 = x0;
	      y0 = y0;
	      x1 = x1;
	      y1 = y1;
	   end // else: !if(x0 > x1)
	   
	   deltax = x1 - x0;
	   deltay = y1 - y0;
	   ABS_deltay = ($signed(deltay) < 0)? (~deltay + 1) : deltay;
	   y =  y0;
	   ystep = (y0 < y1)? 1: -1;
	   error = deltax / 2;
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
		 
		 error = $signed(error) - ABS_deltay;		 
		 if ($signed(error) < 0) begin
		    y = y + ystep;
		    error = $signed(error) + deltax;
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
	      error = error;
	      y = y;
	      wdf_mask_din = 16'hFFFF;
	      nextState = curState;
	   end

	   
	end

	//af_wr_en LOW - second batch of 4 pixels
	//only go back to WRITE_1 if sucessfully wrote data
	WRITE_2: begin
	   af_wr_en = 0;
	   wdf_wr_en = !af_full & !wdf_full;
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
	 x <= x0;
      end else if (curState == WRITE_1 & wdf_wr_en) begin
	 x <= x + 1;
      end else begin
	 x <= x;
      end
   end // always@ (posedge clk)

  
      
   
   assign LE_ready = (curState == IDLE) || (curState == SET_UP);

   
endmodule
