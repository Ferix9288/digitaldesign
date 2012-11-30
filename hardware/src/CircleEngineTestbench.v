//----------------------------------------------------------------------
// Module: CircleEngineTestbench.v
// This module tests the circle engine by
// drawing a few example circles
//-------------

`define MODELSIM 1
`timescale 1ns / 1ps

module CircleEngineTestbench();
   
   parameter HalfCycle = 5;
   localparam Cycle = 2*HalfCycle;	
   reg	Clock;
   initial Clock	= 0;	
   always #(HalfCycle) Clock= ~Clock;

   reg 	Reset;

   reg [23:0] CE_color;
   reg [31:0] CE_arguments;
   reg 	      CE_color_valid, CE_arguments_valid, CE_trigger;
   reg 	      af_full, wdf_full;

   wire       af_wr_en;
   wire [15:0] wdf_mask_din;
   
   
   CircleEngine circle(.clk(Clock),
		       .rst(Reset),
		       .CE_ready(CE_ready),
		       .CE_color(CE_color),
		       .CE_arguments(CE_arguments),
		       .CE_color_valid(CE_color_valid),
		       .CE_arguments_valid(CE_arguments_valid),
		       .CE_trigger(CE_trigger),
		       .af_full(af_full),
		       .wdf_full(wdf_full),
		       .af_addr_din(af_addr_din),
		       .af_wr_en(af_wr_en),
		       .wdf_din(wdf_din),
		       .wdf_mask_din(wdf_mask_din),
		       .wdf_wr_en(wdf_wr_en),
		       .CE_frame_base(32'h10400000));
   

   reg [2:0]   mask;
   
   always@(*) begin
      if(af_wr_en) begin
         if(wdf_mask_din[15:12] == 4'h0) mask = 3'h0;
         else if(wdf_mask_din[11:8] == 4'h0) mask = 3'h1;
         else if(wdf_mask_din[7:4] == 4'h0) mask = 3'h2;
         else if(wdf_mask_din[3:0] == 4'h0) mask = 3'h3;
         else mask = 3'h0;
      end
      else begin
         if(wdf_mask_din[15:12] == 4'h0) mask = 3'h4;
         else if(wdf_mask_din[11:8] == 4'h0) mask = 3'h5;
         else if(wdf_mask_din[7:4] == 4'h0) mask = 3'h6;
         else if(wdf_mask_din[3:0] == 4'h0) mask = 3'h7;
         else mask = 3'h0;
      end
   end

   wire [9:0] result_x, result_y;
   assign result_x = {af_addr_din[8:2], mask};
   assign result_y = af_addr_din[18:9];

   initial begin
      @(posedge Clock);
      af_full = 1'b0;
      wdf_full = 1'b0;
      CE_color_valid = 1'b0;
      CE_arguments_valid = 1'b0;
      CE_trigger = 1'b0;
      Reset = 1'b1;
      #(10*Cycle);
      Reset = 1'b0;
      #(Cycle);
      drawCircle(10'd5, 10'd5, 12'd5, 24'h00ff00);
      
   end // initial begin
   
   task drawCircle;
      input [9:0] x_input;
      input [9:0] y_input;
      input [11:0] radius_input;
      input [23:0] color_input;
      begin
	 
	 CE_color = color_input;
	 while(!CE_ready) #(Cycle);
	 CE_color_valid = 1'b1;
	 #(Cycle);
	 CE_color_valid = 1'b0;
	 CE_arguments_valid = 1'b1;
	 CE_arguments = {x_input, y_input, radius_input};
	 CE_trigger = 1'b1;
	 #(Cycle);
	 CE_arguments_valid = 1'b0;
	 CE_trigger = 1'b0;

	 while (!CE_ready) begin
	    if (wdf_wr_en && wdf_mask_din != 16'FFFF) begin
	       $display ("%4d %4d", x, y);
	    end
	    #(Cycle);
	 end
	 $display("Got out of loop");
	 $finish();

      end
   endtask // drawCircle

endmodule
	       
	 
      
