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
   localparam REQUEST = 3'b101;
   //localparam SET_UP = 3'b001;
   localparam PRE_BURST_1 = 3'b101;
   localparam PRE_BURST_2 = 3'b110;
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
   reg 		 First_Block_Written;

   reg [31:0] 	 word0, word1, word2, word3;
   reg 		 rdf_valid_clocked;

   always@(posedge clk) begin
      if (rst) begin
	 curState <= IDLE;
	 read_pointer <= 0;
	 x <= 0;
	 y <= 0;
	 rdf_valid_clocked <= 0;
	 
      end else begin
	 
	 curState <= nextState;
	 x <= next_x;
	 y <= next_y;
	 write_pointer <= next_wp;
	 FIFO_GP[write_pointer] <= word0;
	 FIFO_GP[write_pointer+1] <= word1;	 
	 FIFO_GP[write_pointer+2] <= word2;	 
	 FIFO_GP[write_pointer+3] <= word3;
	 rdf_valid_clocked <= rdf_valid;
	 
	 //if read_pointer in BLOCK1
	 if (curState != IDLE) begin
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
	   //BLOCK_WRITTEN
	   First_Block_Written = 0;
	   Block1_Written = 0;
	   Block2_Written = 0;
	   //WRITE_POINTER
	   next_wp = 4;
	   //ADDRESSING
	   next_x = 0;
	   next_y = 0;
	   //STATE
	   nextState = (GP_valid)? REQUEST : IDLE;
	end // case: IDLE

	REQUEST: begin
	   //BLOCK_WRITTEN
	   First_Block_Written = 0;
	   Block1_Written
	//SET_UP: begin

	PRE_BURST_1: begin
	   af_wr_en = 1'b1;
	   //BLOCK_WRITTEN
	   First_Block_Written = 1'b0;
	   Block1_Written = 0;
	   Block2_Written = 0;
	   //WRITE_POINTER
	   next_wp = 4;
	   //READ BURST 1
	   if (request & rdf_valid) begin
	      word0 = rdf_dout[31:0]; 
	      word1 = rdf_dout[63:22];
	      word2 = rdf_dout[95:64];
	      word3 = rdf_dout[127:96];
	      next_x = (xOverFlow)? 0: x + 8;
	      next_y = (xOverFlow)? y + 1 : y;
	      nextState = (GP_valid)? curState:
			  (GP_interrupt)? IDLE: PRE_BURST_2;
	      
	   end else begin // if (request & rdf_valid)
	      next_wp = write_pointer;
	      word0 = FIFO_GP[write_pointer];
	      word1 = FIFO_GP[write_pointer+1];
	      word2 = FIFO_GP[write_pointer+2];
	      word3 = FIFO_GP[write_pointer+3];
	      next_x = x;
	      next_y = y;
	      nextState = (GP_interrupt)? IDLE: curState;
	   end
	end // case: PRE_BURST_1

	PRE_BURST_2: begin
	   af_wr_en = 1'b0;
	   //BLOCK_WRITTEN
	   First_Block_Written = 1'b0;
	   Block1_Written = 1'b0;
	   Block2_Written = 1'b0;
	   //WRITE_POINTER
	   next_wp = 0;
	   //READ BURST2
	   word0 = rdf_dout[31:0]; 
	   word1 = rdf_dout[63:22];
	   word2 = rdf_dout[95:64];
	   word3 = rdf_dout[127:96];
	   nextState = (GP_valid)? PRE_BURST_1:
		       (GP_interrupt)? IDLE: BURST_3;
	   
	   
	end // case: PRE_BURST_2
	
	BURST_1: begin
	   af_wr_en = 1'b1;
	   //BLOCK_WRITTEN
	   First_Block_Written = 1'b1;
	   Block1_Written = 1'b0;
	   Block2_Written = 1'b1;
	   //WRITE_POINTER
	   next_wp = 4;
	   //READ BURST1
	   if (request & rdf_valid) begin
	      word0 = rdf_dout[31:0]; 
	      word1 = rdf_dout[63:22];
	      word2 = rdf_dout[95:64];
	      word3 = rdf_dout[127:96];
	      next_x = (xOverFlow)? 0: x + 8;
	      next_y = (xOverFlow)? y + 1 : y;
	      //Writing into our FIFO
	      nextState = (GP_valid)? PRE_BURST_1:
			  (GP_interrupt)? IDLE: BURST_2;
	   end else begin // if (request & rdf_valid)
	      next_wp = write_pointer;
	      word0 = FIFO_GP[write_pointer];
	      word1 = FIFO_GP[write_pointer+1];
	      word2 = FIFO_GP[write_pointer+2];
	      word3 = FIFO_GP[write_pointer+3];
	      next_x = x;
	      next_y = y;
	      nextState = (GP_valid)? PRE_BURST_1:
			  (GP_interrupt)? IDLE: curState;
	   end
	end // case: BURST_1

	BURST_2: begin
	   af_wr_en = 1'b0;
	   //BLOCK_WRITTEN
	   First_Block_Written = 1'b1;
	   Block1_Written = 1'b1;
	   Block2_Written = 1'b1;
	   //WRITE_POINTER
	   next_wp = 0;
	   //READ BURST 2
	   word0 = rdf_dout[31:0]; 
	   word1 = rdf_dout[63:22];
	   word2 = rdf_dout[95:64];
	   word3 = rdf_dout[127:96];
	   nextState = (GP_valid)? PRE_BURST_1:
		       (GP_interrupt)? IDLE:
		       //if read_pointer in Block 1
		       (read_pointer < 8)? BURST_3 : curState;
	   
	end // case: BURST_2

	BURST_3: begin
	   af_wr_en = 1'b1;
	   //BLOCK_WRITTEN
	   First_Block_Written = 1'b1;
	   Block1_Written = 1'b1;
	   Block2_Written = 1'b0;
	   //WRITE_POINTER
	   next_wp = 12;
	   //READ BURST 3
	   if (request & rdf_valid) begin
	      word0 = rdf_dout[31:0]; 
	      word1 = rdf_dout[63:22];
	      word2 = rdf_dout[95:64];
	      word3 = rdf_dout[127:96];
	      next_x = (xOverFlow)? 0: x + 8;
	      next_y = (xOverFlow)? y + 1 : y;
	      //Writing into our FIFO
	      nextState = (GP_valid)? PRE_BURST_1:
			  (GP_interrupt)? IDLE:
			  BURST_4;
	   end else begin // if (request & rdf_valid)
	      next_wp = write_pointer;
	      word0 = FIFO_GP[write_pointer];
	      word1 = FIFO_GP[write_pointer+1];
	      word2 = FIFO_GP[write_pointer+2];
	      word3 = FIFO_GP[write_pointer+3];
	      next_x = x;
	      next_y = y;
	      nextState = (GP_valid)? PRE_BURST_1:
			  (GP_interrupt)? IDLE: curState;
	   end
	   
	end // case: BURST_3

	BURST_4: begin
	   af_wr_en = 1'b0;
	   //BLOCK_WRITTEN
	   First_Block_Written = 1'b1;
	   Block1_Written = 1'b1;
	   Block2_Written = 1'b1;
	   //WRITE_POINTER
	   next_wp = 8;
	   //READ BURST 4
	   word0 = rdf_dout[31:0]; 
	   word1 = rdf_dout[63:22];
	   word2 = rdf_dout[95:64];
	   word3 = rdf_dout[127:96];
	   nextState = (GP_valid)? PRE_BURST_1:
		       (GP_interrupt)? IDLE:
		       (read_pointer > 8)? BURST_1 : curState;
	end
      endcase // case (curState)
   end // always@ (*)
   
   assign fifo_stall = (read_pointer == 7 & !Block2_Written) ||
		  (read_pointer == 15 & !Block1_Written) || (!First_Block_Written) ;

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
