`include "Opcode.vh"
`include "ALUop.vh"

module DataPath(
		input clk,
		input stall,
		input reset,
		input SIn,
		output SOut,
		//All the outputs from Control

		//Original Control unit Outputs 
		input memToReg,
		input regWrite,
		input extType,
		input ALUsrc,
		input regDst,
		input [3:0] ALUop,
		input jump,
		input jr,
		input jal,
		input jalr,
		input shift,

		//Write Ctr output 
		input [3:0] dataMemWriteEn,

		//Write Ctr output 
		input [3:0] instrMemWriteEn,

		//Branch Ctr output 
		input branchCtr,

		//Hazard Ctr outputs 
		input FwdAfromMtoE,
		input FwdBfromMtoE,
		input FwdAfromMtoF,
		input FwdBfromMtoF,

		//UART Ctr outputs 
		input UARTCtr,
		input [31:0] UARTCtrOut,
		input DataInValid,
		input DataOutReady,

		//Original Control unit inputs 
		output reg [5:0] opcodeF,
		output reg [5:0] functF,
		//	output reg [31:0] ALUOutM,

		//FOR ALU input 
		//opcodeE
		output reg [5:0] functE,

		//Write Ctr Inputs for Data Memory 
		output reg [5:0] opcodeE,
		output reg [1:0] byteOffsetE,
		output reg [31:0] ALUOutE,

		//Write Ctr Inputs for Instr Memory 
		//opcodeE
		//byteoffsetE
		//ALUOutE

		//Branch Ctr Inputs 
		//output reg [5:0] opcodeE,
		output reg [31:0] rd1Fwd,
		output reg [31:0] rd2Fwd,

		//Hazard Ctr Inputs 
		output reg [4:0] rsF,
		output reg [4:0] rtF,
		output reg [4:0] rsE,
		output reg [4:0] rtE,
		output reg [4:0] waM,
		output reg regWriteM,

		//UART Ctr Inputs 
		//output reg [31:0] ALUOutE,
		output reg DataInReady,
		output reg DataOutValid,
		output reg [7:0] UARTDataOut
		//opcodeM
		);

   //--FOR ALU--
   
   //~Inputs~
   reg [31:0] 			 ALUinputA;
   reg [31:0] 			 ALUinputB;
   

   //~Outputs~
   wire [31:0] 			 ALUOut;
   //reg [31:0] 			 ALUOutE;
   //reg [31:0] 			 ALUOutM;
   

   //--FOR RegFile--
   
   //~Inputs~
   reg 				 regWriteF;
   reg [4:0] 			 ra1;
   reg [4:0] 			 ra2;
   reg [4:0] 			 regWA; 			 
   reg [31:0] 			 regWD;

   //~Outputs~
   wire [31:0] 			 rd1;
   wire [31:0] 			 rd2;
   reg [31:0] 			 rd1F;
   reg [31:0] 			 rd2F;
   

   //--FOR Data Memory--

   //~Inputs~
   reg [11:0] 			 dataMemAddr;
   reg [31:0] 			 dataMemIn; //also for Instr Mem

   //~Outputs~
   wire [31:0] 			 dataMemOut;
   reg [31:0] 			 dataMemOutM;

   //--FOR Data Memory Mask (IN)--
   //~Inputs~
   // reg [31:0] 			 ALUOutE;
   // reg [5:0] 			 opcodeE;
   wire [31:0] 			 dataInMasked;
   
   //--FOR Data Memory Mask (OUT)--

   //~Inputs~
   reg [5:0] 			 opcodeM;
   reg [1:0] 			 byteOffsetM;
   
   
   //~Output~
   wire [31:0] 			 dataMemMasked;
   //reg [31:0] 			 dataMemMaskedM;
   
   //--FOR Instruction Memory --
   
   //~Inputs~
   reg [11:0] 			 instrMemAddr;


   //~Outputs~
   wire [31:0] 			 instrMemOut;


   //-- FOR Instr Decoder--

   //~Input~
   reg [31:0] 			 DecIn;

   //~Outputs~
   wire [5:0] 			 DecOpcode;
   //reg opcodeF already defined
   
   wire [5:0] 			 DecFunct;
   //reg functF already defined
   
   wire [4:0] 			 DecRs;
   //reg rsF already defined
   
   wire [4:0] 			 DecRt;
   //reg rtF already defined 
   
   wire [4:0] 			 DecRd;
   reg [4:0] 			 rdF;
   
   wire [4:0] 			 DecShamt;
   // reg [4:0] 			 shamtF;
   
   wire [15:0] 			 DecImmediate;
   //reg [15:0] 			 immediateF;
   
   wire [25:0] 			 DecTarget;
   reg [25:0] 			 targetF;
   
   //-- FOR UART --
   
   //~Inputs~
   reg [7:0] 			 UARTDataIn;
   reg 				 UARTDataInValid;
   wire 			 UARTDataInReady;
   wire [7:0] 			 UARTDOut;
   wire 			 UARTDataOutValid;
   reg 				 UARTDataOutReadyM;
   
   
   //Instantiating ALU
   ALU ArithLogicUnit(
		      //Inputs
		      .A(ALUinputA),
		      .B(ALUinputB),
		      .ALUop(ALUop),
		      //Outputs
		      .Out(ALUOut));

   //Instantiating RegFile
   RegFile Regfile(
		   //Inputs
		   .clk(clk),
		   .we(regWriteM),
		   .ra1(ra1),
		   .ra2(ra2),
		   .wa(regWA),
		   .wd(regWD),
		   //Outputs
		   .rd1(rd1),
		   .rd2(rd2));

   //Instantiating Data Memory In
   DataInMask DataInMasked(
			   //Inputs
			   .DataMemIn(dataMemIn),
			   .opcode(opcodeE),
			   .byteOffset(byteOffsetE),
			   //Output
			   .DataInMasked(dataInMasked));
   
   //Instantiating Data Memory
   dmem_blk_ram DataMemory(
			   //Inputs
			   .clka(clk),
			   .ena(!stall),
			   .wea(dataMemWriteEn),
			   .addra(dataMemAddr),
			   .dina(dataInMasked), //CHANGED
			   //Output
			   .douta(dataMemOut));

   
   
   
   //Instantiating Data Memory Out Mask
   DataOutMask DataMemMask(
			   //Inputs
			   .DataOutMem(dataMemOutM),
			   .opcode(opcodeM), //An output into an input?
			   .byteOffset(byteOffsetM),
			   //Output
			   .DataOutMasked(dataMemMasked));
   
   //Instantiating Instruction Memory
   imem_blk_ram InstrMemory(
			    //Inputs
			    .clka(clk),
			    .ena(!stall),
			    .wea(instrMemWriteEn),
			    .addra(instrMemAddr),
			    .dina(dataInMasked),
			    .clkb(clk),
			    .addrb(instrMemAddr),
			    //Output
			    .doutb(instrMemOut));

   InstrDecoder InstructionDecoder(
				   //Inputs
				   .instruction(DecIn),
				   //Outputs
				   .opcode(DecOpcode),
				   .funct(DecFunct),
				   .rs(DecRs),
				   .rt(DecRt),
				   .rd(DecRd),
				   .shamt(DecShamt),
				   .immediate(DecImmediate),
				   .target(DecTarget));

   UART UARTModule(
		   //Inputs
		   .Clock(clk),
		   .Reset(reset),
		   .DataIn(UARTDataIn), //Should it be DataInMasked?
		   .DataInValid(UARTDataInValid),
		   //Output
		   .DataInReady(UARTDataInReady),
		   .DataOut(UARTDOut),
		   .DataOutValid(UARTDataOutValid),
		   //Input
		   .DataOutReady(UARTDataOutReadyM),
		   .SIn(SIn),
		   //Output
		   .SOut(SOut)
		   );
   
   
   
   reg [31:0] 			 PC;
   reg [31:0] 			 nextPC;
   

   //=================FETCH==================//

   reg [31:0] 			 immediateFSigned;
   reg [31:0] 			 immediateESigned;
   reg [31:0] 			 shamtF;
   reg [31:0] 			 shamtE;
 			 
   

   reg 				 memToRegF;
   //reg 				 regWriteF;
   reg 				 extTypeF;
   reg 				 ALUsrcF;
   reg 				 regDstF;
   reg 				 jF; 				 
   reg 				 jrF;
   reg 				 jalF;
   reg 				 jalrF;
   reg 				 shiftF;
   reg [31:0] 			 pcF;
   
   reg 				 regWriteE;
   reg [25:0] 			 targetE;
   reg 				 jE;  
   reg 				 jrE;
   reg 				 jalE;
   reg 				 jalrE;
   reg [31:0] 			 writeBack;

   reg [31:0] 			 rd1E;
   reg [31:0] 			 rd2E;

   reg [31:0] 			 ALUOutM;

   

   reg 				 resetClocked;   
   //Ensure that signals update @ first clock cycle after reset
   //(combinatorially)
   always @(posedge clk)
     resetClocked <= reset;
   
   
   //Assign control signals to appropriate registers
   always@(*) begin
   
      if (!resetClocked) begin //& !stall) begin     
	 memToRegF = memToReg;
	 regWriteF = regWrite;
	 extTypeF = extType;
	 ALUsrcF = ALUsrc;

	 regDstF = regDst;
	 jF = jump;	 
	 jrF = jr;
	 jalF = jal;
	 jalrF = jalr;
	 shiftF = shift;
	 //end else begin//if (resetClocked) begin
      end else begin
	 memToRegF = 0;
	 regWriteF = 0;
	 extTypeF = 0;
	 ALUsrcF = 0;
	 regDstF = 0;
	 jF = 0;
	 jrF = 0;
	 jalF = 0;
	 jalrF = 0;
	 shiftF = 0;
      end
     // end else begin // if (stall)
	 /*
	  * memToRegF = memToRegF;
	 regWriteF = regWriteF;
	 extTypeF = extTypeF;
	 ALUsrcF = ALUsrcF;
	 regDstF = regDstF;
	 jF = jF;
	 jrF = jrF;
	 jalF = jalF;
	 jalrF = jalrF;
	  */
	 // if (!resetClocked & !stall)
	 
	 //end   
      //end
   end
      
   //The Logic/Muxes/Clk Driving the Program Counter and Instruction Memory
   always@(posedge clk) begin
       if (stall)
      	PC <= PC;
      else if (reset) 
	PC <= 0;
      else
	PC <= nextPC;
      
   end // always@ (posedge clk)

   

   //Combinatorial logic determining nextPC
   always@(*) begin
      //CHECK ME
      if (stall) begin
	 nextPC = nextPC;
	 instrMemAddr = instrMemAddr;
      end else if (resetClocked) begin
	 nextPC = 0;
	 instrMemAddr = 0;
      end else if (branchCtr) begin
	 nextPC =  PC + $signed(immediateESigned<<2);
	 instrMemAddr = nextPC[13:2];
      end else if (jE) begin
	 nextPC = {PC[31:28], targetE, 2'b0};
	 instrMemAddr = nextPC[13:2];
      end else if (jrE || jalrE) begin
	 nextPC = rd1E;
	 instrMemAddr = nextPC[13:2];
      end else begin
	 nextPC = PC + 4;
	 instrMemAddr = nextPC[13:2];
      end
   end

   //Combinatorial logic linking Instruction Memory to Decoder
   always@(*) begin
      DecIn = instrMemOut;
   end   
   
   //Combinatorial logic for sign extension
   always@(*) begin
      //Clock variables to Datapath after reset
      //if (!resetClocked & !stall) begin
      // if (!resetClocked)
      //if (!resetClocked) begin
      opcodeF = DecOpcode;
      functF = DecFunct;
      rsF = DecRs;
      rtF = DecRt;
      rdF = DecRd;
      shamtF = {27'b0, DecShamt};
      //immediateF = DecImmediate;
      //If sign-extended and most significant bit is a 1, sign extend
      //Otherwise, just zero-extend
      targetF = DecTarget;
      pcF = PC;
      //end
      //end // always@ (posedge clk)

      immediateFSigned = ((extTypeF == 0) && (DecImmediate[15] == 1'b1))?
			 {16'hffff, DecImmediate} : {16'b0, DecImmediate};
   end

   
   
   //Combinatorial logic fed into and out of RegFile 
   always@(*) begin
      ra1 = rsF;
      ra2 = rtF;
      rd1F = (FwdAfromMtoF)? writeBack: rd1;
      rd2F = (FwdBfromMtoF)? writeBack: rd2;
   end

   //=================PipeLineFE=================//

   reg 				 memToRegE;
   reg 				 extTypeE;
   reg 				 ALUsrcE;
   reg 				 regDstE;
   reg 				 shiftE;
   //reg [3:0] 			 ALUopE;
   
   

   //transfering control signals   
   always@(posedge clk) begin
      if (!reset && !stall) begin	 
	 memToRegE <= memToRegF;
	 regWriteE <= regWriteF;
	 extTypeE <= extTypeF;
	 ALUsrcE <= ALUsrcF;
	 regDstE <= regDstF;
	 jE <= jF;
	 jrE <= jrF;
	 jalE <= jalF;	
	 jalrE <= jalrF;
	 shiftE <= shiftF;
	 // end else begin 
	 //	 regWriteE <= 0;	 
	 //end
      end else if (reset) begin // if (!reset & !stall)
	 memToRegE <= 0;
	 regWriteE <= 0;
	 extTypeE <= 0;
	 ALUsrcE <= 0;
	 regDstE <= 0;
	 jE <= 0;
	 jrE <= 0;
	 jalE <= 0;
	 jalrE <= 0;
	 shiftE <= 0;
      end else begin // if (rest)
      	 memToRegE <= memToRegE;
	 regWriteE <= regWriteE;
	 extTypeE <= extTypeE;
	 ALUsrcE <= ALUsrcE;
	 regDstE <= regDstE;
	 jE <= jE;
	 jrE <= jrE;
	 jalE <= jalE;
	 jalrE <= jalrE;
	 shiftE <= shiftE;
      end
      
   end
   
   // reg [5:0] opcodeE;
   //reg [5:0] functE;
   // reg [4:0] rsE;
   // reg [4:0] rtE;
   reg [4:0] rdE;
   reg [31:0] pcE;
   //reg [31:0] rd1Fwd;
   //reg [31:0] rd2Fwd;
   
   
   //transfering non-control signals
   always@(posedge clk) begin
      if (!reset && !stall) begin
	 opcodeE <= opcodeF;
	 functE <= functF;
	 rsE <= rsF;
	 rtE <= rtF;
	 rdE <= rdF;
	 rd1E <=  rd1F;
	 rd2E <= rd2F;
	 targetE <= targetF;
	 immediateESigned <= immediateFSigned;
	 pcE <= pcF;
	 shamtE <= shamtF;
      end else if (reset) begin
	 opcodeE <= 0;
	 functE <= 0;
	 rsE <= 0;
	 rtE <= 0;
	 rdE <= 0;
	 rd1E <=  0;
	 rd2E <= 0;
	 targetE <= 0;
	 immediateESigned <= 0;
	 pcE <= 0;
	 shamtE <= 0;
      end else begin // if (reset)
	 opcodeE <= opcodeE;
	 functE <= functE;
	 rsE <= rsE;
	 rtE <= rtE;
	 rdE <= rdE;
	 rd1E <=  rd1E;
	 rd2E <= rd2E;
	 targetE <= targetE;
	 immediateESigned <= immediateESigned;
	 pcE <= pcE;
	 shamtE <= shamtE;
	 // ALUOutE <= ALUOut;
      end
   end
   
   //=================Execution==================//

   //Combinatorial logic to ALU inputs
   always@(*) begin
      rd1Fwd = (FwdAfromMtoE)? ALUOutM: rd1E;
      ALUinputA = (shiftE)? shamtE : rd1Fwd;     
      rd2Fwd = (FwdBfromMtoE)? ALUOutM : rd2E;
      ALUinputB = (ALUsrcE)? immediateESigned : rd2Fwd;
   end
   
   
   //Combinatorial logic after ALU
   always@(*) begin
      ALUOutE = ALUOut;
   end
   
   assign isLoadE =  (opcodeE == `LB) || (opcodeE == `LH) ||
		     (opcodeE == `LW) || (opcodeE == `LBU) ||
		     (opcodeE == `LHU);

   reg legalRead ;
   
   
   //To determine whether or not we have an illegal read access
   always@(*) begin

      legalRead = 0;
      
      if (isLoadE) begin
	 case(ALUOutE[31:28])
	   //Sucessful read in Data Memory or UART
	   4'b0001, 4'b0011, 4'b0101, 4'b0111, 4'b1000:
	     legalRead = 1;
	   /*
	    * default:
	     illegalRead= 0;
	    */
	 endcase // casez (ALUOutM[31:28])
      end

   end
    
   
   reg UARTCtrE;
   reg [31:0] UARTCtrOutE;
   

   //Combinatorial logic for dataWriteEn and instrWriteEn and UART
   always@(*) begin
      byteOffsetE = ALUOutE[1:0];
      UARTCtrE = UARTCtr;
      //UARTCtrOutE = UARTCtrOut;
      

      DataInReady = UARTDataInReady;
      DataOutValid = UARTDataOutValid;
      UARTDataOut = UARTDOut;
      
   end

   reg DataOutReadyE;
   reg DataOutReadyM;

   //Combinatorial logic for wires connecting UART Control to UART
   always@(*) begin
      UARTDataIn = rd2Fwd[7:0];
      UARTDataInValid = (stall)? 0: DataInValid;
      DataOutReadyE = DataOutReady;
   end


   //===============PipeLineEM==================//
   
   reg 				 memToRegM;
   //reg 				 regWriteM;
   // reg 				 extTypeM;
   // reg 				 ALUsrcM;
   reg 				 regDstM;
   // reg 				 jrM;
   reg 				 jalM;
   reg 				 jalrM;
   reg 				 UARTCtrM;
   reg [31:0] 			 UARTCtrOutM;


   
   
   //transfering control signals   
   always@(posedge clk) begin
      if (!reset && !stall) begin
	 memToRegM <= memToRegE;	 
	 regWriteM <= (!legalRead && isLoadE)? 0: regWriteE;
	 regDstM <= regDstE;
	 jalM <= jalE;
	 jalrM <= jalrE;
	 UARTCtrM <= UARTCtrE;
	 DataOutReadyM <= DataOutReadyE;
      end else if (reset) begin
	 memToRegM <= 0;
	 regWriteM <= 0;
	 regDstM <= 0;
	 jalM <= 0;
	 jalrM <= 0;
	 UARTCtrM <= 0;
	 //UARTCtrOutM <= 0;
      end else begin
	 memToRegM <= memToRegM;
	 regWriteM <= regWriteM;
	 regDstM <= regDstM;
	 jalM <= jalM;
	 jalrM <= jalrM;
	 UARTCtrM <= UARTCtrM;
      end
   end
   
   //reg [5:0] opcodeM;
   // reg [5:0] functM;
   // reg [4:0] rsM;
   reg [4:0] rtM;
   reg [4:0] rdM;
   // reg [31:0] rd1M;
   // reg [31:0] rd2M;
   // reg [31:0] immediateMSigned;
   reg [31:0] pcM;

   
   //   reg [31:0] ALUOutM;   
   //   reg [1:0]  byteOffsetM;

   //transfering non-control signals
   always@(posedge clk) begin
      if (!reset && !stall) begin
	 opcodeM <= opcodeE;
	 rtM <= rtE;
	 rdM <= rdE;
	 ALUOutM <= ALUOutE;
	 byteOffsetM <= byteOffsetE;
	 pcM <= pcE;
      end else if (reset) begin // if (!reset)
	 opcodeM <= 0;
	 rtM <= 0;
	 rdM <= 0;
	 ALUOutM <= 0;
	 byteOffsetM <= 0;
	 pcM <= 0;
      end else begin // if (stall)
	 opcodeM <= opcodeM;
	 rtM <= rtM;
	 rdM <= rdM;
	 ALUOutM <= ALUOutM;
	 byteOffsetM <= byteOffsetM;
	 pcM <= pcM;
      end     
   end

   //Data Memory inputs (NOT TOO SURE IF CORRECT)
   always@(*) begin
      dataMemIn = rd2Fwd;
      dataMemAddr = ALUOutE[13:2];
   end
   

   //=================Memory==================//

   //Combinatorial logic for all wires after Data Memory
   always@(*) begin
      waM = (regDstM)? rdM: rtM;
   end

   //Combinatorial logic after Data Memory Out to DataMemMask
   always@(*) begin
      dataMemOutM = dataMemOut;
      UARTDataOutReadyM = (stall)? 0: DataOutReadyM;
   end

   //Determining UART Control Out
   wire 				 isUARTM;
   wire [3:0] 				 UARTopM;
   wire 				 isLoadM;
   
   assign isUARTM = (ALUOutM[31:28] == 4'b1000);
   assign UARTopM = ALUOutM[3:0];
   assign isLoadM =  (opcodeM == `LB) || (opcodeM == `LH) ||
		     (opcodeM == `LW) || (opcodeM == `LBU) ||
		     (opcodeM == `LHU);
   always@(*) begin
      UARTCtrOutM = ALUOutM;
      
      if (isUARTM) begin
	 case (UARTopM)

	   //UART transmitter control
	   4'b0: begin
	      if (isLoadM) begin
		 UARTCtrOutM = {31'b0, UARTDataInReady};
	      end
	   end

	   //UART receiver control
	   4'b0100: begin
	      if (isLoadM) begin
		 UARTCtrOutM = {31'b0, UARTDataOutValid};
	      end
	   end   

	   //UART receiver data
	   4'b1100: begin
	      if (isLoadM) begin
		 UARTCtrOutM = {24'b0, UARTDOut};
	      end
	   end
	   
	 endcase // case (UARTop)
      end // if (isUART)
   end // always@ (*)
   
   //Write-back value to RegFile
   always@(*) begin
      if (!memToRegM) 
	writeBack = ALUOutM;
      else if (UARTCtrM)
	writeBack = UARTCtrOutM;
      else
	writeBack = dataMemMasked;
   end

   //Connecting write-back value to RegFile Write Port
   always@(*) begin
      regWD = (jalM || jalrM)? pcM + 8: writeBack;
      regWA = (jalM)? 31 : waM;
   end

  // ChipScope components:
   
   wire [35:0] chipscope_control;
   chipscope_icon icon(
		       .CONTROL0(chipscope_control)
		       ) /* synthesis syn_noprune=1 */;
   chipscope_ila ila(
   		     .CONTROL(chipscope_control),
		     .CLK(clk),
		     //.DATA({reset, stall, PC, nextPC, instrMemOut, instrMemWriteEn, branchCtr, rd1Fwd, rd2Fwd, ALUOutE, UARTDataIn, UARTDataOut, writeBack, regWriteM}),
		     .TRIG0({reset, stall, UARTDataInReady, UARTDataOutValid, SIn, SOut, UARTDOut, UARTDataOut, PC, dataMemOut, dataMemMasked, dataMemWriteEn, rd1Fwd, rd2Fwd, ALUOutE, writeBack, regWriteM, branchCtr, jE, jalE, shiftE, jalrE})
		     ) /* synthesis syn_noprune=1 */;
   

//, branchCtr, rd1Fwd, rd2Fwd, ALUOutE, UARTDataIn, UARTDataOut, writeBack,// regWriteM})
		     //) /* synthesis syn_noprune=1 */;

   
endmodule

