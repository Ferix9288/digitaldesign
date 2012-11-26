
/*
 Command procesor module that handles the logic for parsing the graphics commands
 Three graphics commands for line engine:
 1. Write start point
 2. Write end-point
 3. Write line color
 
 */
`include "gpcommands.vh"

module GraphicsProcessor(
			 input clk,
			 input rst,

			 //line engine processor interface
			 input LE_ready,
			 output [31:0] LE_color,
			 output [19:0] LE_point,
			 output LE_color_valid,
			 output LE_point0_valid,
			 output LE_point1_valid,
			 //output LE_x0_valid,
			 //output LE_y0_valid,
			 //output LE_x1_valid,
			 //output LE_y1_valid,
			 output LE_trigger,
			 output [31:0] LE_frame,

			 //frame filler processor interface
			 input FF_ready,
			 output FF_valid,
			 output [23:0] FF_color,
			 output [31:0] FF_frame,

			 //DRAM request controller interface
			 input rdf_valid,
			 input af_full,
			 input [127:0] rdf_dout,
			 output rdf_rd_en,
			 output af_wr_en,
			 output [30:0] af_addr_din,

			 //processor interface
			 input [31:0] GP_CODE,
			 input [31:0] GP_FRAME,
			 input GP_valid);
   
   
   //Your code goes here. GL HF.

   
   reg [2:0] 		       curState;
   reg [2:0] 		       nextState;

   localparam IDLE = 2'b00;
   localparam READ_0 = 2'b01;
   localparam READ_1 = 2'b10;
   localparam READ_2 = 2'b11;


   wire 		       FIFO_rdf_rd_en;
   wire 		       FIFO_af_wr_en;
   wire [30:0] 		       FIFO_af_addr_din;
   wire [31:0] 		       fifo_GP_out;
   

   wire 		       GP_interrupt;
   wire 		       FIFO_stall;
   
   //GP_interrupt = HIT STOP OR GP_Valid raised high again

   //assign rdf_rd_en = FIFO_rdf_rd_en;
   // assign af_wr_en = FIFO_af_wr_en;
   assign af_addr_din = FIFO_af_addr_din;

   assign rdf_rd_en = 0;
   assign af_wr_en = 0;

   wire 		       GP_stall;
   
   
   FIFO_GP Fifo_GP(//INPUTS
		   .clk(clk),
		   .rst(rst),
		   .rdf_valid(rdf_valid),
		   .af_full(af_full),
		   .rdf_dout(rdf_dout),
		   //OUTPUTS
		   .rdf_rd_en(FIFO_rdf_rd_en),
		   .af_wr_en(FIFO_af_wr_en),
		   .af_addr_din(FIFO_af_addr_din),
		   .fifo_GP_out(fifo_GP_out),
		   .fifo_stall(FIFO_stall),
		   //INPUTS
		   .GP_stall(GP_stall),
		   .GP_FRAME(GP_FRAME),
		   .GP_valid(GP_valid),
		   .GP_interrupt(GP_interrupt));


   reg [7:0] 		       curCommand;
   assign GP_stall = !FF_ready || !LE_ready;
      
   always @(posedge clk) begin
      if (rst) begin
	 curState <= IDLE;
      end else begin
	 curState <= nextState;
	 curCommand <= fifo_GP_out[31:24];
      end
   end
   
   /*
    * 
   always @(*) begin
      case (curState)
	IDLE: begin
	   GP_interrupt = 0;
	   nextState = (GP_valid)? READ_0 : curState;
	end
	
	READ_0: begin
	   if (!FIFO_stall || !GP_stall) begin
	      if (curCommand == STOP) begin
		 GP_interrupt = 1;
		 nextState = IDLE;
	      end else if (curCommand == FILL) begin
		 FF_frame = GP_FRAME;
		 FF_color = fifo_GP_out[23:0];
		 FF_valid = 1;
		 nextState  = curState;
	      end else begin
		 LE_frame = GP_FRAME;
		 LE_color = {8'b0, fifo_GP_out[23:0]};
		 LE_color_valid = 1;
		 nextState = READ_1;
	      end
	   end else begin
	      FF_valid = 0;
	      LE_color_valid = 0;
	      nextState = curState;
	   end
	end // case: READ_0

	READ_1: begin	     
	   if (!FIFO_stall || !GP_stall) begin
	      LE_point = {fifo_GP_out[25:16], fifo_GP_out[9:0]};
	      LE_point_valid = 1;
	      
	      
	     
	   nextState = READ_0;
	end
	
	READ_2: begin
	   nextState = READ_0;
	end
      endcase // case (curState)
   end
    */
   
   //output assignment placeholders - delete these later
				     /*
				      * 
   assign LE_color = 0;
   assign LE_point = 0;
   
   assign LE_color_valid = 0;
   assign LE_x0_valid = 0;
   assign LE_y0_valid = 0;
   assign LE_x1_valid = 0;
   assign LE_y1_valid = 0;

   assign LE_trigger = 0;
   assign LE_frame = 0;
				      */
   
   //frame filler processor interface
   assign FF_valid  = 1;
   assign FF_color = 24'hff0000;
   assign FF_frame = 32'h10400000;
   
   //DRAM request controller interface
   // assign rdf_rd_en = 0;
   
   //assign af_wr_en = 0;
   //assign af_addr_din = 0;

   
   
endmodule
