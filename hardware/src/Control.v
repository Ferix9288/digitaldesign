`include "Opcode.vh"
`include "ALUop.vh"

module Control(input [5:0] opcode,
	       input [5:0] funct,
	       output reg memToReg,
	      // output reg [3:0] memWrite,
	       output reg regWrite,
	       output reg extType,
	       output reg branchCtr,
	       output reg ALUsrc,
	       output reg regDst,
	       output reg [3:0] ALUop,
	       output reg jump,
	       output reg jr,
	       output reg jal);

   ALUDecoder ALUdec(
		     .funct(funct),
		     .opcode(opcode),
		     .ALUop(ALUop)
		     );

   //if not included, then don't care
   
   always @(*) begin
            
      case(opcode)
	`RTYPE: begin
	   memToReg = 0;
	   //memWrite = 0;
	   regWrite = (funct == `JR)? 0:1;
	   extType = 0;
	   branchCtr = 0;
	   ALUsrc = 0;
	   regDst = 1;
	   jump = (funct == `JR | funct == `JALR)? 1:0;	      
	   jr = (funct == `JR | funct == `JALR)? 1:0;
	   jal = (funct == `JALR)? 1:0;
	end

	`LB, `LH, `LW, `LBU, `LHU: begin
	   memToReg = 1;
	   //memWrite = 0;
	   regWrite = 1;
	   extType = 0;
	   branchCtr = 0;
	   ALUsrc = 1;
	   regDst = 0;
	   jump = 0;
	   jr = 0;
	   jal = 0;
	end // case: `LB, `LH, `LW, `LBU, `LHU

	`SB, `SH, `SW: begin
	   memToReg = 1;
	   //memWrite = 1;
	   regWrite = 0;	   
	   extType = 0;
	   branchCtr = 0;
	   ALUsrc = 1;
	   regDst = 0;
	   jump = 0;
	   jr = 0;
	   jal = 0;
	end // case: `SB, `SH, `SW
	
	 `ADDIU, `SLTI, `SLTIU: begin
	    memToReg = 0;
	    //memWrite = 0;
	    regWrite = 1;
	    extType = 0;
	    branchCtr = 0;
	    ALUsrc = 1;
	    regDst = 0;
	    jump = 0;
	    jr = 0;
	    jal = 0;
	 end
	    
	   
	`ANDI, `ORI, `XORI: begin
	   memToReg = 0;
	   //memWrite = 0;
	   regWrite = 1;
	   extType = 1;
	   branchCtr = 0;
	   ALUsrc = 1;
	   regDst = 0;
	   jump = 0;
	   jr = 0;
	   jal = 0;
	end // case: `ANDI, `ORI, `XORI

	`LUI: begin
	   memToReg = 0;
	   //memWrite = 0;
	   regWrite = 1;	   
	   extType = 0;
	   branchCtr = 0;
	   ALUsrc = 1;
	   regDst = 0;
	   jump = 0;
	   jr = 0;
	   jal = 0;
	end // case: `LUI

	`J: begin
	   memToReg = 0;
	   //memWrite = 0;
	   regWrite = 0;	   
	   extType = 0;
	   branchCtr = 0;
	   ALUsrc = 0;
	   regDst = 0;
	   jump = 1;
	   jr = 0;
	   jal = 0;
	end // case: `J

	`JAL: begin
	   memToReg = 0;
	   //memWrite = 0;
	   regWrite = 1;
	   extType = 0;
	   branchCtr = 0;
	   ALUsrc = 0;
	   regDst = 1;
	   jump = 1;
	   jr = 0;
	   jal = 1;
	end // case: `JAL

	`BEQ, `BNE, `BLEZ, `BGTZ, `BLTZ, `BGEZ: begin
	   memToReg = 0;
	  // memWrite = 0;
	   regWrite = 0;
	   extType = 0;
	   branchCtr = 1;
	   ALUsrc = 0;
	   regDst = 0;
	   jump = 0;
	   jr = 0;
	   jal = 0;
	end
   
	   
      endcase
   end  
endmodule
	  
