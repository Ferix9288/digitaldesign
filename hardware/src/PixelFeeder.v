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

   reg [31:0] 		   ignore_count;
   reg [11:0] 		   CountPixels;
   reg [30:0] 		   frameCount;
   
   
    /**************************************************************************
    * YOUR CODE HERE: Write logic to keep the FIFO as full as possible.
     * 
     * 
    **************************************************************************/
   reg 			   curState, nextState;
   wire 		   feeder_full;
   
   
   always @(posedge cpu_clk_g) begin
      if (rst) begin
	 curState <= IDLE;
	 CountPixels <= 0;
	 frameCount <= 31'h08_0000;	 
      end else begin
	 curState <= nextState;
	 if (rdf_valid & video_ready & af_wr_en) begin
	    CountPixels <= CountPixels;
	    frameCount <= frameCount + 8;
	 end else if (af_wr_en) begin
	    frameCount <= frameCount + 8;
	    CountPixels <= CountPixels + 8;
	 end else if (rdf_valid & video_ready) begin
	    CountPixels <= CountPixels - 8;
	 end else begin
	   CountPixels <= CountPixels;
	 end
      end
   end

   always @(*) begin
      case (curState)
	IDLE:
	  nextState =  (CountPixels > 2048)? IDLE: FETCH;
	FETCH:
	  nextState =  (CountPixels > 2048)? IDLE: curState;
      endcase
   end

   assign rdf_rd_en = (curState == FETCH);
   assign af_wr_en = (curState == FETCH);
   assign af_addr_din = frameCount;
   


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
		     .TRIG0({rst, CountPixels, curState, rdf_valid, af_wr_en, af_addr_din})
		     );
endmodule

