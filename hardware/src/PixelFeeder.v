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

		    output frame_interrupt);

   // Hint: States
   localparam IDLE = 1'b0;
   localparam FETCH = 1'b1;
   localparam BUFFER_1_DDR = 6'h1;
   

   reg [31:0] 		   ignore_count;
   reg [11:0] 		   CountPixels;
        
    /**************************************************************************
    * YOUR CODE HERE: Write logic to keep the FIFO as full as possible.
     * 
     * 
    **************************************************************************/
   reg 			   curState, nextState;
   wire 		   feeder_full;
   reg [9:0] 		   x;
   reg [9:0] 		   y_Rows;

   wire 		   request_8pixels, fetch_pixel;
   wire 		   xOverFlow, yOverFlow;
   
   


   
   always @(posedge cpu_clk_g) begin
      
      if (rst) begin
	 curState <= IDLE;
	 CountPixels <= 0;
	 x <= 10'b0;
	 y_Rows <= 10'b0;
	 
      end else begin
	 curState <= nextState;
	 //both requesting and fetching a pixel at the same time
	 if (request_8pixels & fetch_pixel) begin
	    
	    CountPixels <= CountPixels + 7;
	    
	    x <= (xOverFlow)? 0: x + 8;
	    y_Rows <= (xOverFlow)? y_Rows + 1: y_Rows;

	    //just requesting 8 pixels
	 end else if (request_8pixels) begin 
	    
	    CountPixels <= CountPixels + 8;

	    x <= (xOverFlow)? 0: x + 8;
	    y_Rows <= (xOverFlow)? y_Rows + 1: y_Rows;
	  
	    //just fetching a pixel
	 end else if (fetch_pixel) begin 
	    
	    CountPixels <= CountPixels - 1;
	    
	    x <= x;
	    y_Rows <= y_Rows;
	    
	 end else begin
	    CountPixels <= CountPixels;
	    x <= x;
	    y_Rows <= y_Rows;
	 end
      end // else: !if(rst)
      
   end

   always @(*) begin
      case (curState)
	IDLE:
	  nextState =  (CountPixels >= 2040)? IDLE: FETCH;
	FETCH:
	  nextState =  (CountPixels >= 2040)? IDLE: curState;
      endcase
   end

   assign xOverFlow = (x == 10'd792);
   assign yOverFlow = (y_Rows == 10'd599);

   assign rdf_rd_en = CountPixels > 0; 
   assign af_wr_en = (curState == FETCH) & (!yOverFlow);

   assign request_8pixels = (af_wr_en & !af_full);
   assign fetch_pixel = (ignore_count == 0) & video_ready;
   


   /*Original MIPS address: {10'b0001_0000_01, y, x, 2'b0}
    *Shift said address by 3 ... becomes the following:
    *Note: only care about x[3] and above because incrementing x by 8
    */
   assign af_addr_din = {6'b0, 6'b000001, y_Rows, x[9:3], 2'b0};
   

   


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
   
   wire [35:0] chipscope_control;
   chipscope_icon icon(
		       .CONTROL0(chipscope_control)
		       );
   chipscope_ila ila(
   		     .CONTROL(chipscope_control),
		     .CLK(cpu_clk_g),
		     .TRIG0({rst, yOverFlow, af_full, video_ready, curState, rdf_valid, af_wr_en, video, CountPixels, x, y_Rows})
		     );
endmodule

