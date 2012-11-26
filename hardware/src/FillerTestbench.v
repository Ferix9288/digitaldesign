//----------------------------------------------------------------------
// Module: FillerTestbench.v
// This module tests the frame filler by
// filling a frame.
//----------------------------------------------------------------------

`define MODELSIM 1
`timescale 1ns / 1ps

module FillerTestbench();

   parameter HalfCycle = 5;
   localparam Cycle = 2*HalfCycle;	
   reg	Clock, Reset;
   initial Clock	= 0;	
   always #(HalfCycle) Clock= ~Clock;

   reg 	filler_valid;
   reg [23:0] filler_color;
   reg 	      af_full;
   reg 	      wdf_full;

   wire [127:0]       wdf_din;
   wire 	      wdf_wr_en;
   wire [30:0]	      af_addr_din;
   wire 	      af_wr_en;
   wire [15:0] 	      wdf_mask_din;
   wire 	      filler_ready;

   wire [31:0] 	      FF_frame_base;
   assign FF_frame_base = 32'h10400000;
   
   
   FrameFiller Filler(.clk(Clock),
		      .rst(Reset),
		      .valid(filler_valid),
		      .color(filler_color),
		      .af_full(af_full),
		      .wdf_full(wdf_full),
		      .wdf_din(wdf_din),
		      .wdf_wr_en(wdf_wr_en),
		      .af_addr_din(af_addr_din),
		      .af_wr_en(af_wr_en),
		      .wdf_mask_din(wdf_mask_din),
		      .ready(filler_ready),
		      .FF_frame_base(FF_frame_base));

   initial begin
      Reset = 1;
      filler_valid = 0;
      filler_color = 24'hffffff;
      af_full = 0;
      wdf_full = 0;
      #(10*Cycle);
      Reset = 0;
      filler_valid = 1;
      #Cycle;
      filler_valid = 0;
      
      while (!filler_ready) #(Cycle);
      $finish();
      
   end // initial begin

endmodule // FillerTestbench


      
   
   
