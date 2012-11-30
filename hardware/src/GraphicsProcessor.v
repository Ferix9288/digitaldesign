
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
			 output reg   [31:0] LE_color,
			 output reg  [19:0] LE_point,
			 output reg  LE_color_valid,
			 output reg  LE_point0_valid,
			 output reg  LE_point1_valid,
			 //output LE_x0_valid,
			 //output LE_y0_valid,
			 //output LE_x1_valid,
			 //output LE_y1_valid,
			 output reg  LE_trigger,
			 output   [31:0] LE_frame,

			 //frame filler processor interface
			 input FF_ready,
			 output reg  FF_valid,
			 output reg  [23:0]  FF_color,
			 output   [31:0]  FF_frame,

			 //circle engine process interface
			 input CE_ready,
			 output reg [23:0] CE_color,
			 output reg [31:0] CE_arguments,
			 output reg CE_color_valid,
			 output reg CE_arguments_valid,
			 output reg CE_trigger,
			 output [31:0] CE_frame,
			 
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
			 input GP_valid, 
			 output reg GP_interrupt);
   
   
   //Your code goes here. GL HF.

   
   reg [2:0] 		       curState;
   reg [2:0] 		       nextState;

   localparam IDLE = 3'b000;
   localparam READ_0 = 3'b001;
   localparam LINE_1 = 3'b010;
   localparam LINE_2 = 3'b011;
   localparam CIRCLE_1 = 3'b101;
   localparam WAIT = 3'b100;
  


   wire 		       FIFO_rdf_rd_en;
   wire 		       FIFO_af_wr_en;
   wire [30:0] 		       FIFO_af_addr_din;
   wire [31:0] 		       fifo_GP_out;
   

  // wire 		       GP_interrupt;
   wire 		       FIFO_stall;
   
   //GP_interrupt = HIT STOP OR GP_Valid raised high again

   assign rdf_rd_en = FIFO_rdf_rd_en;
   assign af_wr_en = FIFO_af_wr_en;
   assign af_addr_din = FIFO_af_addr_din;
 
   /*
    * assign rdf_rd_en = 1'b0;
   assign af_wr_en = 1'b0;

   assign  FF_valid = 1'b1;
   assign  FF_color = 24'hff0000;
   assign  FF_frame = 32'h10400000;
   
   assign    LE_color = 0;
   assign    LE_point = 0;
   
   assign   LE_color_valid = 0;
   assign   LE_point0_valid = 0;
   assign  LE_point1_valid = 0;
   

   assign   LE_trigger = 0;
   assign  LE_frame = 0;
    */
   
   
   wire 		      GP_stall;
   
   wire [3:0]		      read_pointer;
   wire [2:0] 		      FIFO_curState;
 
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
		   .GP_CODE(GP_CODE),
		   .GP_valid(GP_valid),
		   .GP_interrupt(GP_interrupt),
		   .read_pointer(read_pointer),
		   .curState(FIFO_curState));


   wire [7:0] 		       curCommand;
   assign curCommand = fifo_GP_out[`OPCODE_IDX];
   assign GP_stall = !FF_ready || !LE_ready || !CE_ready;

   reg 			       GP_stall_clocked, FIFO_stall_clocked;

   assign FF_frame = GP_FRAME;
   assign LE_frame = GP_FRAME;
   assign CE_frame = GP_FRAME;
   
   always @(posedge clk) begin
      if (rst) begin
	 curState <= IDLE;
	 GP_stall_clocked <= 0;
	 FIFO_stall_clocked <= 0;
      end else begin
	 curState <= nextState;
	 GP_stall_clocked <= GP_stall;
	 FIFO_stall_clocked <= FIFO_stall;
      end
   end
   
   always @(*) begin
      GP_interrupt = 0;
      FF_valid = 0;
      FF_color = 0;
      
      LE_color_valid = 0;
      LE_point0_valid = 0;
      LE_point1_valid = 0;
      LE_trigger = 0;
      LE_color = 0;
      LE_point = 0;
      
      CE_color_valid = 0;
      CE_arguments_valid = 0;
      CE_trigger = 0;
      CE_arguments = 0;
      CE_color = 0;
      
      
      case (curState)
	IDLE: begin

	   nextState = (GP_valid)? READ_0 : curState;
	end
	
	READ_0: begin

	   if (!FIFO_stall_clocked & !GP_stall) begin
	      if (curCommand == `STOP) begin
		 GP_interrupt = 1;
		 nextState = (GP_valid)? curState: IDLE;
	      end else if (curCommand == `FILL) begin
		 //FF_frame = GP_FRAME;
		 FF_color = fifo_GP_out[`COLOR_IDX];
		 FF_valid = 1;
		 nextState  = curState;//: WAIT;
		 
 	      end else if (curCommand == `LINE) begin
		 //LE_frame = GP_FRAME;
		 LE_color = {8'b0, fifo_GP_out[`COLOR_IDX]};
		 LE_color_valid = 1;
		 nextState = (GP_valid)? curState : LINE_1;
	      end else if (curCommand == `CIRCLE) begin
		 CE_color = fifo_GP_out[`COLOR_IDX];
		 CE_color_valid = 1;
		 nextState = (GP_valid)? curState : CIRCLE_1;
	      end else begin
		 nextState = curState;
	      end
	   end else begin
	      nextState = curState;
	   end
	end // case: LINE_0

	LINE_1: begin	
	   if (!FIFO_stall_clocked & !GP_stall) begin
	      LE_point = {fifo_GP_out[`X_ADDR], fifo_GP_out[`Y_ADDR]};
	      LE_point0_valid = 1;	     
	      nextState = (GP_valid)? READ_0 : LINE_2;
	   end else begin
	      nextState = (GP_valid)? READ_0 : curState;
	   end
	end
	
	LINE_2: begin
	   if (!FIFO_stall_clocked & !GP_stall) begin
	      LE_point = {fifo_GP_out[`X_ADDR], fifo_GP_out[`Y_ADDR]};
	      LE_point1_valid = 1;
	      LE_trigger = 1;
	      nextState = READ_0; //WAIT
	   end else begin
	      nextState = (GP_valid)? READ_0 : curState;
	   end
	end // case: LINE_2

	CIRCLE_1: begin	
	   if (!FIFO_stall_clocked & !GP_stall) begin
	      CE_arguments = fifo_GP_out;
	      CE_arguments_valid = 1;	     
	      nextState = READ_0;
	   end else begin
	      nextState = (GP_valid)? READ_0 : curState;
	   end
	end

      endcase // case (curState)
   end
    
   
   				     

   
   //frame filler processor interface
   /*
    * assign FF_valid  = 1;
   assign FF_color = 24'hff0000;
   assign FF_frame = 32'h10400000;
    */
   
   //DRAM request controller interface

   
   
    
   
   wire [35:0] chipscope_control;
   chipscope_icon icon(
		       .CONTROL0(chipscope_control)
		       );
   chipscope_ila ila(
   		     .CONTROL(chipscope_control),
		     .CLK(clk),
		     .TRIG0({FIFO_curState, read_pointer, rst, rdf_valid, af_wr_en, wdf_wr_en, LE_ready, FF_ready, LE_color_valid, LE_point0_valid, LE_point1_valid, LE_trigger, FF_valid, FIFO_stall, GP_stall, GP_valid, curState, nextState, rdf_dout, GP_FRAME, GP_CODE, fifo_GP_out})
		     ); 
   
    
   
   
   
   
endmodule
