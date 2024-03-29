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

	       //UART CtrE Inputs
	       //input [31:0] ALUOutE,
	       input DataInReady,
	       input DataOutValid,
	       input [7:0] UARTDataOut,

	       //UART CtrM Inputs
	       input [31:0] ALUOutM,
	       input [5:0] opcodeM,
	       
	       //Needed for BIOS/Instr$
	       //ALUOutE  
	       input [31:0] PC,
	       input [31:0] pcE,
	       input [31:0] nextPC,

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

	       //Write Ctr Output for ISR
	       output [3:0] ISR_MemWriteEn,

	       //Branch Ctr Outputs
	       output branchCtr,
	       
	       //Hazard Ctr outputs
	       output FwdAfromMtoE,
	       output FwdBfromMtoE,
	       output FwdAfromMtoF,
	       output FwdBfromMtoF,

	       //UART Ctr outputs
	       output UARTCtr,
	       output [31:0] UARTCtrOutM,
	       output DataInValid,
	       output DataOutReady,

	       //isLoad Signal
	       output isLoadE,
	       output reg legalReadE,

	       //BIOS + instr$ outputs
	       output isBIOS_Data,  enPC_BIOS, enData_BIOS,
	       output reg [1:0] instrSrc,
	       output dcache_re_Ctr, icache_re_Ctr,

	       //Mem I/O Counters
	       output readCycleCount, readInstrCount, resetCounters,
	       
	       //FOR CP0
	       output mtc0, mfc0, causeDelaySlot,

	       //FOR Graphics Processor
	       output readFrameCount, readPixelFrame
	       
	       );

   ALUdec ALUdecoder(
		     .funct(functE),
		     .opcode(opcodeE),
		     .ALUop(ALUop)
		     );

   //Data Memory
   WriteEnCtr MemWriteEnCtr(.opcode(opcodeE),
			    .byteOffset(byteOffsetE),
			    //.AddrPartition(4'b0zz1),
			    .ALUOut(ALUOutE),
			    .stall(stall),
			    .PC(PC),
			    .pcE(pcE),
			    .dataMemWriteEn(dataMemWriteEn),
			    .instrMemWriteEn(instrMemWriteEn),
			    .ISR_MemWriteEn(ISR_MemWriteEn));
   
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

   UARTCtr UARTControlE(//Inputs
			.ALUOut(ALUOutE),
			.opcode(opcodeE),
			.DataInReady(DataInReady),
			.DataOutValid(DataOutValid),
			.UARTDataOut(UARTDataOut),
			//Outputs
			.DataInValid(DataInValid),
			.DataOutReady(DataOutReady),
			.UARTCtr(UARTCtr),
			.UARTCtrOut());

   UARTCtr UARTControlM(//Inputs
			.ALUOut(ALUOutM),
			.opcode(opcodeM),
			.DataInReady(DataInReady),
			.DataOutValid(DataOutValid),
			.UARTDataOut(UARTDataOut),
			//Outputs
			.DataInValid(),
			.DataOutReady(),
			.UARTCtr(),
			.UARTCtrOut(UARTCtrOutM));
			    

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
	   
	end // case: `BEQ, `BNE, `BLEZ, `BGTZ, `BLTZ, `BGEZ

	`mtc0, `mfc0: begin
	   if (rsF == 5'b0) begin //mfc0
	      memToReg = 0;
	      regWrite = 1;
	      extType = 0;
	      ALUsrc = 0;
	      regDst = 0;
	      jump = 0;
	      jr = 0;
	      jal = 0;
	      jalr = 0;
	      shift = 0;
	   end else begin //mtc0
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
	   end // else: !if(rsF == 5'b0)
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
      
   end // always @ (*)

   assign isLoadE =  (opcodeE == `LB) || (opcodeE == `LH) ||
		     (opcodeE == `LW) || (opcodeE == `LBU) ||
		     (opcodeE == `LHU);
   
   //Assigning BIOS/I$ Control Signals
   assign enPC_BIOS = (PC[31:28] == 4'b0100);
 //&& (~stall);
   assign enData_BIOS = (ALUOutE[31:28] == 4'b0100) && (isLoadE);
   assign isBIOS_Data = enData_BIOS;
   
   always@(*) begin
      case (PC[31:28])
	4'b0001: //Instruction
	  instrSrc = 2'b00;

	4'b0100: //BIOS
	  instrSrc = 2'b01;

	4'b1100: //ISR
	  instrSrc = 2'b10;

	default: //is BIOS
	  instrSrc = 2'b01;
	
      endcase // case (PC[31:28])
   end
   
   //To determine whether or not we have an illegal read access
   always@(*) begin

      legalReadE = 0;
      
      if (isLoadE) begin
	 case(ALUOutE[31:28])
	   //Sucessful read in D$ or BIOS or UART
	   4'b0001, 4'b0011, 4'b0100, 4'b1000:
	     legalReadE = 1;
	   /*
	    * default:
	    illegalRead= 0;
	    */
	 endcase // casez (ALUOutM[31:28])
      end

   end // always@ (*)

   assign dcache_re_Ctr = (ALUOutE[31] == 1'b0) && (isLoadE) && 
			  (ALUOutE[30] == 1'b0) && (ALUOutE[28] == 1'b1);

   assign icache_re_Ctr = (PC[31:28] == 4'b0001) || (nextPC[31:28] == 4'b0001);

   assign readCycleCount = (ALUOutE == 32'h80000010) & isLoadE;
   assign readInstrCount = (ALUOutE == 32'h80000014) & isLoadE;
   assign resetCounters = (ALUOutE == 32'h80000018) & isLoadE;
   
   //Logic for mtc0 and mfc0

   assign mfc0 = (opcodeF == `mfc0) & (rsF == 5'b0);
   assign mtc0 = (opcodeF == `mtc0) & (rsF == 5'b00100);

   assign causeDelaySlot = (opcodeF == `BEQ) ||
			   (opcodeF == `BNE) ||
			   (opcodeF == `BLEZ) ||
			   (opcodeF == `BGTZ) ||
			   (opcodeF == `BLTZ) ||
			   (opcodeF == `BGEZ) ||
			   (opcodeF == `J) ||
			   (opcodeF == `JAL) ||
			   (opcodeF == `RTYPE && functF == `JR) ||
			   (opcodeF == `RTYPE && functF == `JALR) ||
			   (mfc0) || (mtc0)
			   ;

   assign readFrameCount = (ALUOutE == 32'h8000001c) & isLoadE;
   assign readPixelFrame = (ALUOutE == 32'h80000020) & isLoadE;

   
endmodule
	  
