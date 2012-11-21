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
  output            ready,
  
  input [31:0] FF_frame_base
  );

   wire        colorWord [31:0];
   reg [30:0]  increment;
   
   /*
    * assign colorWord = {8'b0, color};
   assign wdf_din = {colorWord, colorWord, colorWord, colorWord};
    */
   assign wdf_wr_en = (!af_full) & (!wdf_full);
   assign af_wr_en = (!af_full) & (!wdf_full);

   /*
    * always@(posedge clk) begin
      if (rst) begin
	 increment <= 0;
      else
	if (af_wr_en)
    */
	
   
    
   //Your code goes here. GL HF DD DS

   // Remove these when you implement the frame filler:

   assign ready     = 1'b1;





endmodule
