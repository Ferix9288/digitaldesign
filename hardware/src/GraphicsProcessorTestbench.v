`timescale 1ns/1ps

module GraphicsProcessorTestbench();

    reg Clock, Reset;

    parameter HalfCycle = 5;
    parameter Cycle = 2*HalfCycle;
    parameter ClockFreq = 50_000_000;

    initial Clock = 0;
    always #(HalfCycle) Clock <= ~Clock;
    

   reg 	rdf_valid;
   reg 	af_full;
   reg 	wdf_full;
   
   reg [127:0] rdf_dout;
   wire        rdf_rd_en;
   wire        af_wr_en;
   wire [30:0] af_addr_din;
   wire        ready;
   
   wire        FF_ready;
   wire        FF_valid;
   wire [23:0] FF_color;
   
   wire	       LE_ready;
   wire [31:0] LE_color;
   wire [19:0] LE_point;
   wire        LE_color_valid;
   wire        LE_point0_valid;
   wire        LE_point1_valid;
   
   wire        LE_trigger;
   
   wire [31:0] 	    LE_frame;
   wire [31:0] 	    FF_frame;
   
   reg [31:0] 	    gp_code;
   reg [31:0] 	    gp_frame;
   reg 		    gp_valid;
   
   
   GraphicsProcessor DUT(	.clk(Clock),
    				.rst(Reset),
    				.rdf_valid(rdf_valid),
    				.af_full(af_full),
    				.rdf_dout(rdf_dout),
    				.rdf_rd_en(rdf_rd_en),
    				.af_wr_en(af_wr_en),
    				.af_addr_din(af_addr_din),
    				//line engine control signals
    				.LE_ready(LE_ready),
    				.LE_color(LE_color),
    				.LE_point(LE_point),
    				.LE_color_valid(LE_color_valid),
    				.LE_point0_valid(LE_point0_valid),
				.LE_point1_valid(LE_point1_valid),
    				.LE_trigger(LE_trigger),
    				.LE_frame(LE_frame),
    				//frame filler control signals
    				.FF_ready(FF_ready),
    				.FF_valid(FF_valid),
    				.FF_color(FF_color),
    				.FF_frame(FF_frame),
      
    				.GP_CODE(gp_code),
    				.GP_FRAME(gp_frame),
    				.GP_valid(gp_valid),
				.GP_interrupt(gp_interrupt)
				);

   //ADD FRAME FILLER READY AND LE READY MODULES

   wire [127:0]     FF_wdf_din;
   wire 	    FF_wdf_wr_en;
   wire [30:0] 	    FF_af_addr_din;
   wire [15:0] 	    FF_wdf_mask_din;
   wire 	    FF_af_wr_en;
   
   FrameFiller Fill( .clk(Clock),
		     .rst(Reset),
		     .valid(FF_valid),
		     .color(FF_color),
		     .af_full(af_full),
		     .wdf_full(wdf_full),
		     .wdf_din(FF_wdf_din),
		     .wdf_wr_en(FF_wdf_wr_en),
		     .af_addr_din(FF_af_addr_din),
		     .af_wr_en(FF_af_wr_en),
		     .wdf_mask_din(FF_wdf_mask_din),
		     .ready(FF_ready),
		     .FF_frame_base(FF_frame));

   wire [30:0] 	    LE_af_addr_din;
   wire 	    LE_af_wr_en, LE_wdf_wr_en;
   wire [127:0]     LE_wdf_din;
   wire [15:0] 	    LE_wdf_mask_din;
   
   LineEngine Line( .clk(Clock),
		    .rst(Reset),
		    .LE_ready(LE_ready),
		    .LE_color(LE_color),
		    .LE_point(LE_point),
		    .LE_color_valid(LE_color_valid),
		    .LE_point0_valid(LE_point0_valid),
		    .LE_point1_valid(LE_point1_valid),
		    .LE_trigger(LE_trigger),
		    .LE_frame_base(LE_frame),
		    .af_full(af_full),
		    .wdf_full(wdf_full),
		    .af_addr_din(LE_af_addr_din),
		    .af_wr_en(LE_af_wr_en),
		    .wdf_din(LE_wdf_din),
		    .wdf_mask_din(LE_wdf_mask_din),
		    .wdf_wr_en(LE_wdf_wr_en));
   
		    
   
   initial begin
      
      //TODO put your code here
      af_full = 0;
      wdf_full = 0;
      rdf_valid = 0;
      Reset = 1;
      #(10*Cycle);
      Reset = 0;
      gp_code = 32'h20000;
      gp_frame = 32'h10400000;
      gp_valid = 1;
      #(Cycle);
      gp_valid = 0;
      rdf_valid = 0;
      rdf_dout = {32'h00000000, 32'h00AA00BB, 32'h01230124, 32'h02ff0000};
      #(10*Cycle);
      rdf_valid = 1;
      #(Cycle);
      rdf_dout = {32'h001A002B, 32'h00100020, 32'h020000FF, 32'h01000000};
      #(Cycle);
      rdf_dout = {32'ha281902a, 32'h00000000, 32'haaaabbbb, 32'hddeaff12};
      rdf_valid = 0;
      af_full = 1;
      #(Cycle);
      #(Cycle);
      #(5*Cycle);
      af_full = 0;
      rdf_valid = 1;
      while (!gp_interrupt) #(Cycle);

      #(10*Cycle);
      
   
      $finish();
   end

   
endmodule
