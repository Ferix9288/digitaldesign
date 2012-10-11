`include "Opcode.vh"
`include "ALUop.vh"

module DataOutMask (input [31:0] DataOutMem,
		    input [5:0] opcode,
		    input [1:0] byteOffset,
		    output reg [31:0] DataOutMasked);

   always @(*) begin
      
      case (opcode)
	`LB: begin //Return the byte signed
	   case (byteOffset)
	     2'b00:
	       DataOutMasked = (DataOutMem[31] == 1'b1)? {24'hffffff, DataOutMem[31:24]}: {24'b0, DataOutMem[31:24]};
	     2'b01:
	       DataOutMasked = (DataOutMem[23] == 1'b1)? {24'hffffff, DataOutMem[23:16]}: {24'b0, DataOutMem[23:16]};
	     2'b10:
	       DataOutMasked = (DataOutMem[15] == 1'b1)? {24'hffffff, DataOutMem[15:8]}: {24'b0, DataOutMem[15:8]};
	     2'b11:
	       DataOutMasked = (DataOutMem[7] == 1'b1)? {24'hffffff, DataOutMem[7:0]}: {24'b0, DataOutMem[7:0]};
	   endcase // case (byteOffset)
	end // case: `LB
	`LBU: begin
	   case (byteOffset)
	      2'b00:
	       DataOutMasked = {24'b0, DataOutMem[31:24]};
	     2'b01:
	       DataOutMasked = {24'b0, DataOutMem[23:16]};
	     2'b10:
	       DataOutMasked = {24'b0, DataOutMem[15:8]};
	     2'b11:
	       DataOutMasked = {24'b0, DataOutMem[7:0]};
	   endcase // case (byteOffset)
	end // case: `LBU
	
	`LH: begin
	   case (byteOffset[0])
	     1'b0:
	       DataOutMasked = (DataOutMem[31] == 1'b1)? {15'hffff, DataOutMem[31:16], 1'b0}: {15'b0, DataOutMem[31:16], 1'b0};
	     1'b1:
	       DataOutMasked = (DataOutMem[15] == 1'b1)? {15'hffff, DataOutMem[15:0], 1'b0}: {15'b0, DataOutMem[15:0], 1'b0};
	   endcase // case (byteOffset)	   
	end // case: `LH
	
	`LHU: begin
	   case (byteOffset[0])
	     1'b0:
	       DataOutMasked = {15'b0, DataOutMem[31:16], 1'b0};
	     1'b1:
	       DataOutMasked = {15'b0, DataOutMem[15:0], 1'b0};
	   endcase // case (byteOffset)
	end // case: `LHU

	`LW: begin
	   DataOutMasked = {DataOutMem[31:2], 2'b0};
	   
	end
	
	
	default:
	  DataOutMasked = DataOutMem;
	
	
      endcase // case (opcode)

   end

endmodule
