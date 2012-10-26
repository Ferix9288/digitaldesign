`include "Opcode.vh"
`include "ALUop.vh"

module Control(
	      // input reset,
	       //Original Control Unit Inputs
	       input stall,
	       input [5:0] opcodeF,
	       input [5:0] functF,
	      // input [31:0] ALUOutM,

	       //For ALU
	       input [5:0] functE,
	       
	       //Write Ctr Inputs for Data Memory
	       input [5:0] opcodeE,
	       input [1:0] byteOffsetE,
	       input [31:0] ALUOutE,

	       //Write Ctr Inputs for Instr Memory
	       //opcodeE,
	       //byteOffsetE,
	       //ALUOutE

	       //Branch Ctr Inputs
	       //input [5:0] opcodeE,
	       input [31:0] rd1Fwd,
	       input [31:0] rd2Fwd,
	       //input [31:0] rd1Fwd,
	       //input [31:0] rd2Fwd,

	       //Hazard Ctr Inputs
	       input [4:0] rsF,
	       input [4:0] rtF,
	       input [4:0] rsE,
	       input [4:0] rtE,
	       input [4:0] waM,
	       input regWriteM,

	       //UART Ctr Inputs
	       //input [31:0] ALUOutE,
	       input DataInReady,
	       input DataOutValid,
	       input [7:0] UARTDataOut,
	       //opcodeM

	       //Needed for BIOS/Instr$
	       //ALUOutE  
	       input [31:0] PC,

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
	       output reg jalr,
	       output reg shift,

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
	       output [31:0] UARTCtrOut,
	       output DataInValid,
	       output DataOutReady,

	       //isLoad Signal
	       output isLoadE,
	       output reg legalReadE,

	       //BIOS + instr$ outputs
	       output isBIOS_Data, instrSrc, enPC_BIOS, enData_BIOS
	       


	       );

   ALUdec ALUdecoder(
		     .funct(functE),
		     .opcode(opcodeE),
		     .ALUop(ALUop)
		     );

   //Data Memory
   WriteEnCtr DataMemWriteEnCtr(.opcode(opcodeE),
				.byteOffset(byteOffsetE),
				//.AddrPartition(4'b0zz1),
				.ALUOut(ALUOutE),
				.stall(stall),
				.dataMemWriteEn(dataMemWriteEn),
				.instrMemWriteEn(instrMemWriteEn));

   /*
    * //Instruction Memory
   WriteEnCtr InstrMemWriteEnCtr(.opcode(opcodeE),
				 .byteOffset(byteOffsetE),
				 .AddrPartition(4'b0z1z),
				 .ALUOut(ALUOutE),
				 .writeEn(instrMemWriteEn));
    */
   
   
   BranchCtr BranchControl(.opcode(opcodeE),
			   .rd1(rd1Fwd),
			   .rd2(rd2Fwd),
			   .rtE(rtE),
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

   UARTCtr UARTControl(.ALUOut(ALUOutE),
		       .DataInReady(DataInReady),
		       .DataOutValid(DataOutValid),
		       .UARTDataOut(UARTDataOut),
		       .opcode(opcodeE),
		       .DataInValid(DataInValid),
		       .DataOutReady(DataOutReady),
		       .UARTCtrOut(UARTCtrOut),
		       .UARTCtr(UARTCtr));
   
      
   always @(*) begin
      
	
      case(opcodeF)
	`RTYPE: begin
	   memToReg = 0;
	   //memWrite = 0;
	   regWrite = (functF == `JR)? 0:1;
	   extType = 0;
	   ALUsrc = 0;
	   regDst = 1;
	   jump = 0;	      
	   jr = (functF == `JR)? 1:0;
	   jal = 0;
	   jalr = (functF == `JALR)? 1:0;
	   case(functF)
	     `SLL, `SRL, `SRA:
	       shift = 1;
	     default:
	       shift = 0;
	   endcase
	end

	`LB, `LH, `LW, `LBU, `LHU: begin
	   memToReg = 1;
	   //memWrite = 0;
	   regWrite = 1;	   
	   extType = 0;
	   ALUsrc = 1;
	   regDst = 0;
	   jump = 0;
	   jr = 0;
	   jal = 0;
	   jalr = 0;
	   shift = 0;
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
	   jalr = 0;
	   shift = 0;
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
	    jalr = 0;
	    shift = 0;
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
	   jalr = 0;
	   shift = 0;
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
	   jalr = 0;
	   shift = 0;
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
	   jalr = 0;
	   shift = 0;
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
	   jalr = 0;
	   shift = 0;
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
	   jalr = 0;
	   shift = 0;
	end

	default: begin
	   memToReg = 0;
	   regWrite = 0;
	   extType = 0;
	   ALUsrc = 0;
	   regDst = 0;
	   jump = 0;
	   jr = 0;
	   jal = 0;
	   jalr = 0;
	   shift = 0;
	end
	
      endcase // case (opcodeF)
      
      /*
       * if (reset) begin
	 ALUsrc = x;
	 jump = x;
	 jr = x;
	 jal = x;
	 
      end
       */
   end // always @ (*)

   assign isLoadE =  (opcodeE == `LB) || (opcodeE == `LH) ||
		     (opcodeE == `LW) || (opcodeE == `LBU) ||
		     (opcodeE == `LHU);
   
   //Assigning BIOS/I$ Control Signals
   assign enPC_BIOS = (PC[31:28] == 4'b0100);
   assign enData_BIOS = (ALUOutE[31:28] == 4'b0100);
   assign isBIOS_Data = enData_BIOS && (isLoadE);
   assign instrSrc = enPC_BIOS;
 
   
   //To determine whether or not we have an illegal read access
   always@(*) begin

      legalReadE = 0;
      
      if (isLoadE) begin
	 case(ALUOutE[31:28])
	   //Sucessful read in Data Memory or UART
	   4'b0001, 4'b0011, 4'b0101, 4'b0111, 4'b1000, 4'b0100:
	     legalReadE = 1;
	   /*
	    * default:
	    illegalRead= 0;
	    */
	 endcase // casez (ALUOutM[31:28])
      end

   end
    
endmodule
	  
