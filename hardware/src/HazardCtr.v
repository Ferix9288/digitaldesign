`include "Opcode.vh"
`include "ALUop.vh"

module HazardCtr (input [4:0] rsF,
		  input [4:0] rtF,
		  input [4:0] rsE,
		  input [4:0] rtE,
		  input [4:0] waM,
		  input regWriteM,
		  output FwdAfromMtoE,
		  output FwdBfromMtoE,
		  output FwdAfromMtoF,
		  output FwdBfromMtoF
		  );

   //Forwarding from Memory to Execution stage in Pipe-Lined Datapath
   assign FwdAfromMtoE = (waM != 0) && (waM == rsE) &&
			 (regWriteM);
   
   assign FwdBfromMtoE = (waM != 0) && (waM == rtE) &&
			 (regWriteM) ;
   

   //Forwarding from Memory to Fetch stage in Pipe-lined Datapath
   assign FwdAfromMtoF = (waM != 0) && (waM == rsF) &&
			 (regWriteM) ;
   
   assign FwdBfromMtoF = (waM != 0) && (waM == rtF) &&
			 (regWriteM) ;
   

endmodule
