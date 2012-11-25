`timescale 1ns/1ps

module MISCTestbench();
   localparam ClockFreq = 100_000_00;
   localparam Cycle = 10;
  
   reg  Clock, Reset;
   initial Clock = 1'b0;
   always #(5) Clock = ~Clock;

   //Test absolute function
   reg [9:0] x_Cols;
   wire [9:0] ABS_x;
   wire [9:0] ABS2_x;
   
   assign ABS_x = ($signed(x_Cols) < 0)? - x_Cols : x_Cols;
   assign ABS2_x = ($signed(x_Cols) < 0)? (~x_Cols + 1) : x_Cols;

   
   assign blah = 1'b1;

   reg [31:0] FIFO_GP[15:0];
   
   

   //Test if grabbing the right frame
   reg [31:0] frame;
   wire [5:0]  frameBuffer_addr;
   assign frameBuffer_addr = frame[24:19] >> 3;

   reg [3:0]   read_pointer;

   reg [31:0] read_out;

   
   wire [9:0] upper_bound, lower_bound;
   assign upper_bound = read_pointer << 5 + 31;
   assign lower_bound = read_pointer << 5;

   reg 	      rdf_valid, af_full;
   reg [127:0] rdf_dout;
   wire [31:0] GP_FRAME;
   reg 	       GP_valid, GP_interrupt;

   assign GP_FRAME = 32'h10400000;
   
   wire        rdf_rd_en;
   wire        af_wr_en;
   wire [30:0] af_addr_din;
   wire [31:0] fifo_GP_out;
   
   FIFO_GP FIFO(.clk(Clock),
		.rst(Reset),
		.rdf_valid(rdf_valid),
		.af_full(af_full),
		.rdf_dout(rdf_dout),
		.rdf_rd_en(rdf_rd_en),
		.af_wr_en(af_wr_en),
		.af_addr_din(af_addr_din),
		.fifo_GP_out(fifo_GP_out),
		.GP_FRAME(GP_FRAME),
		.GP_valid(GP_valid),
		.GP_interrupt(GP_interrupt));
   
   
   initial begin
      x_Cols = -30;
      frame = 32'h10800000;
      FIFO_GP[2] = 32'hffffffff;      
      read_pointer = 2;
      read_out = FIFO_GP[read_pointer];
      
      GP_valid = 0;
      GP_interrupt = 0;

      Reset = 1;
      #(5*Cycle);
      Reset = 0;
      
      
      #1;
      $display("x: %b", x_Cols);      
      $display("ABS_x: %d ", ABS_x);
      $display("ABS2_x: %d ", ABS2_x);
      $display("frame: %b ", frameBuffer_addr);
      $display("blah: %b ", blah);
      $display("FIFO_GP: %h", FIFO_GP[2]);
      $display("Read_out: %h", read_out);

      #1;
      rdf_valid = 0;
      af_full = 0;
      
      #(Cycle);
      GP_valid = 1;
      rdf_dout = 32'h0;
      

      #1;
      
      #(10*Cycle);
      rdf_valid = 1;
      rdf_dout = 128'hff000000ceaa0e3ddeadbeefffffffff;
      #(100*Cycle);
      
      $finish();
   end

endmodule

