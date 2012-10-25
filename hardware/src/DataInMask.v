`include "Opcode.vh"
`include "ALUop.vh"

  module DataInMask (input [31:0] DataMemIn,
		     input [5:0] opcode,
		     input [1:0] byteOffset,
		     output reg [31:0] DataInMasked);

   wire [31:0] 			       bottomByte;
   wire [31:0] 			       bottom2Bytes;
   
   assign bottomByte = {24'b0, DataMemIn[7:0]};
   assign bottom2Bytes = {16'b0, DataMemIn[15:0]};
   
   always @(*) begin
      case (opcode)
	`SB:
	  case (byteOffset)
	    2'b00:
	      DataInMasked = bottomByte << 24;
	    2'b01:
	      DataInMasked = bottomByte << 16;
	    2'b10:
	      DataInMasked = bottomByte << 8;
	    2'b11:
	      DataInMasked = bottomByte;
	  endcase // case (byteOffset)
	
	`SH:
	  case (byteOffset[1])
	    1'b0:
	      DataInMasked = bottom2Bytes << 16;
	    1'b1:
	      DataInMasked = bottom2Bytes;
	  endcase // case (byteOffset[1])
	
	default:
	  DataInMasked = DataMemIn;
      endcase // case (opcode)
   end
   
endmodule
