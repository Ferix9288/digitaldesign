
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
    output [9:0] LE_point,
    output LE_color_valid,
    output LE_x0_valid,
    output LE_y0_valid,
    output LE_x1_valid,
    output LE_y1_valid,
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

   
   reg [3:0] curState;
   reg [3:0] nextState;
   reg [3:0] prevState;

   localparam IDLE = 3'b000;
   localparam ACTIVE = 3'b001;
   localparam STOP = 3'b010;
   localparam FILL = 3'b011;
   localparam LINE = 3'b100;
   localparam READ_1 = 3'b101;
   localparam READ_2 = 3'b110;
   localparam READ_3 = 3'b111;


   wire      FIFO_rdf_rd_en;
   wire      FIFO_af_wr_en;
   wire [30:0] FIFO_af_addr_din;

   wire        GP_interrupt;
   //GP_interrupt = HIT STOP OR GP_Valid raised high again

   assign rdf_rd_en = FIFO_rdf_rd_en;
   assign af_wr_en = FIFO_af_wr_en;
   assign af_addr_din = FIFO_af_addr_din;
   
   FIFO_GP Fifo_GP(.clk(clk),
		   .rst(rst),
		   .rdf_valid(rdf_valid),
		   .af_full(af_full),
		   .rdf_dout(rdf_dout),
		   .rdf_rd_en(FIFO_rdf_rd_en),
		   .af_wr_en(FIFO_af_wr_en),
		   .af_addr_din(FIFO_af_addr_din),
		   .fifo_GP_out(fifo_GP_out),
		   .GP_FRAME(GP_FRAME),
		   .GP_valid(GP_valid),
		   .GP_interrupt(GP_interrupt));
   

		   
   /*
    * always @(posedge clk) begin
      if (rst) begin
	 curState <= IDLE;
	 prevState <= IDLE;
      end else begin
	 curState <= nextState;
	 prevState <= curState;
      end
   end

   wire [2:0] curCommand;
   
   always @(*) begin
      case (curState)
	IDLE: begin
	   nextState = (GP_valid)? READ_0 : curState;
	end
	
	READ_0: begin
	   curCommand = rdf_dout[122:120];
	   if (curCommand == STOP) begin
	      nextState = IDLE;
	   end else if (curCommand == FILL) begin
	      nextState  = READ_1;
	      FF_frame = GP_FRAME;
	   end else begin
	      nextState = READ_1;
	      LE_frame = GP_FRAME;
	   end
	end // case: READ_0

	READ_1: begin
	   if (curCommand == FILL) begin
	      nextState = READ_0;
	      FF_color = ;
	   end else begin
	      nextState = READ_2;
	      LE_color = ;
	   end
	end
	
	READ_2: begin
	   nextState = READ_0;
	end
      endcase // case (curState)
   end
    */

   
   //output assignment placeholders - delete these later
   
   assign LE_color = 0;
   assign LE_point = 0;
   
   assign LE_color_valid = 0;
   assign LE_x0_valid = 0;
   assign LE_y0_valid = 0;
   assign LE_x1_valid = 0;
   assign LE_y1_valid = 0;

   assign LE_trigger = 0;
   assign LE_frame = 0;
		       
   //frame filler processor interface
   assign FF_valid  = 0;
   assign FF_color = 0;
   assign FF_frame = 0;
		       
   //DRAM request controller interface
   assign rdf_rd_en = 0;
   
   assign af_wr_en = 0;
   assign af_addr_din = 0;
		       
endmodule
