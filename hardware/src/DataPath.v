module DataPath(
		input clk,
		input stall,
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
		output reg [1:0] byteOffsetF,

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
   wire [31:0] 			 ALUinputA;
   wire [31:0] 			 ALUinputB;

   //~Outputs~
   wire [31:0] 			 ALUOut;
   reg [31:0] 			 ALUOutE;

   //--FOR RegFile--

   //~Inputs~
   reg 				 regWriteF;
   reg [5:0] 			 ra1;
   reg [5:0] 			 ra2;
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
		   .we(regWriteF),
		   .ra1(ra1),
		   .ra2(ra2),
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
				   .instruction(),
				   //Outputs
				   .opcode(),
				   .funct(),
				   .rs(),
				   .rt(),
				   .rd(),
				   .shamt(),
				   .immediate(),
				   .target());
   
   
   
		   
   
endmodule
   
//memToRegE <= memToRegF
