// UC Berkeley CS150
// Lab 3, Spring 2012
// Module: ALU.v
// Desc:   32-bit ALU for the MIPS150 Processor
// Inputs: A: 32-bit value
// B: 32-bit value
// ALUop: Selects the ALU's operation 
// 						
// Outputs:
// Out: The chosen function mapped to A and B.

`include "Opcode.vh"
`include "ALUop.vh"

module ALU(
    input [31:0] A,B,
    input [3:0] ALUop,
    output reg [31:0] Out
);

   always@(*) begin
      Out = 0;
      
      case(ALUop)
	`ALU_ADDU: begin
	   Out = A + B;
	end
	`ALU_SUBU: begin
	   Out = A - B;
	end
	`ALU_SLT: begin
	   Out = ($signed(A) < $signed(B));
	end
	`ALU_SLTU: begin
	   Out = A < B;
	end
	`ALU_AND: begin
	   Out = A & B;
	   
	end
	`ALU_OR: begin
	   Out = A | B ;
	   
	end
	`ALU_XOR: begin
	   Out = A ^ B ;
	   
	end
	`ALU_LUI: begin
	   Out = B << 16;
	   
	end
	`ALU_SLL: begin
	   Out = B << A;
	   
	end
	`ALU_SRL: begin
	   Out = B >> A;
	   
	end
	`ALU_SRA: begin
	   Out = $signed(B) >>> A;
	   
	end
	`ALU_NOR: begin
	   Out = ~(A | B);
	   
	end
	`ALU_XXX: begin
	   
	end
      endcase // case (ALUop)
   end
	  
   
	 


endmodule
