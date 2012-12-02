
//Draws Circles
//First Word: 8 bits for command; 24 for color
//Second Word: [[31:22] -> x, [21: 12] -> y, [11:0] radius]

module CircleEngine(
		    input clk,
		    input rst,
		    output CE_ready,
		    input [23:0] CE_color,
		    input [31:0] CE_arguments,
		    input CE_color_valid,
		    input CE_arguments_valid,

		    input CE_trigger,

		    input af_full,
		    input wdf_full,

		    output [30:0] af_addr_din,
		    output reg af_wr_en,
		    output [127:0] wdf_din,
		    output reg [15:0] wdf_mask_din,
		    output reg wdf_wr_en,

		    input [31:0] CE_frame_base
		    );

   localparam IDLE = 4'b0000;
   localparam SETUP = 4'b0001;
   localparam CIRCLE_FUNCTION = 4'b0010;
   localparam PRINT4 = 4'b0011;
   localparam WRITE1_4 = 4'b0100;
   localparam WRITE2_4 = 4'b0101;
   localparam WHILE = 4'b0110;
   localparam PRINT8 = 4'b0111;
   localparam WRITE1_8 = 4'b1000;
   localparam WRITE2_8 = 4'b1001;
   
   reg [3:0] 			 curState, nextState;

   reg [9:0] 			 x0, y0, next_x0, next_y0;
   reg [9:0] 			 x, y, next_y;
   reg [11:0] 			 radius, next_radius;
   

   reg [11:0] 			 f;
   reg [11:0] 			 ddF_x, ddF_y;
   reg [11:0] 			 next_f, next_ddF_x, next_ddF_y;
   

   wire [31:0] 			 addr_div8;
   wire [5:0] 			 frameBuffer_addr;
   assign addr_div8 = CE_frame_base >> 3;
   assign frameBuffer_addr = addr_div8[24:19];

   reg [9:0] 			 y_addr, x_addr, next_y_addr, next_x_addr;
   
   assign af_addr_din = {6'b0, frameBuffer_addr, y_addr, x_addr[9:3], 2'b0};

   reg [23:0] 			 next_color, stored_color;
   wire [31:0] 			 padded_color;
   assign padded_color = {8'b0, stored_color};

   assign wdf_din = {padded_color, padded_color, 
		     padded_color, padded_color};
   
   


   wire [3:0] 			 mask;
   assign mask = x_addr[2:0];
   
  
   always@(posedge clk) begin
      if (rst) begin
	 curState <= IDLE;
	 x0 <= 0;
	 y0 <= 0;
	 radius <= 0;
	 f <= 0;
	 ddF_x <= 0;
	 ddF_y <= 0;
	 y <= 0;
	 stored_color <= 0;

	 x_addr <= 0;
	 y_addr <= 0;
	 
      end else begin
	 curState <= nextState;
	 x0 <= next_x0;
	 y0 <= next_y0;
	 radius <= next_radius;
	 f <= next_f;
	 ddF_x <= next_ddF_x;
	 ddF_y <= next_ddF_y;
	 y <= next_y;
	 stored_color <= next_color;
	 x_addr <= next_x_addr;
	 y_addr <= next_y_addr;
	 
      end
   end // always@ (posedge clk)
   
   reg [3:0] 			 count_4, count_8;
   reg [3:0] 			 next_count_4, next_count_8;
   
   always @(posedge clk) begin
      if (rst) begin
	 count_4 <= 0;
	 count_8 <= 0;
      end else begin
	 count_4 <= next_count_4;
	 count_8 <= next_count_8;
      end
   end
   
   always@(*) begin
      next_f = f;
      next_x0 = x0;
      next_y0 = y0;
      next_radius = radius;
      next_ddF_x = ddF_x;
      next_ddF_y = ddF_y;
      next_y = y;
      af_wr_en = 0;
      wdf_mask_din = 16'hFFFF;
      next_color = stored_color;
      next_x_addr = x_addr;
      next_y_addr = y_addr;

      next_count_4 = 0;
      next_count_8 = 0;

      wdf_wr_en = 0;
      af_wr_en = 0;
      
      case(curState)
	
	IDLE: begin

	   next_color = (CE_color_valid)? CE_color: stored_color;
	   nextState = (CE_color_valid)? SETUP: curState;
	end

	SETUP: begin
	   next_x0 = (CE_arguments_valid)? CE_arguments[31:22]: x0;
	   next_y0 = (CE_arguments_valid)? CE_arguments[21:12]: y0;
	   next_radius = (CE_arguments_valid)? CE_arguments[11:0] : radius;
	   nextState = (CE_trigger)? CIRCLE_FUNCTION: curState;
	end

	CIRCLE_FUNCTION: begin
	   next_f = 1 - radius;
	   next_ddF_x = 1;
	   next_ddF_y = ~(radius << 1) + 1;
	   next_y = radius;
	   nextState = PRINT4;
	end

	PRINT4: begin
	   next_count_4 = count_4;
	   case (count_4)
	     4'h0: begin
		next_x_addr = x0;
		next_y_addr = y0 + radius;
		nextState = WRITE1_4;
	     end

	     4'h1: begin
		next_x_addr = x0;
		next_y_addr = y0 - radius;
		nextState = WRITE1_4;
	     end

	     4'h2: begin
		next_x_addr = x0 + radius;
		next_y_addr = y0;
		nextState = WRITE1_4;
		
	     end

	     4'h3: begin
		next_x_addr = x0 - radius;
		next_y_addr = y0;
		nextState = WRITE1_4;
	     end

	     default: begin
		nextState = WHILE;
	     end
	   endcase // case (count_4)
	end // case: PRINT4

	WRITE1_4: begin
	   af_wr_en = 1'b1;
	   wdf_wr_en = 1'b1;
	   next_count_4 = count_4;
	   
	   if (!af_full & !wdf_full) begin
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
	      nextState = WRITE2_4;
	   end else 
	     nextState = curState;
	end // case: WRITE1_4

	WRITE2_4: begin
	   wdf_wr_en = 1'b1;
	   if (!af_full & !wdf_full) begin
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
	      nextState = PRINT4;
	      next_count_4 = count_4 + 1;
	   end else begin 
	      nextState = curState;
	      next_count_4 = count_4;
	      
	   end
	end // case: WRITE2_4

	WHILE: begin
	   if (x < y) begin
	      if ($signed(f) >= 0) begin
		 next_y = y - 1;
		 next_ddF_y = ddF_y + 2;
		 next_f = f + next_ddF_y;
	      end
	      next_ddF_x = ddF_x + 2;
	      next_f = next_f + next_ddF_x;
	      nextState = PRINT8;
	   end else
	     nextState = IDLE;
	end

	PRINT8: begin
	   next_count_8 = count_8;
	   
	   case(count_8)
	     4'h0: begin
		next_x_addr = x0 + x;
		next_y_addr = y0 + y;
		nextState = WRITE1_8;
	     end

	     4'h1: begin
		next_x_addr = x0 - x;
		next_y_addr = y0 + y;
		nextState = WRITE1_8;
	     end

	     4'h2: begin
		next_x_addr = x0 + x;
		next_y_addr = y0 - y;
		nextState = WRITE1_8;
	     end

	     4'h3: begin
		next_x_addr = x0 - x;
		next_y_addr = y0 - y;
		nextState = WRITE1_8;
	     end

	     4'h4: begin
		next_x_addr = x0 + y;
		next_y_addr = y0 + x;
		nextState = WRITE1_8;
	     end

	     4'h5: begin
		next_x_addr = x0 - y;
		next_y_addr = y0 + x;
		nextState = WRITE1_8;
	     end

	     4'h6: begin
		next_x_addr = x0 + y;
		next_y_addr = y0 - x;
		nextState = WRITE1_8;
	     end

	     4'h7: begin
		next_x_addr = x0 - y;
		next_y_addr = y0 - x;
		nextState = WRITE1_8;
	     end

	     default: begin
		nextState = WHILE;
	     end
	   endcase // case (PRINT8)
	   
	end // case: PRINT8

	WRITE1_8: begin
	   af_wr_en = 1'b1;
	   wdf_wr_en = 1'b1;
	   next_count_8 = count_8;
	   if (!af_full & !wdf_full) begin
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
	      nextState = WRITE2_8;
	   end else begin 
	      nextState = curState;
	   end
	end // case: WRITE8_4
   	
	WRITE2_8: begin
	   wdf_wr_en = 1'b1;
	   if (!af_full & !wdf_full) begin
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
	      nextState = PRINT8;
	      next_count_8 = count_8 + 1;
	   end else begin 
	      nextState = curState;
	      next_count_8 = count_8;
	   end
	end // case: WRITE2_4

	
	     
      endcase // case (curState)
      
   end // always@ (*)
   
   
   always@(posedge clk) begin
      if (rst || curState == CIRCLE_FUNCTION) begin
	 x <= 0;
      end else if (curState == WHILE) begin //FIX ME
	 x <= x + 1;
      end else begin
	 x <= x;
      end
   end
   
   assign CE_ready = (curState == IDLE) || (curState == SETUP);
   
  
   
endmodule
 
