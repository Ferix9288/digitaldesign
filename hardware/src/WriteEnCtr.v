`include "Opcode.vh"
`include "ALUop.vh"

module WriteEnCtr (input [5:0] opcode,
		   input [1:0] byteOffset,
		   input [3:0] AddrPartition,
		   input [31:0] ALUOut,
		   output reg [3:0] writeEn);

   //AddrPartition specifies which address space this memory block holds
   //AddrIn is the top 4 bits of the address

   wire [3:0] 			    isInAddrSpace;

   assign isInAddrSpace = ALUOut[31:28];
		   
   
   always @(*) begin
      writeEn = 4'b0;
      
      casez (isInAddrSpace) 
	AddrPartition: begin
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
	     
	   endcase // case (opcode)
	end // case: AddrPartition
	
	

      endcase // case (isInAddrSpace)
      
   end

endmodule
