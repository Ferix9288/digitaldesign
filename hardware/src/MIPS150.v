module MIPS150(
    input clk,
    input rst,

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
    input stall
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
   wire [3:0] dataMemWriteEn;
   wire [3:0] instrMemWriteEn;
   wire       branchCtr;
   wire       FwdAfromMtoE;
   wire       FwdBfromMtoE;
   wire       FwdAfromMtoF;
   wire       FwdBfromMtoF;
   wire       UARTCtr;
   wire [31:0] UARTCtrOut;
   wire        DataInValid;
   wire        DataOutReady;
   wire [5:0]  opcodeF;
   wire [5:0]  functF;
 //  wire [31:0] ALUOutM;
   wire [5:0]  functE;
   wire [31:0] ALUOutE;
   wire [5:0]  opcodeE;
   wire [1:0]  byteOffsetE;
   //wire [5:0]  opcodeE;
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
   wire        isBIOS_Data, instrSrc, enPC_BIOS, enData_BIOS;
   wire [31:0] PC;
   

    
   DataPath DataPath(
		     .clk(clk),
		     .stall(stall),
		     .reset(rst),
		     .SIn(FPGA_SERIAL_RX),
		     .SOut(FPGA_SERIAL_TX),
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
		     .branchCtr(branchCtr),
		     .FwdAfromMtoE(FwdAfromMtoE),
		     .FwdBfromMtoE(FwdBfromMtoE),
		     .FwdAfromMtoF(FwdAfromMtoF),
		     .FwdBfromMtoF(FwdBfromMtoF),
		     .UARTCtr(UARTCtr),
		     .UARTCtrOut(UARTCtrOut),
		     .DataInValid(DataInValid),
		     .DataOutReady(DataOutReady),
		     .isLoadE(isLoadE),
		     .legalReadE(legalReadE),
		     .isBIOS_Data(isBIOS_Data),
		     .instrSrc(instrSrc),
		     .enPC_BIOS(enPC_BIOS),
		     .enData_BIOS(enData_BIOS),
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
		     .PC(PC));
   
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
		    .PC(PC),
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
		    .branchCtr(branchCtr),
		    .FwdAfromMtoE(FwdAfromMtoE),
		    .FwdBfromMtoE(FwdBfromMtoE),
		    .FwdAfromMtoF(FwdAfromMtoF),
		    .FwdBfromMtoF(FwdBfromMtoF),
		    .UARTCtr(UARTCtr),
		    .UARTCtrOut(UARTCtrOut),
		    .DataInValid(DataInValid),
		    .DataOutReady(DataOutReady),
		    .isLoadE(isLoadE),
		    .legalReadE(legalReadE),
		    .isBIOS_Data(isBIOS_Data),
		    .instrSrc(instrSrc),
		    .enPC_BIOS(enPC_BIOS),
		    .enData_BIOS(enData_BIOS));
   
		    


endmodule
