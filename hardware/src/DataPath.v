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
		output reg [31:0] ALUOutM,

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
		output reg [31:0] rd1E,
		output reg [31:0] rd2E,

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
   reg [31:0] 			 dataMemMaskedM;
 			 
   //--FOR Instruction Memory --
   
   //~Inputs~
   reg [11:0] 			 instrMemAddr;
   reg [31:0] 			 instrMemIn;

   //~Outputs~
   wire [31:0] 			 instrMemOut;
   reg [31:0] 			 instrMemOutF;

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
   reg [4:0] 			 shamtF;
			 
   wire [15:0] 			 DecImmediate;
   reg [15:0] 			 immediateF;
   
   wire [25:0] 			 DecTarget;
   reg [25:0] 			 targetF;
	
   //-- FOR UART --
   
   //~Inputs~
   reg [7:0] 			 UARTDataIn;
   reg 				 UARTDataInValid;
   wire 			 UARTDataInReady;
   wire [7:0] 			 UARTDOut;
   wire 			 UARTDataOutValid;
   reg 				 UARTDataOutReady;
   
 			 
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

   //Instantiating Data Memory In
   DataInMask DataInMasked(
			 //Inputs
			 .DataMemIn(dataMemIn),
			 .opcode(opcodeE),
			 //Output
			 .DataInMasked(dataInMasked));
   
				    
   
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
		   .DataOutReady(UARTDataOutReady),
		   .SIn(SIn),
		   //Output
		   .SOut(SOut)
		   );
   
		   
   
   reg [31:0] 			 PC;
   reg [31:0] 			 nextPC;
   

   //=================FETCH==================//

   reg [31:0] 			 immediateFSigned;

   reg 				 memToRegF;
   //reg 				 regWriteF;
   reg 				 extTypeF;
   reg 				 ALUsrcF;
   reg 				 regDstF;
   reg 				 jF; 				 
   reg 				 jrF;
   reg 				 jalF;
   reg 				 jalrF;
   reg [31:0] 			 pcF;
   
   reg 				 regWriteE;
   reg [25:0] 			 targetE;
   reg 				 jE;  
   reg 				 jrE;
   reg 				 jalE;
   reg 				 jalrE;


     
   //Assign control signals to appropriate registers
   always@(*) begin
      if (reset) begin

	 regWriteF = 0;
	 regWriteM = 0;
	 regWriteE = 0;
	 
      end else begin      
	 memToRegF = memToReg;
	 regWriteF = regWrite;
	 extTypeF = extType;
	 ALUsrcF = ALUsrc;

	 regDstF = regDst;
	 jF = jump;	 
	 jrF = jr;
	 jalF = jal;
	 jalrF = jalr;
      end   
   end

   
   //The Logic/Muxes/Clk Driving the Program Counter and Instruction Memory
   always@(posedge clk) begin
      //if (stall)
      //nextPC <= PC;
      //PC <= nextPC;	 

      if (reset) 
	PC <= 0;
      else
	PC <= nextPC;
      
   end // always@ (posedge clk)

   
   reg resetClocked;   
   //Ensure that signals update @ first clock cycle after reset
   //(combinatorially)
   always @(posedge clk)
     resetClocked <= reset;
   
   //Combinatorial logic determining nextPC
   always@(*) begin
      if (resetClocked) begin
	 nextPC = 0;
	 instrMemAddr = 0;
      end else if (branchCtr) begin
	 nextPC =  PC + $signed(immediateESigned<<2);
      end
      else if (jE) begin
	 nextPC = {PC[31:28], targetE, 2'b0};
      end else if (jrE || jalrE) begin
	 nextPC = rd1E;
      end else begin
	 nextPC = PC + 4;
      end
      
      if (!resetClocked) begin
	 instrMemAddr = nextPC[13:2];
      end
   end

   //Combinatorial logic linking Instruction Memory to Decoder
   always@(*) begin
      DecIn = instrMemOut;
   end

   /*
    * //Clock variables to Datapath after reset
   always@(posedge clk) begin
      if (!reset) begin
	 opcodeF <= DecOpcode;
	 functF <= DecFunct;
	 rsF <= DecRs;
	 rtF <= DecRt;
	 rdF <= DecRd;
	 shamtF <= DecShamt;
	 immediateF <= DecImmediate;
	 //If sign-extended and most significant bit is a 1, sign extend
	 //Otherwise, just zero-extend
	 targetF <= DecTarget;
      end
   end // always@ (posedge clk)
    */

   
   
   //Combinatorial logic for sign extension
   always@(*) begin
      //Clock variables to Datapath after reset
      if (!resetClocked) begin

	 opcodeF = DecOpcode;
	 functF = DecFunct;
	 rsF = DecRs;
	 rtF = DecRt;
	 rdF = DecRd;
	 shamtF = DecShamt;
	 immediateF = DecImmediate;
	 //If sign-extended and most significant bit is a 1, sign extend
	 //Otherwise, just zero-extend
	 targetF = DecTarget;
	 pcF = PC;
	 
      end // always@ (posedge clk)
      immediateFSigned = ((extType == 0) && (immediateF[15] == 1'b1))?
			 {16'b1, immediateF} : {16'b0, immediateF};
   end

   //Combinatorial logic fed into and out of RegFile 
   always@(*) begin
      ra1 = rsF;
      ra2 = rtF;
      rd1F = (FwdAfromMtoF)? ALUOutM: rd1;
      rd2F = (FwdBfromMtoF)? ALUOutM: rd2;
   end

   //=================PipeLineFE=================//

   reg 				 memToRegE;
   reg 				 extTypeE;
   reg 				 ALUsrcE;
   reg 				 regDstE;
   //reg [3:0] 			 ALUopE;
 
 

   //transfering control signals   
   always@(posedge clk) begin
      if (!reset) begin	 
	 memToRegE <= memToRegF;
	 regWriteE <= regWriteF;
	 extTypeE <= extTypeF;
	 ALUsrcE <= ALUsrcF;
	 regDstE <= regDstF;
	 jE <= jF;
	 jrE <= jrF;
	 jalE <= jalF;	
	 jalrE <= jalrF;
      end else begin 
	 regWriteE = 0;	 
      end
   end
	 
   // reg [5:0] opcodeE;
   //reg [5:0] functE;
   // reg [4:0] rsE;
   // reg [4:0] rtE;
   reg [4:0] rdE;
   //reg [31:0] rd1E;
   //reg [31:0] rd2E;
   reg [31:0] immediateESigned;
   reg [31:0] pcE;
   
   
   //transfering non-control signals
   always@(posedge clk) begin
      if (!reset) begin
	 opcodeE <= opcodeF;
	 functE <= functF;
	 rsE <= rsF;
	 rtE <= rtF;
	 rdE <= rdF;
	 rd1E <= rd1F;
	 rd2E <= rd2F;
	 targetE <= targetF;
	 immediateESigned <= immediateFSigned;
	 pcE <= pcF;
	 
	// ALUOutE <= ALUOut;
	 
      end
   end
  
   //=================Execution==================//

   //Combinatorial logic to ALU inputs
   always@(*) begin
      rd1E = (FwdAfromMtoE)? ALUOutM: rd1E;
      ALUinputA = rd1E;     
      rd2E = (FwdBfromMtoE)? ALUOutM : rd2E;
      ALUinputB = (ALUsrcE)? immediateESigned : rd2E;
   end
   
    
   //Combinatorial logic after ALU
   always@(*) begin
      ALUOutE = ALUOut;
   end
    

   //Combinatorial logic for dataWriteEn and instrWriteEn
   always@(*) begin
      byteOffsetE = ALUOutE[1:0];     
   end


   //===============PipeLineEM==================//
		   
   reg 				 memToRegM;
   //reg 				 regWriteM;
   reg 				 extTypeM;
   reg 				 ALUsrcM;
   reg 				 regDstM;
   reg 				 jrM;
   reg 				 jalM;
   reg 				 jalrM;
   
   //transfering control signals   
   always@(posedge clk) begin
      if (!reset) begin
	 memToRegM <= memToRegE;
	 regWriteM <= regWriteE;
	 extTypeM <= extTypeE;
	 ALUsrcM <= ALUsrcE;
	 regDstM <= regDstE;
	 jrM <= jrE;
	 jalM <= jalE;
	 jalrM <= jalrE;
      end else begin
	 regWriteM = 0;
      end
   end
   
   //reg [5:0] opcodeM;
   reg [5:0] functM;
   reg [4:0] rsM;
   reg [4:0] rtM;
   reg [4:0] rdM;
   reg [31:0] rd1M;
   reg [31:0] rd2M;
   reg [31:0] immediateMSigned;
   reg [31:0] pcM;

   
//   reg [31:0] ALUOutM;   
//   reg [1:0]  byteOffsetM;

   //transfering non-control signals
   always@(posedge clk) begin
      if (!reset) begin
	 opcodeM <= opcodeE;
	 functM <= functE;
	 rsM <= rsE;
	 rtM <= rtE;
	 rdM <= rdE;
	 rd1M <= rd1E;
	 rd2M <= rd2E;
	 immediateMSigned <= immediateESigned;
	 ALUOutM <= ALUOutE;
	 byteOffsetM <= byteOffsetE;
	 pcM <= pcE;
	 

      end // if (!reset)
      
      else begin
	 opcodeM = 0;//makes Opcode an R-type => writeEnables = False
      end
	 
   end

   //Data Memory inputs (NOT TOO SURE IF CORRECT)
   always@(*) begin
      if (!reset) begin
	 dataMemAddr = ALUOutE[13:2];
	 dataMemIn = rd2E;
      end
   end
      

   //=================Memory==================//

   //Combinatorial logic for all wires after Data Memory
   always@(*) begin
      waM = (regDstM)? rdM: rtM;
   end

   //Combinatorial logic to connect Instruction Memory ports
   always@(*) begin
      instrMemIn = rd2M;
   end
   
   //Combinatorial logic for wires connecting UART Control to UART
   always@(*) begin
      UARTDataIn = rd2M[7:0];
      UARTDataInValid = DataInValid;
      UARTDataOutReady = DataOutReady;

      DataInReady = UARTDataInReady;
      DataOutValid = UARTDataOutValid;
      UARTDataOut = UARTDOut;
   end

   //Combinatorial logic after Data Memory Out to DataMemMask
   always@(*) begin
      dataMemOutM = dataMemOut;
      dataMemMaskedM = dataMemMasked;
   end

   reg [31:0] writeBack;
   
   //Write-back value to RegFile
   always@(*) begin
      if (!memToRegM) 
	 writeBack = ALUOutM;
      else if (UARTCtr)
	writeBack = UARTCtrOut;
      else
	writeBack = dataMemMasked;
   end

   //Connecting write-back value to RegFile Write Port
   always@(*) begin
      regWD = (jalM || jalrM)? pcM + 8: writeBack;
      regWA = (jalM)? 31 : waM;
   end

   //=========RESET========//

  //If RESET, pipeline registers can retain its original values and even pass it new one
   //However, nothing will happen if control signals are asserted as so and PC is stored @ 0.
   /*
    * always@(*) begin
      if (reset) begin
	 regWriteF = 0;
	 regWriteM = 0;
	 regWriteE = 0;
	 instrMemWriteEn = 0;
	 dataMemWriteEn = 0;	 
	 UARTCtr = 0;
      end

      else begin
	 regWriteF = regWriteF;
	 regWriteM = regWriteM;
	 regWriteE = regWriteE;
	 instrMemWriteEn = instrMemWriteEn;
	 
    */
	 

   /*
    * always@(*) begin
     if (rst) begin
	regWriteF = 0;
	//jrWriteEn = 0;
	memToRegE = 0;
	memToRegF = 0;
	extTypeE = 0;
	extTypeF = 0;
	ALUsrcE = 0;
	ALUsrcF = 0;
	regDstE = 0;
	regDstF = 0;
	jrE = 0;
	jrF = 0;
	jalE = 0;
	jalF = 0;
	opcodeE = 0;
	opcodeF = 0;
	functE = 0;
	functF = 0;
	rsE = 0;
	rtE = 0;
	rdE = 0;
	rdF = 0;
	rd2E = 0;
	rd2F = 0;
	immediateESigned = 0;
	immediateFSigned = 0;
	
	memToRegM = 0;
	regWriteM = 0;
	extTypeM = 0;
	ALUsrcM = 0;
	regDstM = 0;
	ALUopM = 0;
	jrM = 0;
	jalM = 0;

	functM = 0;
	rsM = 0;
	rtM = 0;
	rdM = 0;
	rd1M = 0;
	rd2M = 0;
	immediateMSigned = 0;
	ALUOutM = 0;
	dataMemAddr = 0;
	dataMemIn = 0;
     end
   end
    */
      
endmodule
   
//memToRegE <= memToRegF
