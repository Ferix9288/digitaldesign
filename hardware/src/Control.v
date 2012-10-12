`include "Opcode.vh"
`include "ALUop.vh"

module Control(
	       //Original Control unit inputs
	       input [5:0] opcodeF,
	       input [5:0] functF,

	       //Write Ctr Inputs for Data Memory
	       input [5:0] opcodeM,
	       input [1:0] byteOffsetM,
	       //ALUOutM

	       //Write Ctr Inputs for Instr Memory
	       //opcodeM,
	       //byteOffsetM,
	       //ALUOutM

	       //Branch Ctr Inputs
	       input [5:0] opcodeE,
	       input [31:0] rd1E,
	       input [31:0] rd2E,

	       //Hazard Ctr Inputs
	       input [4:0] rsF,
	       input [4:0] rtF,
	       input [4:0] rsE,
	       input [4:0] rtE,
	       input [4:0] waM,
	       input regWriteM,

	       //UART Ctr Inputs
	       input [31:0] ALUOutM,
	       input DataInReady,
	       input DataOutValid,
	       input [7:0] UARTDataOut,
	       //opcodeM

	       //Original Control unit outputs
	       output reg memToReg,
	       output reg regWrite,
	       output reg extType,
	       output reg ALUsrc,
	       output reg regDst,
	       output  [3:0] ALUop,
	       output reg jump,
	       output reg jr,
	       output reg jal,

	       //Write Ctr Output for Data Memory
	       output [3:0] dataMemWriteEn,

	       //Write Ctr Output for Instr Memory
	       output [3:0] instrMemWriteEn,

	       //Branch Ctr Outputs
	       output branchCtr,
	       
	       //Hazard Ctr outputs
	       output FwdAfromMtoE,
	       output FwdBfromMtoE,
	       output FwdAfromMtoF,
	       output FwdBfromMtoF,

	       //UART Ctr outputs
	       output UARTCtr,
	       output UARTCtrOut,
	       output DataInValid,
	       output DataOutReady


	       );

   ALUdec ALUdecoder(
		     .funct(funct),
		     .opcode(opcode),
		     .ALUop(ALUop)
		     );

   //Data Memory
   WriteEnCtr DataMemWriteEnCtr(.opcode(opcodeM),
				.byteOffset(byteOffsetM),
				.AddrPartition(4'b0zz1),
				.ALUOut(ALUOutM),
				.writeEn(dataMemWriteEn));

   //Instruction Memory
   WriteEnCtr InstrMemWriteEnCtr(.opcode(opcodeM),
				 .byteOffset(byteOffsetM),
				 .AddrPartition(4'b0z1z),
				 .ALUOut(ALUOutM),
				 .writeEn(instrMemWriteEn));
   
   
   BranchCtr BranchControl(.opcode(opcodeE),
			   .rd1(rd1E),
			   .rd2(rd2E),
			   .branchCtr(branchCtr));

   HazardCtr HazardControl(.rsF(rsF),
			   .rtF(rtF),
			   .rsE(rsE),
			   .rtE(rtE),
			   .waM(waM),
			   .regWriteM(regWriteM),
			   .FwdAfromMtoE(FwdAfromMtoE),
			   .FwdBfromMtoE(FwdBfromMtoE),
			   .FwdAfromMtoF(FwdAfromMtoF),
			   .FwdBfromMtoF(FwdBfromMtoF));

   UARTCtr UARTControl(.ALUOut(ALUOutM),
		       .DataInReady(DataInReady),
		       .DataOutValid(DataOutValid),
		       .UARTDataOut(UARTDataOut),
		       .opcode(opcodeM),
		       .DataInValid(DataInValid),
		       .DataOutReady(DataOutReady),
		       .UARTCtrOut(UARTCtrOut),
		       .UARTCtr(UARTCtr));
     


   
   always @(*) begin
            
      case(opcode)
	`RTYPE: begin
	   memToReg = 0;
	   //memWrite = 0;
	   regWrite = (funct == `JR)? 0:1;
	   extType = 0;
	   ALUsrc = 0;
	   regDst = 1;
	   jump = 0;	      
	   jr = (funct == `JR | funct == `JALR)? 1:0;
	   jal = (funct == `JALR)? 1:0;
	end

	`LB, `LH, `LW, `LBU, `LHU: begin
	   memToReg = 1;
	   //memWrite = 0;
	   //To determine whether or not we have an illegal read access
	   casez(ALUOutM[31:28])
	     4'b0zz1 || 4'b1000: //Sucessful read in Data Memory or UART
	       regWrite = 1;
	     default:
	       regWrite = 0;
	   endcase

	   extType = 0;
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
	   ALUsrc = 0;
	   regDst = 0;
	   jump = 0;
	   jr = 0;
	   jal = 0;
	end
   
	   
      endcase
   end  
endmodule
	  
