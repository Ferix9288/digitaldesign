`include "Opcode.vh"
`include "ALUop.vh"

module WriteEnCtr (input [5:0] opcode,
		   input [1:0] byteOffset,
		   output reg [3:0] writeEn);

   always @(*) begin
      case (opcode)
	`SB: begin
	   case (byteOffset)
	     2'b00:
	       writeEn = 4'b1000;
	     2'b01:
	       writeEn = 4'b0100;
	     2'b10:
	       writeEn = 4'b0010;
	     2'b11:
	       writeEn = 4'b0001;
	   endcase // case (byteOffset)
	end
	`SH: begin
	   case (byteOffset[0])
	     1'b0:
	       writeEn = 4'b1100;
	     1'b1:
	       writeEn = 4'b0011;
	   endcase // case (byteOffset)
	end // case: `SH
	
	`SW: 
	  writeEn = 4'b1111;
	
	default:
	  writeEn = 4'b0;
	
      endcase // case (opcode)

   end

endmodule
