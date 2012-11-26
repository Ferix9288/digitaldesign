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
		GP_FRAME,
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
   input [31:0]  GP_FRAME;
   input 	 GP_valid;
   input 	 GP_interrupt;
   
   //assign stall

   localparam IDLE = 3'b000;
   //localparam SET_UP = 3'b001;
   localparam PRE_BURST_1 = 3'b101;
   localparam PRE_BURST_2 = 3'b110;
   localparam BURST_1 = 3'b001;
   localparam BURST_2 = 3'b010;
   localparam BURST_3 = 3'b011;
   localparam BURST_4 = 3'b100;
   
   
   reg [2:0] 	 curState, nextState;

   wire [5:0] 	 frameBuffer_addr;
   assign frameBuffer_addr = GP_FRAME[24:19] >> 3;

   reg [9:0] 	 x, y, next_x, next_y;
   assign af_addr_din = {6'b0, frameBuffer_addr, y, x[9:3], 2'b0};

   reg [31:0] 	 FIFO_GP[15:0];
   reg [3:0] 	 read_pointer, write_pointer;
   
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
   reg 		 First_Block_Written;
   
   
   always@(posedge clk) begin
      if (rst) begin
	 curState <= IDLE;
	 read_pointer <= 0;
	 x <= 0;
	 y <= 0;
	 
      end else begin
	 
	 curState <= nextState;
	 x <= next_x;
	 y <= next_y;
	 //if read_pointer in BLOCK1
	 if (curState != IDLE & First_Block_Written) begin
	    read_pointer <= (fifo_stall || GP_stall)? read_pointer:
			    (read_pointer == 15)? 0 : read_pointer + 1;
	    
	 end else // if (curState != IDLE)
	   read_pointer <= 0;
      end
   end  // always@ (posedge clk)
   
   assign fifo_GP_out = FIFO_GP[read_pointer];
   
   
   always@(*) begin
      case (curState)
	IDLE: begin
	   write_pointer = 4;
	   next_x = 0;
	   next_y = 0;
	   Block1_Written = 0;
	   Block2_Written = 0;
	   First_Block_Written = 0;
	   nextState = (GP_valid)? PRE_BURST_1 : IDLE;
	end

	//SET_UP: begin

	PRE_BURST_1: begin
	   af_wr_en = 1'b1;
	   First_Block_Written = 1'b0;
	   write_pointer = 4;
	   
	   if (request & rdf_valid) begin
	      next_x = (xOverFlow)? 0: x + 8;
	      next_y = (xOverFlow)? y + 1 : y;
	      //Writing into our FIFO
	      FIFO_GP[write_pointer] = rdf_dout[31:0];
	      FIFO_GP[write_pointer+1] = rdf_dout[63:32];
	      FIFO_GP[write_pointer+2] = rdf_dout[95:64];
	      FIFO_GP[write_pointer+3] = rdf_dout[127:96];
	      nextState = (GP_interrupt)? IDLE:
			  PRE_BURST_2;
	   end else begin // if (request & rdf_valid)
	      next_x = x;
	      next_y = y;
	      nextState = (GP_interrupt)? IDLE: curState;
	   end
	end // case: PRE_BURST_1

	PRE_BURST_2: begin
	   af_wr_en = 1'b0;
	   First_Block_Written = 1'b1;
	   write_pointer = 0;
	   FIFO_GP[write_pointer] = rdf_dout[31:0];
	   FIFO_GP[write_pointer+1] = rdf_dout[63:32];
	   FIFO_GP[write_pointer+2] = rdf_dout[95:64];
	   FIFO_GP[write_pointer+3] = rdf_dout[127:96];
	   
	   nextState = (GP_interrupt)? IDLE:
		       //Need to be < 7 because @ the 8th word,
		       //it'll fetch the 9th (and that word won't be
		       //written until the next cycle over - one too early)

		       //also !af_full in case it'll delay 
		       // pulling the next burst of 4 words
		       (read_pointer < 8)? BURST_3 : curState;
	   
	end // case: PRE_BURST_2
	
	BURST_1: begin
	   af_wr_en = 1'b1;
	   Block1_Written = 1'b0;
	   write_pointer = 4;
	   
	   if (request & rdf_valid) begin
	      next_x = (xOverFlow)? 0: x + 8;
	      next_y = (xOverFlow)? y + 1 : y;
	      //Writing into our FIFO
	      FIFO_GP[write_pointer] = rdf_dout[31:0];
	      FIFO_GP[write_pointer+1] = rdf_dout[63:32];
	      FIFO_GP[write_pointer+2] = rdf_dout[95:64];
	      FIFO_GP[write_pointer+3] = rdf_dout[127:96];
	      nextState = (GP_interrupt)? IDLE:
			  BURST_2;
	   end else begin // if (request & rdf_valid)
	      next_x = x;
	      next_y = y;
	      nextState = (GP_interrupt)? IDLE: curState;
	   end
	end // case: BURST_1

	BURST_2: begin
	   af_wr_en = 1'b0;
	   Block1_Written = 1'b1;
	   write_pointer = 0;
	   FIFO_GP[write_pointer] = rdf_dout[31:0];
	   FIFO_GP[write_pointer+1] = rdf_dout[63:32];
	   FIFO_GP[write_pointer+2] = rdf_dout[95:64];
	   FIFO_GP[write_pointer+3] = rdf_dout[127:96];
	   
	   nextState = (GP_interrupt)? IDLE:
		       //Need to be < 7 because @ the 8th word,
		       //it'll fetch the 9th (and that word won't be
		       //written until the next cycle over - one too early)

		       //also !af_full in case it'll delay 
		       // pulling the next burst of 4 words
		       (read_pointer < 8)? BURST_3 : curState;
	   
	end // case: BURST_2

	BURST_3: begin
	   af_wr_en = 1'b1;
	   Block2_Written = 1'b0;
	   write_pointer = 12;

	   if (request & rdf_valid) begin
	      next_x = (xOverFlow)? 0: x + 8;
	      next_y = (xOverFlow)? y + 1 : y;
	      //Writing into our FIFO
	      FIFO_GP[write_pointer] = rdf_dout[31:0];
	      FIFO_GP[write_pointer+1] = rdf_dout[63:32];
	      FIFO_GP[write_pointer+2] = rdf_dout[95:64];
	      FIFO_GP[write_pointer+3] = rdf_dout[127:96];
	      nextState = (GP_interrupt)? IDLE:
			  BURST_4;
	   end else begin // if (request & rdf_valid)
	      next_x = x;
	      next_y = y;
	      nextState = (GP_interrupt)? IDLE: curState;
	   end
	   
	end // case: BURST_3

	BURST_4: begin
	   af_wr_en = 1'b0;
	   Block2_Written = 1'b1;
	   write_pointer = 8;
	   FIFO_GP[write_pointer] = rdf_dout[31:0];
	   FIFO_GP[write_pointer+1] = rdf_dout[63:32];
	   FIFO_GP[write_pointer+2] = rdf_dout[95:64];
	   FIFO_GP[write_pointer+3] = rdf_dout[127:96];
	   
	   nextState = (GP_interrupt)? IDLE:
		       (read_pointer > 8)? BURST_1 : curState;
	end
      endcase // case (curState)
   end // always@ (*)
   
   assign fifo_stall = (read_pointer == 7 & !Block2_Written) ||
		  (read_pointer == 15 & !Block1_Written);
   
endmodule
