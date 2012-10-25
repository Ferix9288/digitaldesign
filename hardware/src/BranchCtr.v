`include "Opcode.vh"
`include "ALUop.vh"

module BranchCtr (input [5:0] opcode,
		  input [31:0] rd1,
		  input [31:0] rd2,
		  input [4:0] rtE,
		  output reg  branchCtr);

   always @(*) begin
      case (opcode)
	`BEQ: 
	  branchCtr = (rd1 == rd2)? 1 : 0;
	
	`BNE: 
	  branchCtr = (rd1 != rd2)? 1 : 0;
	
	`BLEZ: 
	  branchCtr = ($signed(rd1) <= 0)? 1: 0;
	
	`BGTZ:
	  branchCtr = ($signed(rd1) > 0)? 1:0;

	`BLTZ, `BGEZ: begin
	   //Determine which one of the two instr by rt register value
	   if (rtE  == 1)
	     //BGEZ
	     branchCtr = ($signed(rd1) >= 0)? 1:0;
	   else
	     //BLTZ
	     branchCtr = ($signed(rd1) < 0)? 1:0;
	end

	default:
	  branchCtr = 0;
	
      endcase // case (opcode)

   end

endmodule
