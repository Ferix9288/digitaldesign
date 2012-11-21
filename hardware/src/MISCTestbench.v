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

   //Test if grabbing the right frame
   reg [31:0] frame;
   wire [5:0]  frameBuffer_addr;
   assign frameBuffer_addr = frame[24:19] >> 3;
   
   initial begin
      x_Cols = -30;
      frame = 32'h10800000;
      
      #1;
      $display("x: %b", x_Cols);      
      $display("ABS_x: %d ", ABS_x);
      $display("ABS2_x: %d ", ABS2_x);
      $display("frame: %b ", frameBuffer_addr);

      $finish();
   end

endmodule

