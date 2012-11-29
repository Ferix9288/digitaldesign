/*
 * //Draws Circles
//First Word: 8 bits for command; 24 for color
//Second Word: [[31:22] -> x, [21: 12] -> y, [11:0] radius]

module CircleEngine(
		    input clk,
		    input rst,
		    output CE_ready,
		    input [23:0] CE_color,
		    input [19:0] CE_point,
		    input [11:0] CE_radius,
		    input CE_color_valid,
		    input CE_point_valid,

		    input CE_trigger,

		    input af_full,
		    input wdf_full,

		    output reg [30:0] af_addr_din,
		    output reg af_wr_en,
		    output [127:0] wdf_din,
		    output reg [15:0] wdf_mask_din,
		    output reg wdf_wr_en,

		    input [31:0] CE_frame_base
		    );

   localparam IDLE = 3'b000;
   localparam SETUP = 3'b001;
   localparam CIRCLE_FUNCTION = 3'b010;

   reg [2:0] 			 curState, nextState;

   reg [9:0] 			 x, y, x_init, y_init;

   reg [11:0] 			 radius;
   

   reg [11:0] 			 f;
   reg [11:0] 			 ddF_x, ddF_y;

   wire [31:0] 			 addr_div8;
   wire [5:0] 			 frameBuffer_addr;
   assign addr_div8 = CE_frame_base >> 3;
   assign frameBuffer_addr = addr_div8[24:19];

   assign af_addr_din = {6'b0, frameBuffer_addr, y, x[9:3], 2'b0};
  
     always@(posedge clk) begin
      if (rst) begin
	 curState <= IDLE;
      end else begin
	 curState <= nextState;
      end
   end

   always@(*) begin
      case(curState)
	IDLE: begin
	   af_wr_en = 0;
	   wdf_wr_en = 0;
	   nextState = (CE_color_valid)? SETUP: curState;
	end

	SETUP: begin
	   x_init = (CE_point_valid)? CE_point[31:22]: x_init;
	   y_init = (CE_point_valid)? CE_point[21:12]: y_init;
	   radius = (CE_point_valid)? CE_point[11:0] : radius;
	   nextState = (CE_trigger)? CIRCLE_FUNCTION: curState;
	end

	CIRCLE_FUNCTION: begin
	   f = 1 - radius;
	   ddF_x = 1;
	   ddF_y = radius << -2;
	   next_x = 0;
	   y = radius;

	    
	   //setPixel(x0, y0 + radius);
	   //setPixel(x0, y0 - radius);
	   //setPixel(x0 + radius, y0);
	   //setPixel(x0 - radius, y0);

	   
	   
	end

      endcase // case (curState)
      
   end // always@ (*)
   
	  
    

 
   
   


 
   
  printf("%4d %4d\n", x0, y0 + radius); 
  printf("%4d %4d\n", x0, y0 - radius); 
  printf("%4d %4d\n", x0 + radius, y0); 
  printf("%4d %4d\n", x0 - radius, y0); 

 
   
   
endmodule
*/
