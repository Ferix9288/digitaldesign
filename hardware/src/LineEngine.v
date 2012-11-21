
module LineEngine(
  input                 clk,
  input                 rst,
  output                LE_ready,
  // 8-bit each for RGB, and 8 bits zeros at the top
  input [31:0]          LE_color,
  input [9:0]           LE_point,
  // Valid signals for the inputs
  input                 LE_color_valid,
  input                 LE_x0_valid,
  input                 LE_y0_valid,
  input                 LE_x1_valid,
  input                 LE_y1_valid,
  // Trigger signal - line engine should
  // Start drawing the line
  input                 LE_trigger,
  // FIFO connections
  input                 af_full,
  input                 wdf_full,
  
  output [30:0]         af_addr_din,
  output                af_wr_en,
  output [127:0]        wdf_din,
  output [15:0]         wdf_mask_din,
  output                wdf_wr_en,

  input [31:0] 		LE_frame_base
);


   // Implement Bresenham's line drawing algorithm here!

   //X + Y Coordinates
   reg [9:0] 		x0, y0, x1, y1;

   //#define swap(x,y)
   
   //#define ABS(x) ( (x < 0) ? -x : x)
   wire [9:0] 	       deltay, ABS_deltay;
   assign deltay = y1 - y0;
   assign ABS_deltay = ($signed(deltay) < 0)? (~deltay + 1) : deltay;
     
   /*
    * //#define ABS(x) ( (x < 0) ? -x : x)
   wire [9:0] 	       ABS_x;
   assign ABS_x = ($signed(x_Cols) < 0)? (~x_Cols + 1) : x_Cols;
    */
     
   
   // Remove these when you implement this module:
   assign af_wr_en = 1'b0;
   assign wdf_wr_en = 1'b0;
   assign LE_ready = 1'b1;

endmodule
