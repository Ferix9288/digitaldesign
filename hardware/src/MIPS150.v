
module MIPS150(
    input clk, rst, stall,
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
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
		     .UARTDataOut(UARTDataOut));
   
   Control Controls(.opcodeF(opcodeF),
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
		    .DataOutReady(DataOutReady));
   
		    


endmodule
    

