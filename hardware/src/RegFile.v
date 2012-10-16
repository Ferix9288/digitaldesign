//-----------------------------------------------------------------------------
//  Module: RegFile
//  Desc: An array of 32 32-bit registers
//  Inputs Interface:
//    clk: Clock signal
//    ra1: first read address (asynchronous)
//    ra2: second read address (asynchronous)
//    wa: write address (synchronous)
//    we: write enable (synchronous)
//    wd: data to write (synchronous)
//  Output Interface:
//    rd1: data stored at address ra1
//    rd2: data stored at address ra2
//  Author: Felix Li and Lionel Honda
//-----------------------------------------------------------------------------

module RegFile(input clk,
               input we,
               input  [4:0] ra1, ra2, wa,
               input  [31:0] wd,
               output [31:0] rd1,
	       output [31:0] rd2);

//three ported register file
//read two ports combinationally (asynchronous)
//write third port on rising edge of clock
//register 0 hardwired to 0

   (* ram_style = "distributed" *) reg [31:0] rf[31:0]; //32 32-bit registers
   
   
   always @(posedge clk)
     if(we) rf[wa] <= wd;
   
   assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
   assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
    
   
endmodule
