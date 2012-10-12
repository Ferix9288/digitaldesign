module DataPath(
		input clk,
		input stall,
		input reset,
		input SIn,
		output SOut,
		//All the outputs from Control

		//Original Control unit Outputs (become inputs)
		input memToReg,
		input regWrite,
		input extType,
		input ALUsrc,
		input regDst,
		input [3:0] ALUop,
		input jump,
		input jr,
		input jal,

		//Write Ctr output (become input)
		input [3:0] dataMemWriteEn,

		//Write Ctr output (become input)
		input [3:0] instrMemWriteEn,

		//Branch Ctr output (become input)
		input branchCtr,

		//Hazard Ctr outputs (become inputs)
		input FwdAfromMtoE,
		input FwdBfromMtoE,
		input FwdAfromMtoF,
		input FwdBfromMtoF,

		//UART Ctr outputs (become inputs)
		input UARTCtr,
		input UARTCtrOut,
		input DataInValid,
		input DataOutReady,

		//Original Control unit inputs (become outputs)
		output reg [5:0] opcodeF,
		output reg [5:0] functF,

		//Write Ctr Inputs for Data Memory (become outputs)
		output reg [5:0] opcodeM,
		output reg [1:0] byteOffsetM,

		//Write Ctr Inputs for Instr Memory (become outputs)
		//byteoffsetM

		//Branch Ctr Inputs (become outputs)
		output reg [5:0] opcodeE,
		output reg [31:0] rd1E,
		output reg [31:0] rd2E,

		//Hazard Ctr Inputs (become outputs)
		output reg [4:0] rsF,
		output reg [4:0] rtF,
		output reg [4:0] rsE,
		output reg [4:0] rtE,
		output reg [4:0] waM,
		output reg regWriteM,

		//UART Ctr Inputs (become outputs)
		output reg [31:0] ALUOutM,
		output reg DataInReady,
		output reg DataOutValid,
		output reg [7:0] UARTDataOut
		//opcodeM
		);

   //--FOR ALU--
   
   //~Inputs~
   reg [31:0] 			 ALUinputA;
   reg [31:0] 			 ALUinputB;
   reg [3:0] 			 ALUopE;
 			 

   //~Outputs~
   wire [31:0] 			 ALUOut;
   reg [31:0] 			 ALUOutE;

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
   reg [31:0] 			 dataMemIn;

   //~Outputs~
   wire [31:0] 			 dataMemOut;
   reg [31:0] 			 dataMemOutM;

   //--FOR Data Memory Mask--

   //~Inputs~

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
		      .ALUop(ALUopE),
		      //Outputs
		      .Out(ALUOut));

   //Instantiating RegFile
   RegFile Regfile(
		   //Inputs
		   .clk(clk),
		   .we(regWriteF),
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
			   .ena(stall),
			   .wea(dataMemWriteEn),
			   .addra(dataMemAddr),
			   .dina(dataMemIn),
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
			    .ena(stall),
			    .wea(intrMemWriteEn),
			    .addra(instrMemAddr),
			    .dina(instrMemIn),
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
		   .Reset(rst),
		   .DataIn(UARTDataIn),
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
   reg [3:0] 			 ALUopF;
   reg 				 jrF;
   reg 				 jalF;
     
   //Assign control signals to appropriate registers
   always@(*) begin
      memToRegF = memToReg;
      regWriteF = regWrite;
      extTypeF = extType;
      ALUsrcF = ALUsrc;
      regDstF = regDst;
      ALUopF = ALUop;
      jrF = jr;
      jalF = jal;      
   end
   
   //The Logic/Muxes Driving the Program Counter
   always@(posedge clk) begin
      PC <= nextPC;
      if (stall)
	nextPC <= PC;
      if (reset)
	nextPC <= 0;      
      else if (branchCtr) 
	nextPC <=  PC + 4 + immediateFSigned<<2;
      else if (jump)
	nextPC <= {PC[31:28], targetF};
      else if (jr)
	nextPC <= rd1F;
      else      
	nextPC <= PC + 4;
   end // always@ (posedge clk)

   //Combinatorial logic from PC to Instr-Mem and then to Instr Decoder
   always@(*) begin
      instrMemAddr = PC[13:2];
      DecIn = instrMemOut;
   end

   //Combinatorial logic for Decoder output
   always@(*) begin
      opcodeF = DecOpcode;
      functF = DecFunct;
      rsF = DecRs;
      rtF = DecRt;
      rdF = DecRd;
      shamtF = DecShamt;
      immediateF = DecImmediate;
      //If sign-extended and most significant bit is a 1, sign extend
      //Otherwise, just zero-extend
      immediateFSigned = ((extType == 0) && (immediateF[15] == 1'b1))?
			 {16'b1, immediateF} : {16'b0, immediateF};
      targetF = DecTarget;      
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
   reg 				 regWriteE;
   reg 				 extTypeE;
   reg 				 ALUsrcE;
   reg 				 regDstE;
   //reg [3:0] 			 ALUopE;
   reg 				 jrE;
   reg 				 jalE;
 

   //transfering control signals   
   always@(posedge clk) begin
      memToRegE <= memToRegF;
      regWriteE <= regWriteF;
      extTypeE <= extTypeF;
      ALUsrcE <= ALUsrcF;
      regDstE <= regDstF;
      ALUopE <= ALUopF;
      jrE <= jrF;
      jalE <= jalF;      
   end
	 
   // reg [5:0] opcodeE;
   reg [5:0] functE;
   // reg [4:0] rsE;
   // reg [4:0] rtE;
   reg [4:0] rdE;
   //reg [31:0] rd1E;
   //reg [31:0] rd2E;
   reg [31:0] immediateESigned;

   //transfering non-control signals
   always@(posedge clk) begin
      opcodeE <= opcodeF;
      functE <= functF;
      rsE <= rsF;
      rtE <= rtF;
      rdE <= rdF;
      rd1E <= rd1F;
      rd2E <= rd2F;
      immediateESigned <= immediateFSigned;
   end
  
   //=================Execution==================//

   //Combinatorial logic to ALU inputs
   always@(*) begin
      ALUinputA = (FwdAfromMtoE)? ALUOutM: rd1E;
      if (FwdBfromMtoE)
	ALUinputB = ALUOutM;
      else 
	ALUinputB = (ALUsrcE)? (immediateESigned) : rd2E;
   end

   //Combinatorial logic after ALU
   always@(*) begin
      ALUOutE = ALUOut;
   end

   //===============PipeLineEM==================//
		   
   reg 				 memToRegM;
   //reg 				 regWriteM;
   reg 				 extTypeM;
   reg 				 ALUsrcM;
   reg 				 regDstM;
   reg [3:0] 			 ALUopM;
   reg 				 jrM;
   reg 				 jalM;
   

   //transfering control signals   
   always@(posedge clk) begin
      memToRegM <= memToRegE;
      regWriteM <= regWriteE;
      extTypeM <= extTypeE;
      ALUsrcM <= ALUsrcE;
      regDstM <= regDstE;
      ALUopM <= ALUopE;
      jrM <= jrE;
      jalM <= jalE;      
   end
   
   //reg [5:0] opcodeM;
   reg [5:0] functM;
   reg [4:0] rsM;
   reg [4:0] rtM;
   reg [4:0] rdM;
   reg [31:0] rd1M;
   reg [31:0] rd2M;
   reg [31:0] immediateMSigned;

   //transfering non-control signals
   always@(posedge clk) begin
      opcodeM <= opcodeE;
      functM <= functE;
      rsM <= rsE;
      rtM <= rtE;
      rdM <= rdE;
      rd1M <= rd1E;
      rd2M <= rd2E;
      immediateMSigned = immediateESigned;
      ALUOutM <= ALUOutE;
      
   end

   //Data Memory inputs (NOT TOO SURE IF CORRECT)
   always@(posedge clk) begin
      dataMemAddr <= ALUOutE[13:2];
      dataMemIn <= rd2E;
   end
      

   //=================Memory==================//

   //Combinatorial logic for all wires after Data Memory
   always@(*) begin
      waM = (regDstM)? rdM: rtM;
   end

   //Combinatorial logic for dataWriteEn and instrWriteEn
   always@(*) begin
      byteOffsetM = ALUOutM[1:0];     
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
      regWD = (jal)? PC + 8: writeBack;
      regWA = (jal)? 31 : waM;
   end
      
	
   
   
      
endmodule
   
//memToRegE <= memToRegF
