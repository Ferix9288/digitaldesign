/* This module keeps a FIFO filled that then outputs to the DVI module. */

module PixelFeeder( //System:
                    input          cpu_clk_g,
                    input          clk50_g, // DVI Clock
                    input          rst,
                    //DDR2 FIFOS:
                    input          rdf_valid,
                    input          af_full,
                    input  [127:0] rdf_dout,
                    output         rdf_rd_en,
                    output         af_wr_en,
                    output [30:0]  af_addr_din,
                    // DVI module:
                    output [23:0]  video,
                    output         video_valid,
                    input          video_ready,

		    output reg frame_interrupt);

   // Hint: States
   localparam IDLE = 1'b0;
   localparam FETCH = 1'b1;
   //0x1040_0000
   localparam BUFFER1_DDR = 6'b000001;
   //0x1080_0000
   localparam BUFFER2_DDR = 6'b000010;
   

   reg [31:0] 		   ignore_count;
   reg [31:0] 		   CountPixels;
        
    /**************************************************************************
    * YOUR CODE HERE: Write logic to keep the FIFO as full as possible.
     * 
     * 
    **************************************************************************/
   reg 			   curState, nextState;
   wire 		   feeder_full;
   reg [9:0] 		   x_Cols;
   reg [9:0] 		   y_Rows;

   wire 		   request_8pixels, fetch_pixel;
   wire 		   xOverFlow, yOverFlow;
   reg [5:0]		   frameBuffer_addr;

   assign xOverFlow = (x_Cols == 10'd792);
   assign yOverFlow = (y_Rows == 10'd599);
   
   assign rdf_rd_en = 1'b1;
   assign af_wr_en = (ignore_count == 0) & (curState == FETCH) & (nextState == FETCH);

   assign request_8pixels = (af_wr_en & !af_full);
   assign fetch_pixel = (ignore_count == 0) & video_ready
			& (CountPixels != 0);

   //assign frame_interrupt = (when frame finished? half-way?)
			      
   always @(posedge cpu_clk_g) begin
      
      if (rst) begin
	 curState <= IDLE;
	 CountPixels <= 0;
	 x_Cols <= 10'b0;
	 y_Rows <= 10'b0;
	 frameBuffer_addr <= BUFFER1_DDR;
	 
      end else begin
	 curState <= nextState;
	 //both requesting and fetching a pixel at the same time
	 if (request_8pixels & fetch_pixel) begin
	    
	    CountPixels <= CountPixels + 7;

	    x_Cols <= (xOverFlow)? 0: x_Cols + 8;
	    
	    if (xOverFlow) begin
	       y_Rows <= (yOverFlow)? 0 : y_Rows + 1;
	       frame_interrupt <= (yOverFlow)? 1: 0;
	       // frameBuffer_addr <= (frameBuffer_addr == BUFFER1_DDR)?
	       //			   BUFFER2_DDR: BUFFER1_DDR;
	       
	    end else begin
	       y_Rows <= y_Rows;
	       frame_interrupt <= 0;
	       // frameBuffer_addr <= frameBuffer_addr;
	    end
	    
	    //just requesting 8 pixels
	 end else if (request_8pixels) begin 
	    
	    CountPixels <= CountPixels + 8;

	    x_Cols <= (xOverFlow)? 0: x_Cols + 8;
	    
	    if (xOverFlow) begin
	       y_Rows <= (yOverFlow)? 0 : y_Rows + 1;
	       frame_interrupt <= (yOverFlow)? 1: 0;
	       // frameBuffer_addr <= (frameBuffer_addr == BUFFER1_DDR)?
	       //			   BUFFER2_DDR: BUFFER1_DDR;

	    end else begin
	       y_Rows <= y_Rows;
	       frame_interrupt <= 0;
	       // frameBuffer_addr <= frameBuffer_addr;
	    end
	    
	  
	    //just fetching a pixel
	 end else if (fetch_pixel) begin 
	    
	    CountPixels <= CountPixels - 1;
	    
	    x_Cols <= x_Cols;
	    y_Rows <= y_Rows;
	    
	 end else begin
	    CountPixels <= CountPixels;
	    x_Cols <= x_Cols;
	    y_Rows <= y_Rows;
	 end
      end // else: !if(rst)
      
   end

   always @(*) begin
      case (curState)
	IDLE:
	  nextState =  (CountPixels >= 4000)? IDLE: FETCH;
	FETCH:
	  nextState =  (CountPixels >= 4000)? IDLE: curState;
      endcase
   end

   /*Original MIPS address: {10'b0001_0000_01, y, x, 2'b0}
    *Shift said address by 3 ... becomes the following:
    *Note: only care about x[3] and above because incrementing x by 8
    */
   assign af_addr_din = {6'b0, frameBuffer_addr, y_Rows, x_Cols[9:3], 2'b0};
   
    /* We drop the first frame to allow the buffer to fill with data from
    * DDR2. This gives alignment of the frame. */
    always @(posedge cpu_clk_g) begin
       if(rst)
            ignore_count <= 32'd480000; // 600*800 
       else if(ignore_count != 0 & video_ready)
            ignore_count <= ignore_count - 32'b1;
       else
            ignore_count <= ignore_count;
    end

    // FIFO to buffer the reads with a write width of 128 and read width of 32. We try to fetch blocks
    // until the FIFO is full.
   wire [31:0] feeder_dout;
   wire        feeder_empty;
   
    pixel_fifo feeder_fifo(
    	.rst(rst),
    	.wr_clk(cpu_clk_g),
    	.rd_clk(clk50_g),
    	.din(rdf_dout),
    	.wr_en(rdf_valid),
    	.rd_en(video_ready & ignore_count == 0),
    	.dout(feeder_dout),
    	.full(feeder_full),
    	.empty(feeder_empty));

   
   assign video = feeder_dout[23:0];
   assign video_valid = 1'b1;
   
   
   /*
    * 
    wire [35:0] chipscope_control;
   chipscope_icon icon(
		       .CONTROL0(chipscope_control)
		       );
   chipscope_ila ila(
   		     .CONTROL(chipscope_control),
		     .CLK(cpu_clk_g),
		     .TRIG0({ rst, yOverFlow, af_full, video_ready, curState, rdf_valid, af_wr_en, ignore_count, video, CountPixels, x_Cols, y_Rows})
		     ); //frameBuffer_addr was in btw af_wr_en and ic
    */
   
   
    
endmodule

