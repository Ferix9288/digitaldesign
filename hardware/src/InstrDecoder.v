//Asynchronously decodes/parses instructions

module InstrDecoder(
		    input [31:0] instruction,
		    output reg [5:0]  opcode, funct,
		    output reg  [4:0]  rs, rt, rd, shamt,
		    output reg  [15:0] immediate,
		    output reg  [25:0] target);

   /*
    * assign opcode = instruction[31:26];
   assign instruction  = instruction[25:21];
   assign rt = instruction[20:16];
   assign rd = instruction[15:11];
   assign shamt = instruction[10:6];
   assign funct = instruction[5:0];
   assign immediate = instruction[15:0];
   assign target = instruction[25:0];
    */

   always @(*) begin
      opcode = instruction[31:26];
      rs  = instruction[25:21];
      rt = instruction[20:16];
      rd = instruction[15:11];
      shamt = instruction[10:6];
      funct = instruction[5:0];
      immediate = instruction[15:0];
      target = instruction[25:0];
   end

   endmodule
