`include "Opcode.vh"
`include "ALUop.vh"

module DataPath(
		input clk,
		input stall,
		input reset,
		input SIn,
		output SOut,

		//Cache Outputs
		output reg [31:0] dcache_addr,
		output reg [31:0] icache_addr,
		output reg [3:0] dcache_we,
		output reg [3:0] icache_we,
		output reg icache_re, dcache_re,
		output reg [31:0] dcache_din,
		output reg [31:0] icache_din,

		//Cache Inputs
		input [31:0] dcache_dout,
		input [31:0] instruction,
		
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
		input [31:0] UARTCtrOutM,
		input DataInValid,
		input DataOutReady,

		//isLoad Output
		input isLoadE,
		input legalReadE,
		
		//BIOS+Instr$ outputs
		input isBIOS_Data, instrSrc, enPC_BIOS, enData_BIOS,
		input dcache_re_Ctr, icache_re_Ctr,

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

		//UART CtrE Inputs 
		//output reg [31:0] ALUOutE,
		output reg DataInReady,
		output reg DataOutValid,
		output reg [7:0] UARTDataOut,

		//UART CtrM Inputs
		output reg [31:0] ALUOutM,
		output reg [5:0] opcodeM,

		//Needed for BIOS/Instr$
		output reg [31:0] PC,
		output reg [31:0] pcE
		//opcodeM
		);

   //--FOR ALU--
   
   //~Inputs~
   reg [31:0] 			 ALUinputA;
   reg [31:0] 			 ALUinputB;
   

   //~Outputs~
   wire [31:0] 			 ALUOut;
   
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
   

   //--FOR Data In Mask --

   //~Inputs~
   reg [31:0] 			 dataMemIn_toMask;
   
   //--FOR Data Memory Mask (IN)--
   //~Inputs~
   wire [31:0] 			 dataInMasked;

   //--FOR BIOS Memory Out Mask --
   
   //~Inputs~
   //reg [5:0] 			 opcodeM;
   reg [1:0] 			 byteOffsetM;
   

   //~Output~				 
   wire [31:0] 			 Data_BIOSOut_Masked;


   //--FOR D$ Memory Out Mask --
   wire [31:0] 			 dcache_dout_Masked;
   
       
   //--FOR Instruction Memory --
   
   //~Inputs~
   //reg [11:0] 			 instrMemAddr_A;
   //reg [11:0] 			 instrMemAddr_B;


   //~Outputs~
   //wire [31:0] 			 instrMemOut;

   //--FOR BIOS Memory --

   //~Inputs~
   //wire 			 enPC_BIOS, enData_BIOS;
   reg [11:0] 			 addrPC_BIOS, addrData_BIOS;

   //~Outputs~
   wire [31:0] 			 PC_BIOSOut, Data_BIOSOut;
   

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
			   .DataMemIn(dataMemIn_toMask),
			   .opcode(opcodeE),
			   .byteOffset(byteOffsetE),
			   //Output
			   .DataInMasked(dataInMasked));

   
   /*
    * //Instantiating Data Memory
   dmem_blk_ram DataMemory(
			   //Inputs
			   .clka(clk),
			   .ena(~stall),
			   .wea(dataMemWriteEn),
			   .addra(dataMemAddr),
			   .dina(dataInMasked), //CHANGED
			   //Output
			   .douta(dataMemOut));
    */
    

   
   //Instantiating DataOutMask for BIOS Data
   DataOutMask BIOSMemMask(
			   //Inputs
			   .DataOutMem(Data_BIOSOut),
			   .opcode(opcodeM), //An output into an input?
			   .byteOffset(byteOffsetM),
			   .DataOutMasked(Data_BIOSOut_Masked));
   
   //Instantiating Data $ Out Mask
   DataOutMask DataCacheMask(//Inputs
			     .DataOutMem(dcache_dout),
			     .opcode(opcodeM),
			     .byteOffset(byteOffsetM),
			     .DataOutMasked(dcache_dout_Masked));
   
   
   /*
    * //Instantiating Data Memory Out Mask
   DataOutMask DataMemMask(
			   //Inputs
			   .DataOutMem(dataMemOutM),
			   .opcode(opcodeM), //An output into an input?
			   .byteOffset(byteOffsetM),
			   //Output
			   .DataOutMasked(dataMemMasked));
    */


   /*
    * //Instantiating Instruction Memory
   imem_blk_ram InstrMemory(
			    //Inputs
			    .clka(clk),
			    .ena(~stall),
			    .wea(instrMemWriteEn),
			    .addra(instrMemAddr_A),
			    .dina(dataInMasked),
			    .clkb(clk),
			    .addrb(instrMemAddr_B),
			    //Output
			    .doutb(instrMemOut));

    */

   //Instantiating BIOS Memory
   bios_mem BIOS(//inputs
		 .clka(clk),
		 .ena(enPC_BIOS),
		 .addra(addrPC_BIOS),
		 //output
		 .douta(PC_BIOSOut),
		 //inputs
		 .clkb(clk),
		 .enb(enData_BIOS),
		 .addrb(addrData_BIOS),
		 //output
		 .doutb(Data_BIOSOut));

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
   
   
   
   //reg [31:0] 			 PC;
   reg [31:0] 			 nextPC;
   //reg [31:0] pcE;
   

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
   
   reg 				 resetClocked; 
   reg 				 stallClocked;
				 
   //Ensure that signals update @ first clock cycle after reset
   //(combinatorially)
   always @(posedge clk) begin
      resetClocked <= reset;
      stallClocked <= stall;
   end
   
   
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
   end
      
   //The Logic/Muxes/Clk Driving the Program Counter and Instruction Memory
   always@(posedge clk) begin
      if (stall)
      	PC <= PC;
      else if (reset) 
	PC <= 32'h40000000;
      else
	PC <= nextPC;
      
   end // always@ (posedge clk)
   
   
   //Combinatorial logic determining nextPC
   //CHANGE STALLING TO FEEDBACK

   reg [31:0] nextPC_E;

   
   always@(*) begin
      if (resetClocked) begin
	 nextPC = 32'h40000000;
	 //instrMemAddr_B = 0;
	 addrPC_BIOS = 0;
      end else if (stall) begin
	 addrPC_BIOS = nextPC_E[13:2];
      end else if (branchCtr) begin
	 nextPC =  PC + $signed(immediateESigned<<2);
	 //instrMemAddr_B = nextPC[13:2];
	 addrPC_BIOS = nextPC[13:2];
      end else if (jE) begin
	 nextPC = {PC[31:28], targetE, 2'b0};
	 //instrMemAddr_B = nextPC[13:2];
	 addrPC_BIOS = nextPC[13:2];
      end else if (jrE || jalrE) begin
	 nextPC = rd1E;
	 //instrMemAddr_B = nextPC[13:2];
	 addrPC_BIOS = nextPC[13:2];
      end else begin
	 nextPC = PC + 4;
	 //instrMemAddr_B = nextPC[13:2];
	 addrPC_BIOS = nextPC[13:2];

      end
   end // always@ (*)
   

   
   //Combinatorial logic to hook up PC to BIOS and Instr $
   always@(*) begin
      //addrPC_BIOS = (stall)? nextPC_E[13:2] : addrPC_BIOS;      
      addrData_BIOS = ALUOutE[13:2];
   end
   
   //Combinatorial logic linking BIOS/Instruction Memory to Decoder
   always@(*) begin
      DecIn = (instrSrc)? PC_BIOSOut : instruction;
   end   
   
   //Combinatorial logic for sign extension
   always@(*) begin
      opcodeF = DecOpcode;
      functF = DecFunct;
      rsF = DecRs;
      rtF = DecRt;
      rdF = DecRd;
      shamtF = {27'b0, DecShamt};
   
      //If sign-extended and most significant bit is a 1, sign extend
      //Otherwise, just zero-extend
      targetF = DecTarget;
      pcF = PC;
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
	 nextPC_E <= nextPC;
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
	 nextPC_E <= 0;
	 shamtE <= 0;
      end else begin // if (stall asserted)
	 opcodeE <= opcodeE;

	 //opcodeE <= opcodeM;
	 //ALUOutE <= ALUOutM;
	 
	 functE <= functE;
	 rsE <= rsE;
	 rtE <= rtE;
	 rdE <= rdE;
	 rd1E <=  rd1E;
	 rd2E <= rd2E;
	 targetE <= targetE;
	 immediateESigned <= immediateESigned;
	 pcE <= pcE;
	 nextPC_E <= nextPC_E;
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
      
   
   reg UARTCtrE;
   

   //Combinatorial logic for dataWriteEn and instrWriteEn and UART
   always@(*) begin
      byteOffsetE = ALUOutE[1:0];
      UARTCtrE = UARTCtr;
      
      DataInReady = UARTDataInReady;
      DataOutValid = UARTDataOutValid;
      UARTDataOut = UARTDOut;
      
   end

   reg DataOutReadyE;
   reg DataOutReadyM;

   //Combinatorial logic for wires connecting UART Control to UART
   always@(*) begin
      UARTDataIn = rd2Fwd[7:0];
      UARTDataInValid = DataInValid;
      DataOutReadyE = DataOutReady;
   end
   
   //Data Memory inputs for DCache + ICache 
   always@(*) begin
      dataMemIn_toMask = rd2Fwd;
      //dataMemAddr = ALUOutE[13:2];

      //D$
      dcache_we = dataMemWriteEn;
      dcache_din =  dataInMasked;
      
      //instrMemAddr_A = ALUOutE[13:2];

      //I$

      icache_we = instrMemWriteEn; //make sure PC[30] == 1
      icache_din = dataInMasked;

   end
   

   //===============PipeLineEM==================//
   
   reg 				 memToRegM;
   reg 				 regDstM;
   reg 				 jalM;
   reg 				 jalrM;
   reg 				 UARTCtrM;
   reg 				 isBIOS_DataM;
   reg 				 dcache_re_Ctr_M;
   reg 				 icache_re_Ctr_M;
   reg 				 isLoadM;
   
   
				    
   //transfering control signals   
   always@(posedge clk) begin
      if (!reset && !stall) begin
	 memToRegM <= memToRegE;	 
	 regWriteM <= (!legalReadE && isLoadE)? 0: regWriteE;
	 regDstM <= regDstE;
	 jalM <= jalE;
	 jalrM <= jalrE;
	 UARTCtrM <= UARTCtrE;
	 DataOutReadyM <= DataOutReadyE;
	 isLoadM <= isLoadE;
	 isBIOS_DataM <= isBIOS_Data;
	 dcache_re_Ctr_M <= dcache_re_Ctr;
	 icache_re_Ctr_M <= icache_re_Ctr;
	 
 
      end else if (reset) begin
	 memToRegM <= 0;
	 regWriteM <= 0;
	 regDstM <= 0;
	 jalM <= 0;
	 jalrM <= 0;
	 UARTCtrM <= 0;
	 isLoadM <= 0;
	 isBIOS_DataM <= 0;
	 dcache_re_Ctr_M <= 0;
	 icache_re_Ctr_M <= 0;

      end else begin
	 memToRegM <= memToRegM;
	 regWriteM <= regWriteM;
	 regDstM <= regDstM;
	 jalM <= jalM;
	 jalrM <= jalrM;
	 UARTCtrM <= UARTCtrM;
	 isLoadM <= isLoadM;
	 isBIOS_DataM <= isBIOS_DataM;
	 dcache_re_Ctr_M <= dcache_re_Ctr_M;
	 icache_re_Ctr_M <= icache_re_Ctr_M;

      end
   end
   
   reg [4:0] rtM;
   reg [4:0] rdM;
   reg [31:0] pcM;
   
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



   //=================Memory==================//

   //Determine which read enable /address to take to account for stall
   always@(*) begin
      dcache_addr = (stall)? ALUOutM: ALUOutE;
      icache_addr = (icache_re_Ctr)? PC: (stall)? ALUOutM: ALUOutE;

      dcache_re = (stall)? dcache_re_Ctr_M: dcache_re_Ctr;
      icache_re = (stall)? icache_re_Ctr_M: icache_re_Ctr;
   end
   
   //Combinatorial logic for all wires after Data Memory
   always@(*) begin
      waM = (regDstM)? rdM: rtM;
   end

   //Combinatorial logic after Data Memory Out to DataMemMask
   always@(*) begin
      //dataMemOutM = dataMemOut;
      UARTDataOutReadyM = DataOutReadyM;
   end

   //Determining UART Control Out
   //Passed in by Control Module
         
   //Write-back value to RegFile
   always@(*) begin
      if (isBIOS_DataM)
	writeBack = Data_BIOSOut_Masked;
      else if (!memToRegM) 
	writeBack = ALUOutM;
      else if (UARTCtrM)
	writeBack = UARTCtrOutM;
      else 
	writeBack = dcache_dout_Masked;
   end

   //Connecting write-back value to RegFile Write Port
   always@(*) begin
      regWD = (jalM || jalrM)? pcM + 8: writeBack;
      regWA = (jalM)? 31 : waM;
   end

  // ChipScope components:
   
 //  wire [35:0] chipscope_control;
 //  chipscope_icon icon(
		      // .CONTROL0(chipscope_control)
//		       ) /* synthesis syn_noprune=1 */;
//   chipscope_ila ila(
//   		     .CONTROL(chipscope_control),
//		     .CLK(clk),
		     //.DATA({reset, stall, PC, nextPC, instrMemOut, instrMemWriteEn, branchCtr, rd1Fwd, rd2Fwd, ALUOutE, UARTDataIn, UARTDataOut, writeBack, regWriteM}),
//		     .TRIG0({reset, stall, UARTDataInReady, UARTDataOutValid, SIn, SOut, UARTDOut, ALUop, instrMemWriteEn,  PC, dataMemOut, dataMemMasked, dataMemWriteEn, rd1Fwd, rd2Fwd, ALUOutE, writeBack, regWriteM, branchCtr, UARTDataOutReady, UARTDataInValid, shiftE, jalrE})
//		     ) /* synthesis syn_noprune=1 */;
   

//, branchCtr, rd1Fwd, rd2Fwd, ALUOutE, UARTDataIn, UARTDataOut, writeBack,// regWriteM})
		     //) /* synthesis syn_noprune=1 */;

   
endmodule

