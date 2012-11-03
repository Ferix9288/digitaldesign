`include "Opcode.vh"
`include "ALUop.vh"

module WriteEnCtr (input [5:0] opcode,
		   input [1:0] byteOffset,
		   input [31:0] ALUOut,
		   input stall,
		   input [31:0] PC,
		   input [31:0] pcE,
		   output reg [3:0] dataMemWriteEn,
		   output reg [3:0] instrMemWriteEn,
		   output reg [3:0] ISR_MemWriteEn);

   //AddrPartition specifies which address space this memory block holds
   //AddrIn is the top 4 bits of the address

   wire [3:0] 			    topNibble;
   wire 			    isDataMem;
   wire 			    isInstrMem;
   wire 			    isISR;
   
   //wire 			    isInAddrSpace;
   
   
   assign topNibble = ALUOut[31:28];
   assign isDataMem = (topNibble[3] == 1'b0) && (topNibble[2] == 1'b0) && 
		      (topNibble[0] == 1'b1);
   assign isInstrMem = (topNibble[3] == 1'b0) && (topNibble[2] == 1'b0) && 
		       (topNibble[1] == 1'b1);

   assign isISR = (topNibble == 4'b1100);
   
   
   always @(*) begin
      if (stall) 
	 dataMemWriteEn = 4'b0;
      else if (isDataMem) begin
	 case (opcode)
	   `SB: begin
	      case (byteOffset)
		2'b00:
		  dataMemWriteEn = 4'b1000;
		2'b01:
		  dataMemWriteEn = 4'b0100;
		2'b10:
		  dataMemWriteEn = 4'b0010;
		2'b11:
		  dataMemWriteEn = 4'b0001;
	      endcase // case (byteOffset)
	   end
	   `SH: begin
	      case (byteOffset[1])
		1'b0:
		  dataMemWriteEn = 4'b1100;
		1'b1:
		  dataMemWriteEn = 4'b0011;
	      endcase // case (byteOffset)
	   end // case: `SH
	   
	   `SW: 
	     dataMemWriteEn = 4'b1111;
	   
	   default:
	     dataMemWriteEn = 4'b0;
	 endcase // case (opcode)
	 
      end else   // if (isInAddrSpace)
	dataMemWriteEn = 4'b0;
      
   end

   always @(*) begin
      if (stall)
	instrMemWriteEn = 4'b0;
      else if (isInstrMem && PC[30] == 1'b1) begin
	 case (opcode)
	   `SB: begin
	      case (byteOffset)
		2'b00:
		  instrMemWriteEn = 4'b1000;
		2'b01:
		  instrMemWriteEn = 4'b0100;
		2'b10:
		  instrMemWriteEn = 4'b0010;
		2'b11:
		  instrMemWriteEn = 4'b0001;
	      endcase // case (byteOffset)
	   end
	   `SH: begin
	      case (byteOffset[1])
		1'b0:
		  instrMemWriteEn = 4'b1100;
		1'b1:
		  instrMemWriteEn = 4'b0011;
	      endcase // case (byteOffset)
	   end // case: `SH
	   
	   `SW: 
	     instrMemWriteEn = 4'b1111;
	   
	   default:
	     instrMemWriteEn = 4'b0;
	 endcase // case (opcode)
	 
      end else   // if (isInAddrSpace)
	instrMemWriteEn = 4'b0;
      
   end // always @ (*)

   always @(*) begin
      if (stall)
	ISR_MemWriteEn = 4'b0;
      else if (isISR) begin
	 case (opcode)
	   `SB: begin
	      case (byteOffset)
		2'b00:
		  ISR_MemWriteEn = 4'b1000;
		2'b01:
		  ISR_MemWriteEn = 4'b0100;
		2'b10:
		  ISR_MemWriteEn = 4'b0010;
		2'b11:
		  ISR_MemWriteEn = 4'b0001;
	      endcase // case (byteOffset)
	   end
	   `SH: begin
	      case (byteOffset[1])
		1'b0:
		  ISR_MemWriteEn = 4'b1100;
		1'b1:
		  ISR_MemWriteEn = 4'b0011;
	      endcase // case (byteOffset)
	   end // case: `SH
	   
	   `SW: 
	     ISR_MemWriteEn = 4'b1111;
	   
	   default:
	     ISR_MemWriteEn = 4'b0;
	 endcase // case (opcode)
	 
      end else   // if (isInAddrSpace)
	ISR_MemWriteEn = 4'b0;
      
   end // always @ (*)

   
endmodule
