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
   reg [10:0] 		   CountPixels;
   

    /**************************************************************************
    * YOUR CODE HERE: Write logic to keep the FIFO as full as possible.
     * 
     * 
    **************************************************************************/
   /*
    * reg 			   curState, nextState;
   wire 	feeder_full;
   
   
   always @(posedge cpu_clk_g) begin
      if (rst) begin
	 curState <= IDLE;
	 CountPixels <= 0;
      end else begin
	 curState <= nextState;
	 if (rdf_valid)
	   CountPixels <= CountPixels - 8;
	 else if (af_wr_en)
	   CountPixels <= CountPixels + 8;
	 else
	   CountPixels <= CountPixels;
      end
   end

   always @(*) begin
      case (curState)
	IDLE:
	  nextState =  (CountPixels > 2040)? IDLE: FETCH;
	FETCH:
	  nextState =  (CountPixels > 2040)? IDLE: curState;
      endcase
    end

   assign rdf_rd_en = (curState == FETCH);
   assign af_wr_en = (curState == FETCH);
   assign af_addr_din = {3'b001, 28'h1004234};
    */
   


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

endmodule

