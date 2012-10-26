`timescale 1ns/1ps

module BIOSTestbench();

    reg Clock, Reset, stall;
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;

    reg   [7:0] DataIn;
    reg         DataInValid;
    wire        DataInReady;
    wire  [7:0] DataOut;
    wire        DataOutValid;
    reg         DataOutReady;

    parameter HalfCycle = 5;
    parameter Cycle = 2*HalfCycle;
    parameter ClockFreq = 50_000_000;

    initial Clock = 0;
    always #(HalfCycle) Clock <= ~Clock;

    // Instantiate your CPU here and connect the FPGA_SERIAL_TX wires
    // to the UART we use for testing
   
   reg 		stallClocked;

   always@(posedge Clock)
     stallClocked <= stall;

   wire [31:0] 	dcache_addr;
   wire [31:0] 	icache_addr;
   wire [3:0] 	dcache_we;
   wire [3:0] 	icache_we;
   wire         dcache_re;
   wire         icache_re;
   wire [31:0] 	dcache_din;
   wire [31:0] 	icache_din;
   wire [31:0] 	dcache_dout;
   wire [31:0] 	instruction;

   MIPS150 CPU(.clk(Clock),
	       .rst(Reset),
	       .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
	       .FPGA_SERIAL_TX(FPGA_SERIAL_TX),
	       .dcache_addr (dcache_addr ),
               .icache_addr (icache_addr ),
               .dcache_we   (dcache_we   ),
               .icache_we   (icache_we   ),
               .dcache_re   (dcache_re   ),
               .icache_re   (icache_re   ),
               .dcache_din  (dcache_din  ),
               .icache_din  (icache_din  ),
               .dcache_dout (dcache_dout ),
               .instruction (instruction ),
               .stall(stallClocked)
	       );
   
 
   UART  #( .ClockFreq(       ClockFreq))
	    uart( .Clock(           Clock),
		  .Reset(           Reset),
		  .DataIn(          DataIn),
		  .DataInValid(     DataInValid),
		  .DataInReady(     DataInReady),
		  .DataOut(         DataOut),
		  .DataOutValid(    DataOutValid),
                  .DataOutReady(    DataOutReady),
		  .SIn(             FPGA_SERIAL_TX),
		  .SOut(            FPGA_SERIAL_RX));



   integer 	i;
   localparam loops = 100;
   
   initial begin
      // Reset. Has to be long enough to not be eaten by the debouncer.
      Reset = 0;
      //DataIn = 8'h7a;
      DataInValid = 0;
      DataOutReady = 0;
      stall = 0;
      
      
      #(100*Cycle)

      Reset = 1;
      #(30*Cycle)
      Reset = 0;

      /*
       * // Wait until transmit is ready
      while (!DataInReady) #(Cycle);
      DataInValid = 1'b1;
      #(Cycle)
      DataInValid = 1'b0;
       */

      // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;


      // Add more test cases!


      
      // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;


      // Add more test cases!

      // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;


      // Add more test cases!


      
      // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;

      // Add more test cases!

    // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;

      // Add more test cases!


      
      // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;

      // Add more test cases!

      // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;

      // Add more test cases!


      
      // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;

      // Add more test cases!

      
      // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;

      // Add more test cases!


      
      // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;

      
      DataIn = 8'hff;
      

	             
      //Wait until transmit is ready
      while (!DataInReady) #(Cycle);
      DataInValid = 1'b1;
      #(Cycle)
      DataInValid = 1'b0;

      // Wait for something to come back
      while (!DataOutValid) #(Cycle);
      $display("Got %d", DataOut);
      DataOutReady = 1;
      #Cycle;
      DataOutReady = 0;

      #Cycle;	       
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;
      stall = 1;
      #Cycle;
      stall = 0;
      #Cycle;

      for(i = 0; i< loops; i = i +1)
	begin
	   stall = ~stall;
	   #Cycle;
	end
   




      $finish();
   end

endmodule
