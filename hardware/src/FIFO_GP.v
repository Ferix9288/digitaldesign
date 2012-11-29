//-----------------------------------------------------
// Design Name : FIFO_GP
// File Name   : FIFO_GP.v
// Function    : Synchronous (single clock) FIFO for GP
// Coder       : Felix Li and Lionel Honda
//-----------------------------------------------------

module FIFO_GP (
		clk, // Clock input
		rst, // Active high reset
		rdf_valid,
		af_full,
		rdf_dout,
		rdf_rd_en,
		af_wr_en,
		af_addr_din,
		fifo_GP_out,
		fifo_stall,
		GP_stall,
		GP_CODE,
		GP_valid,
		GP_interrupt
		);    

   
   // Port Declarations
   input clk ;
   input rst ;
   input rdf_valid ;
   input af_full ;
   input [127:0] rdf_dout ;
   output 	 rdf_rd_en ;
   output reg 	 af_wr_en;
   output [30:0] af_addr_din;
   output [31:0] fifo_GP_out;
   output 	 fifo_stall;
   input 	 GP_stall;
   input [31:0]  GP_CODE;
   input 	 GP_valid;
   input 	 GP_interrupt;
   
   //assign stall

   localparam IDLE = 3'b000;
   localparam REQUEST_BLOCK1 = 3'b101;
   localparam REQUEST_BLOCK2 = 3'b110;
   localparam BURST_1 = 3'b001;
   localparam BURST_2 = 3'b010;
   localparam BURST_3 = 3'b011;
   localparam BURST_4 = 3'b100;
   
   
   reg [2:0] 	 curState, nextState;

   wire [31:0] 	 addr_div8;
   wire [5:0] 	 frameBuffer_addr;
   assign addr_div8 = GP_CODE >> 3;
   assign frameBuffer_addr = addr_div8[24:19];

   reg [9:0] 	 x, y, next_x, next_y;
   assign af_addr_din = {6'b0, frameBuffer_addr, y, x[9:3], 2'b0};

   reg [31:0] 	 FIFO_GP[15:0];
   reg [3:0] 	 read_pointer, write_pointer, next_wp;
   
   wire 	 xOverFlow;
   assign xOverFlow = (x == 10'd792);

   wire 	 request;   
   assign request = af_wr_en & !af_full;

   assign rdf_rd_en = 1'b1;

   //Two Things happening:
   //ONE: Block1/2_Written checks to see if read pointer has
   //access to these blocks.
   //TWO: (read_pointer < or > 8 check is to ensure that writes
   //don't happen to a block currently being read.
   
   reg 		 Block1_Written;
   reg 		 Block2_Written;

   reg [31:0] 	 word0, word1, word2, word3;

   always@(posedge clk) begin
      if (rst) begin
	 curState <= IDLE;
	 read_pointer <= 15;
	 x <= 0;
	 y <= 0;
	 
      end else begin
	 curState <= nextState;
	 x <= (GP_valid)? 0 : next_x;
	 y <= (GP_valid)? 0 : next_y;
	 //write_pointer <= next_wp;
	 FIFO_GP[write_pointer] <= word0;
	 FIFO_GP[write_pointer+1] <= word1;	 
	 FIFO_GP[write_pointer+2] <= word2;	 
	 FIFO_GP[write_pointer+3] <= word3;
	 //if read_pointer in BLOCK1
	 if (curState != IDLE) begin
	    read_pointer <= (GP_valid)? 15:
			    (fifo_stall || GP_stall)? read_pointer:
			    (read_pointer == 15)? 0 : read_pointer + 1;
	    
	 end else // if (curState != IDLE)
	   read_pointer <= read_pointer;
      end
   end  // always@ (posedge clk)
   
   assign fifo_GP_out = FIFO_GP[read_pointer];
   
   assign fifo_stall = (read_pointer == 7 & !Block2_Written) ||
		       (read_pointer == 15 & !Block1_Written);
   
   
   always@(*) begin

      case (curState)
	IDLE: begin
	   //BLOCK_WRITTEN
	   Block1_Written = 0;
	   Block2_Written = 0;
	   //WRITE_POINTER
	   write_pointer = 0;
	   //ADDRESSING
	   next_x = 0;
	   next_y = 0;
	   //STATE
	   nextState = (GP_valid)? REQUEST_BLOCK1 : IDLE;
	end // case: IDLE

	REQUEST_BLOCK1: begin
	   af_wr_en = 1'b1;
	   //BLOCK_WRITTEN
	   Block1_Written = 0;
	   Block2_Written = 1;
	   //WRITE_POINTER
	   write_pointer = 8;
	   //ADDRESSING
	   if (!af_full & !GP_valid & !GP_interrupt & (read_pointer >= 8)) begin
	      next_x = (xOverFlow)? 0 : x + 8;
	      next_y = (xOverFlow)? y + 1: y;
	      nextState = BURST_1;
	      
	   end else begin
	      next_x = x;
	      next_y = y;
	      nextState = (GP_valid)? REQUEST_BLOCK1:
			  (GP_interrupt)? IDLE: curState;
	   end	   
	end
	
	BURST_1: begin
	   af_wr_en = 1'b0;
	   //BLOCK_WRITTEN
	   Block1_Written = 1'b0;
	   Block2_Written = 1'b1;
	   //WRITE_POINTER
	   write_pointer = 4;
	   //ADDRESSING
	   next_x = x;
	   next_y = y;
	   
	   //READ BURST1
	   if (rdf_valid) begin
	      word0 = rdf_dout[31:0]; 
	      word1 = rdf_dout[63:32];
	      word2 = rdf_dout[95:64];
	      word3 = rdf_dout[127:96];
	      //Writing into our FIFO
	      nextState = (GP_valid)? REQUEST_BLOCK1:
			  (GP_interrupt)? IDLE: BURST_2;
	   end else begin // if (request & rdf_valid)
	      next_wp = write_pointer;
	      word0 = FIFO_GP[write_pointer];
	      word1 = FIFO_GP[write_pointer+1];
	      word2 = FIFO_GP[write_pointer+2];
	      word3 = FIFO_GP[write_pointer+3];
	      nextState = (GP_valid)? REQUEST_BLOCK1:
			  (GP_interrupt)? IDLE: curState;
	   end
	end // case: BURST_1

	BURST_2: begin
	   af_wr_en = 1'b0;
	   //BLOCK_WRITTEN
	   Block1_Written = 1'b1;
	   Block2_Written = 1'b1;
	   //WRITE_POINTER
	   write_pointer = 0;
	   //READ BURST 2
	   word0 = rdf_dout[31:0]; 
	   word1 = rdf_dout[63:32];
	   word2 = rdf_dout[95:64];
	   word3 = rdf_dout[127:96];
	   nextState = (GP_valid)? REQUEST_BLOCK1:
		       (GP_interrupt)? IDLE:
		       //if read_pointer in Block 1
		       REQUEST_BLOCK2;
	   
	end // case: BURST_2

	REQUEST_BLOCK2: begin
	   af_wr_en = 1'b1;
	   //BLOCK_WRITTEN
	   Block1_Written = 1'b1;
	   Block2_Written = 1'b0;
	   //WRITE_POINTER
	   write_pointer = 0;
	   //ADDRESSING
	   if (!af_full & !GP_valid & !GP_interrupt & (read_pointer < 8)) begin
	      next_x = (xOverFlow)? 0 : x + 8;
	      next_y = (xOverFlow)? y + 1: y;
	      nextState = BURST_3;
	   end else begin
	      next_x = x;
	      next_y = y;
	      nextState = (GP_valid)? REQUEST_BLOCK1:
			  (GP_interrupt)? IDLE: curState;
	   end	   
	end // case: REQUEST_BLOCK2
	
	BURST_3: begin
	   af_wr_en = 1'b1;
	   //BLOCK_WRITTEN
	   Block1_Written = 1'b1;
	   Block2_Written = 1'b0;
	   //WRITE_POINTER
	   write_pointer = 12;
	   //ADDRESSING
	   next_x = x;
	   next_y = y;
	   //READ BURST 3
	   if (rdf_valid) begin
	      word0 = rdf_dout[31:0]; 
	      word1 = rdf_dout[63:32];
	      word2 = rdf_dout[95:64];
	      word3 = rdf_dout[127:96];
	      //Writing into our FIFO
	      nextState = (GP_valid)? REQUEST_BLOCK1:
			  (GP_interrupt)? IDLE:
			  BURST_4;
	   end else begin // if (request & rdf_valid)
	      next_wp = write_pointer;
	      word0 = FIFO_GP[write_pointer];
	      word1 = FIFO_GP[write_pointer+1];
	      word2 = FIFO_GP[write_pointer+2];
	      word3 = FIFO_GP[write_pointer+3];

	      nextState = (GP_valid)? REQUEST_BLOCK1:
			  (GP_interrupt)? IDLE: curState;
	   end
	   
	end // case: BURST_3

	BURST_4: begin
	   af_wr_en = 1'b0;
	   //BLOCK_WRITTEN
	   Block1_Written = 1'b1;
	   Block2_Written = 1'b1;
	   //WRITE_POINTER
	   write_pointer = 8;
	   //READ BURST 4
	   word0 = rdf_dout[31:0]; 
	   word1 = rdf_dout[63:32];
	   word2 = rdf_dout[95:64];
	   word3 = rdf_dout[127:96];
	   nextState = (GP_valid)? REQUEST_BLOCK1:
		       (GP_interrupt)? IDLE:
		       REQUEST_BLOCK1;
	end
      endcase // case (curState)
   end // always@ (*)
   


   wire [35:0] chipscope_control;
   chipscope_icon icon(
		       .CONTROL0(chipscope_control)
		       );
   chipscope_ila ila(
   		     .CONTROL(chipscope_control),
		     .CLK(clk),
		     .TRIG0({GP_interrupt, xOverFlow, yOverFlow, rst, rdf_valid, af_full, af_wr_en, First_Block_Written, Block1_Written, Block2_Written, fifo_stall, GP_stall, GP_valid, curState, nextState, read_pointer, rdf_dout, x, y, af_addr_din, fifo_GP_out})
		     ); 
   
   
endmodule
