`timescale 1ns/1ps

module asmTestbench();

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

   MIPS150 CPU(.clk(Clock),
	       .rst(Reset),
	       .stall(stall),
	       .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
	       .FPGA_SERIAL_TX(FPGA_SERIAL_TX));
   


    UART          #( .ClockFreq(       ClockFreq))
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

   initial begin
      // Reset. Has to be long enough to not be eaten by the debouncer.)

      Reset = 1;
      stall = 0;
      
      #(30*Cycle);
      
      Reset = 0;

      #(1000*Cycle);
      
      

      $finish();
   end

endmodule
