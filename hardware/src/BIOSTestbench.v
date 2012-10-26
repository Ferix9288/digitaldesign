`timescale 1ns/1ps

module BIOSTestbench();

   reg Clock, Reset;
   
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

   wire 	stall;
   reg 		ourStall;

   reg 		stallClocked;

   always@(posedge Clock)
     stallClocked <= ourStall;

   // DDR 2 wires
    wire [12:0] DDR2_A;
    wire [1:0] DDR2_BA;
    wire DDR2_CAS_B;
    wire DDR2_CKE;
    wire [1:0] DDR2_CLK_N;
    wire [1:0] DDR2_CLK_P;
    wire DDR2_CS_B;
    wire [63:0]  DDR2_D;
    wire [7:0]   DDR2_DM;
    wire [7:0]   DDR2_DQS_N;
    wire [7:0]   DDR2_DQS_P;
    wire DDR2_ODT;
    wire DDR2_RAS_B;
    wire DDR2_WE_B;

    wire  [31:0] dcache_addr;
    wire  [31:0] icache_addr;
    wire  [3:0]  dcache_we;
    wire  [3:0]  icache_we;
    wire         dcache_re;
    wire         icache_re;
    wire  [31:0] dcache_din;
    wire  [31:0] icache_din;
    wire [31:0]  dcache_dout;
    wire [31:0]  instruction;
   
    //wire         stall;

    // Instantiate your CPU here and connect the FPGA_SERIAL_TX wires
    // to the UART we use for testing
    
    PLL_BASE
    #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKFBOUT_MULT(32),
        .CLKFBOUT_PHASE(0.0),
        .CLKIN_PERIOD(10.0),

        .CLKOUT0_DIVIDE(16),
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT0_PHASE(0.0),

        .CLKOUT1_DIVIDE(4),
        .CLKOUT1_DUTY_CYCLE(0.5),
        .CLKOUT1_PHASE(0.0),

        .CLKOUT2_DIVIDE(4),
        .CLKOUT2_DUTY_CYCLE(0.5),
        .CLKOUT2_PHASE(0.0),

        .CLKOUT3_DIVIDE(4),
        .CLKOUT3_DUTY_CYCLE(0.5),
        .CLKOUT3_PHASE(90.0),

        .CLKOUT4_DIVIDE(8),
        .CLKOUT4_DUTY_CYCLE(0.5),
        .CLKOUT4_PHASE(0.0),

        .CLKOUT5_DIVIDE(16),
        .CLKOUT5_DUTY_CYCLE(0.5),
        .CLKOUT5_PHASE(0.0),

        .COMPENSATION("SYSTEM_SYNCHRONOUS"),
        .DIVCLK_DIVIDE(4),
        .REF_JITTER(0.100)
    )
    user_clk_pll
    (
        .CLKFBOUT(pll_fb),
        .CLKOUT0(cpu_clk),
        .CLKOUT1(clk200),
        .CLKOUT2(clk0),
        .CLKOUT3(clk90),
        .CLKOUT4(clkdiv0),
        .CLKOUT5(clk50),
        .LOCKED(pll_lock),
        .CLKFBIN(pll_fb),
        .CLKIN(user_clk_g),
        .RST(1'b0)
    );

    IBUFG user_clk_buf ( .I(Clock),    .O(user_clk_g) );
    BUFG  cpu_clk_buf  ( .I(cpu_clk),  .O(cpu_clk_g)  );
    BUFG  clk200_buf   ( .I(clk200),   .O(clk200_g)   );
    BUFG  clk0_buf     ( .I(clk0),     .O(clk0_g)     );
    BUFG  clkdiv50_buf ( .I(clk50),    .O(clk50_g)    );
    BUFG  clk90_buf    ( .I(clk90),    .O(clk90_g)    );
    BUFG  clkdiv0_buf  ( .I(clkdiv0),  .O(clkdiv0_g)  );

    // Reset shift register:
    reg [2:0] rst_sr;
    wire fifo_reset; // fifo_reset resets fifos... reset_fifo is a fifo for the reset signal.
    assign fifo_reset = Reset | (|rst_sr);
    always @(posedge cpu_clk_g) begin
        rst_sr <= {rst_sr[1:0], Reset};
    end

    mt4htf3264hy ddr2(
        .DDR2_A(DDR2_A),
        .DDR2_BA(DDR2_BA),
        .DDR2_CAS_B(DDR2_CAS_B),
        .DDR2_CKE(DDR2_CKE),
        .DDR2_CLK_N(DDR2_CLK_N),
        .DDR2_CLK_P(DDR2_CLK_P),
        .DDR2_CS_B(DDR2_CS_B),
        .DDR2_D(DDR2_D),
        .DDR2_DM(DDR2_DM),
        .DDR2_DQS_N(DDR2_DQS_N),
        .DDR2_DQS_P(DDR2_DQS_P),
        .DDR2_ODT(DDR2_ODT),
        .DDR2_RAS_B(DDR2_RAS_B),
        .DDR2_WE_B(DDR2_WE_B));

    Memory150 #(.SIM_ONLY(1'b1)) mem_arch(
        .cpu_clk_g(cpu_clk_g),
        .clk0_g(clk0_g),
        .clk200_g(clk200_g),
        .clkdiv0_g(clkdiv0_g),
        .clk90_g(clk90_g),
        .rst(|rst_sr),
        .init_done(init_done),
        .DDR2_A(DDR2_A),
        .DDR2_BA(DDR2_BA),
        .DDR2_CAS_B(DDR2_CAS_B),
        .DDR2_CKE(DDR2_CKE),
        .DDR2_CLK_N(DDR2_CLK_N),
        .DDR2_CLK_P(DDR2_CLK_P),
        .DDR2_CS_B(DDR2_CS_B),
        .DDR2_D(DDR2_D),
        .DDR2_DM(DDR2_DM),
        .DDR2_DQS_N(DDR2_DQS_N),
        .DDR2_DQS_P(DDR2_DQS_P),
        .DDR2_ODT(DDR2_ODT),
        .DDR2_RAS_B(DDR2_RAS_B),
        .DDR2_WE_B(DDR2_WE_B),
        .locked     (pll_lock),
        .dcache_addr(dcache_addr),
        .icache_addr(icache_addr),
        .dcache_we  (dcache_we  ),
        .icache_we  (icache_we  ),
        .dcache_re  (dcache_re  ),
        .icache_re  (icache_re  ),
        .dcache_din (dcache_din ),
        .icache_din (icache_din ),
        .dcache_dout(dcache_dout),
        .instruction(instruction),
        .stall(stall)
    );


    MIPS150 CPU(
        .clk(cpu_clk_g),
        .rst(Reset || ~init_done),
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
        .stall(stall)
    );

    UART          #( .ClockFreq(       ClockFreq))
                  uart( .Clock(           cpu_clk_g),
                        .Reset(           Reset || ~init_done),
                        .DataIn(          DataIn),
                        .DataInValid(     DataInValid),
                        .DataInReady(     DataInReady),
                        .DataOut(         DataOut),
                        .DataOutValid(    DataOutValid),
                        .DataOutReady(    DataOutReady),
                        .SIn(             FPGA_SERIAL_TX),
                        .SOut(            FPGA_SERIAL_RX));


   
   /*
    * MIPS150 CPU(.clk(Clock),
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



    */
   integer 	i;
   localparam loops = 100;
   
   initial begin
      // Reset. Has to be long enough to not be eaten by the debouncer.
      Reset = 0;
      //DataIn = 8'h7a;
      DataInValid = 0;
      DataOutReady = 0;
      ourStall = 0;
      
      
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


      /*
       * 
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
       */

      /*
       * #Cycle;	       
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
       */
   




      $finish();
   end

endmodule
