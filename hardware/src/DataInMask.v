`include "Opcode.vh"
`include "ALUop.vh"

  module DataInMask (input [31:0] DataMemIn,
		     input [5:0] opcode,
		     output reg [31:0] DataInMasked);

   wire [7:0] 			       bottomByte;
   wire [15:0] 			       bottom2Bytes;
   
   assign bottomByte = DataMemIn[7:0];
   assign bottom2Bytes = DataMemIn[15:0];
   
   
   always @(*) begin
      case (opcode)
	`SB:
	  DataInMasked = {bottomByte, 24'b0};
	`SH:
	  DataInMasked = {bottom2Bytes, 16'b0};
	default:
	  DataInMasked = DataMemIn;
      endcase // case (opcode)
   end
   
endmodule
