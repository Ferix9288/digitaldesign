module MIPS150(
    input clk,
    input rst,
    input stall,


    // Serial
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX,

    // Memory system connections
    output [31:0] dcache_addr,
    output [31:0] icache_addr,
    output [3:0] dcache_we,
    output [3:0] icache_we,
    output dcache_re,
    output icache_re,
    output [31:0] dcache_din,
    output [31:0] icache_din,
    input [31:0] dcache_dout,
    input [31:0] instruction,

    output [31:0] gp_code,
    output [31:0] gp_frame,
    output gp_valid,
    input frame_interrupt
);

// Use this as the top-level module for your CPU. You
// will likely want to break control and datapath out
   // into separate modules that you instantiate here.

   wire    memToReg;
   wire    regWrite;
   wire    extType;
   wire    ALUsrc;
   wire    regDst;
   wire [3:0] ALUop;
   wire       jump;
   wire       jr;
   wire       jal;
   wire       jalr;
   wire       shift;
   wire [3:0] dataMemWriteEn, instrMemWriteEn, ISR_MemWriteEn;
   wire       branchCtr;
   wire       FwdAfromMtoE;
   wire       FwdBfromMtoE;
   wire       FwdAfromMtoF;
   wire       FwdBfromMtoF;
   wire       UARTCtr;
   wire [31:0] UARTCtrOutM;
   wire        DataInValid;
   wire        DataOutReady;
   wire [5:0]  opcodeF;
   wire [5:0]  functF;
   wire [5:0]  functE;
   wire [31:0] ALUOutE;
   wire [31:0] ALUOutM;
   
   wire [5:0]  opcodeE;
   wire [5:0]  opcodeM;
   
   wire [1:0]  byteOffsetE;
   wire [31:0] rd1Fwd;
   wire [31:0] rd2Fwd;
   wire [4:0]  rsF;
   wire [4:0]  rtF;
   wire [4:0]  rsE;
   wire [4:0]  rtE;
   wire [4:0]  waM;
   wire        regWriteM;
   wire        DataInReady;
   wire        DataOutValid;
   wire [7:0]  UARTDataOut;
   wire        isLoadE, legalReadE;  
   wire        isBIOS_Data, enPC_BIOS, enData_BIOS;
   wire [1:0]  instrSrc;
   
   wire [31:0] PC;
   wire [31:0] pcE;
   wire [31:0] nextPC;
   
   

   wire        dcache_re_Ctr, icache_re_Ctr;

   wire        readCycleCount, readInstrCount, resetCounters;
   wire        mtc0, mfc0, causeDelaySlot;
   
   
   
   

    
   DataPath DataPath(//Inputs
		     .clk(clk),
		     .stall(stall),
		     .reset(rst),
		     .SIn(FPGA_SERIAL_RX),
		     //Outputs to Cache
		     .SOut(FPGA_SERIAL_TX),
		     .dcache_addr(dcache_addr),
		     .icache_addr(icache_addr),
		     .dcache_we(dcache_we),
		     .icache_we(icache_we),
		     .dcache_re(dcache_re),
		     .icache_re(icache_re),
		     .dcache_din(dcache_din),
		     .icache_din(icache_din),
		     //Inputs from Cache
		     .dcache_dout(dcache_dout),
		     .instruction(instruction),


		     //Basic Controls
		     .memToReg(memToReg),
		     .regWrite(regWrite),
		     .extType(extType),
		     .ALUsrc(ALUsrc),
		     .regDst(regDst),
		     .ALUop(ALUop),
		     .jump(jump),
		     .jr(jr),
		     .jal(jal),
		     .jalr(jalr),
		     .shift(shift),

		     //Write Enables for Memory
		     .dataMemWriteEn(dataMemWriteEn),
		     .instrMemWriteEn(instrMemWriteEn),
		     .ISR_MemWriteEn(ISR_MemWriteEn),

		     //Branch Control Logic
		     .branchCtr(branchCtr),
		     .FwdAfromMtoE(FwdAfromMtoE),
		     .FwdBfromMtoE(FwdBfromMtoE),
		     .FwdAfromMtoF(FwdAfromMtoF),
		     .FwdBfromMtoF(FwdBfromMtoF),

		     //UART Control
		     .UARTCtr(UARTCtr),
		     .UARTCtrOutM(UARTCtrOutM),
		     .DataInValid(DataInValid),
		     .DataOutReady(DataOutReady),
		     .isLoadE(isLoadE),
		     .legalReadE(legalReadE),

		     //FOR BIOS MEM
		     .isBIOS_Data(isBIOS_Data),
		     .enPC_BIOS(enPC_BIOS),
		     .enData_BIOS(enData_BIOS),
		     .instrSrc(instrSrc),

		     .dcache_re_Ctr(dcache_re_Ctr),
		     .icache_re_Ctr(icache_re_Ctr),

		     //FOR Memory Mapped I/O Count
		     .readCycleCount(readCycleCount),
		     .readInstrCount(readInstrCount),
		     .resetCounters(resetCounters),

		     //FOR CP0

		     .mtc0(mtc0),
		     .mfc0(mfc0),
		     .causeDelaySlot(causeDelaySlot),
		     
		     //OUTPUTS

		     
		     .opcodeF(opcodeF),
		     .functF(functF),
		    // .ALUOutM(ALUOutM),
		     .functE(functE),
		     .opcodeE(opcodeE),
		     .byteOffsetE(byteOffsetE),
		     .ALUOutE(ALUOutE),
		     .rd1Fwd(rd1Fwd),
		     .rd2Fwd(rd2Fwd),
		     .rsF(rsF),
		     .rtF(rtF),
		     .rsE(rsE),
		     .rtE(rtE),
		     .waM(waM),
		     .regWriteM(regWriteM),
		     .DataInReady(DataInReady),
		     .DataOutValid(DataOutValid),
		     .UARTDataOut(UARTDataOut),
		     .ALUOutM(ALUOutM),
		     .opcodeM(opcodeM),
		     .PC(PC),
		     .pcE(pcE),
		     .nextPC(nextPC),
		     //Graphics Processor
		     .GP_CODE(gp_code),
		     .GP_FRAME(gp_frame),
		     .GP_valid(gp_valid));
   
   Control Controls(.stall(stall),
		    .opcodeF(opcodeF),
		    .functF(functF),
		   // .ALUOutM(ALUOutM),
		    .functE(functE),
		    .opcodeE(opcodeE),
		    .byteOffsetE(byteOffsetE),
		    .ALUOutE(ALUOutE),
		    .rd1Fwd(rd1Fwd),
		    .rd2Fwd(rd2Fwd),
		    .rsF(rsF),
		    .rtF(rtF),
		    .rsE(rsE),
		    .rtE(rtE),
		    .waM(waM),
		    .regWriteM(regWriteM),
		    .DataInReady(DataInReady),
		    .DataOutValid(DataOutValid),
		    .UARTDataOut(UARTDataOut),
		    .ALUOutM(ALUOutM),
		    .opcodeM(opcodeM),
		    .PC(PC),
		    .pcE(pcE),
		    .nextPC(nextPC),
		    .memToReg(memToReg),
		    .regWrite(regWrite),
		    .extType(extType),
		    .ALUsrc(ALUsrc),
		    .regDst(regDst),
		    .ALUop(ALUop),
		    .jump(jump),
		    .jr(jr),
		    .jal(jal),
		    .jalr(jalr),
		    .shift(shift),
		    
		    .dataMemWriteEn(dataMemWriteEn),
		    .instrMemWriteEn(instrMemWriteEn),
		    .ISR_MemWriteEn(ISR_MemWriteEn),
		    
		    .branchCtr(branchCtr),
		    .FwdAfromMtoE(FwdAfromMtoE),
		    .FwdBfromMtoE(FwdBfromMtoE),
		    .FwdAfromMtoF(FwdAfromMtoF),
		    .FwdBfromMtoF(FwdBfromMtoF),
		    .UARTCtr(UARTCtr),
		    .UARTCtrOutM(UARTCtrOutM),
		    .DataInValid(DataInValid),
		    .DataOutReady(DataOutReady),
		    .isLoadE(isLoadE),
		    .legalReadE(legalReadE),
		    .isBIOS_Data(isBIOS_Data),
		    .enPC_BIOS(enPC_BIOS),
		    .enData_BIOS(enData_BIOS),
		    .instrSrc(instrSrc),
		    .dcache_re_Ctr(dcache_re_Ctr),
		    .icache_re_Ctr(icache_re_Ctr),
		    .readCycleCount(readCycleCount),
		    .readInstrCount(readInstrCount),
		    .resetCounters(resetCounters),
		    .mtc0(mtc0),
		    .mfc0(mfc0),
		    .causeDelaySlot(causeDelaySlot));
   
		    


endmodule
