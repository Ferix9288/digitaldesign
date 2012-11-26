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
   reg [127:0] rdf_dout;
   wire        rdf_rd_en;
   wire        af_wr_en;
   wire [30:0] af_addr_din;
   wire        ready;
   
   reg 	       FF_ready;
   wire        FF_valid;
   wire [23:0] FF_color;
   
   reg 	       LE_ready;
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
   
   initial begin
      
      //TODO put your code here
      LE_ready = 1;
      FF_ready = 1;
      af_full = 0;
      rdf_valid = 0;
      Reset = 1;
      #(10*Cycle);
      Reset = 0;
      gp_code = 32'h20000;
      gp_frame = 32'h10400000;
      gp_valid = 1;
      #(Cycle);
      gp_valid = 0;
      rdf_valid = 1;
      
      rdf_dout = {32'h00000000, 32'h00AA00BB, 32'h01230124, 32'h02ff0000};
      #(Cycle);
      rdf_dout = {32'h001A002B, 32'h00100020, 32'h020000FF, 32'h01000000};

      while (!gp_interrupt) #(Cycle);

      #(10*Cycle);
      
   
      $finish();
   end

   
endmodule
