//CORRECT BRANCH STALLS.

module hazard_detect (
input [15:0] IF_ID_Inst, 
input ID_EX_MemRead, 
input ID_EX_RegWrite, 
input EX_MEM_RegWrite, 
input [3:0] EX_MEM_RdAddr, 
input br_true, 
input MemWrite, 
input ID_EX_flag_br_checker, 
input EX_MEM_flag_br_checker, 
input MEM_WB_flag_br_checker, 
input [3:0] ID_EX_RtAddr, 
output flag_br_checker, 
output stall, 
output IF_Flush, 
output ID_Flush
);



wire [3:0] IF_ID_RegRs;
wire [3:0] IF_ID_RegRt;
wire [3:0] ID_EX_RegRt;
wire [3:0] ID_EX_RegRd;
wire [3:0] EX_MEM_RegRd;

assign IF_ID_RegRs = IF_ID_Inst[7:4];
assign IF_ID_RegRt = (IF_ID_Inst[15:12] == 4'b1000 | IF_ID_Inst[15:12] == 4'b1001) ? IF_ID_Inst[11:8] : IF_ID_Inst[3:0];
assign ID_EX_RegRt = ID_EX_RtAddr;
assign EX_MEM_RegRd = EX_MEM_RdAddr;

assign flag_br_checker = (ID_EX_flag_br_checker | EX_MEM_flag_br_checker) ? 0 : (((IF_ID_Inst[15:13] == 3'b110) && (IF_ID_Inst[11:9] != 3'b111)) ? 1'b1 : 1'b0);

//Data Hazard
assign ID_Flush = (IF_ID_Inst[15] == 1'b0 | IF_ID_Inst[15:12] == 4'b1000 | IF_ID_Inst[15:12] == 4'b1001 | IF_ID_Inst[15:13] == 3'b110) ? ((ID_EX_MemRead & ((ID_EX_RegRt == IF_ID_RegRs))) | (ID_EX_MemRead & (ID_EX_RegRt == IF_ID_RegRt) & MemWrite !=1'b1) | ((IF_ID_Inst[15:13] ==  3'b110 && flag_br_checker == 1'b1 && IF_ID_Inst[11:9] != 3'b111) | (IF_ID_Inst[15:13] ==  3'b110 && ID_EX_flag_br_checker == 1'b1 && IF_ID_Inst[11:9] != 3'b111))) ? 1'b1 : 1'b0 : 1'b0;
assign stall = (IF_ID_Inst[15] == 1'b0 | IF_ID_Inst[15:12] == 4'b1000 | IF_ID_Inst[15:12] == 4'b1001 | IF_ID_Inst[15:13] == 3'b110) ? ((ID_EX_MemRead & ((ID_EX_RegRt == IF_ID_RegRs))) | (ID_EX_MemRead & (ID_EX_RegRt == IF_ID_RegRt) & MemWrite !=1'b1) | ((IF_ID_Inst[15:13] ==  3'b110 && flag_br_checker == 1'b1 && IF_ID_Inst[11:9] != 3'b111) | (IF_ID_Inst[15:13] ==  3'b110 && ID_EX_flag_br_checker == 1'b1 && IF_ID_Inst[11:9] != 3'b111))) ? 1'b1 : 1'b0 : 1'b0;

//assign pc_write = ((ID_EX_MemRead & ((ID_EX_RegisterRt == IF_ID_RegisterRs) | (ID_EX_RegisterRt == IF_ID_RegisterRt))) | ((IF_ID_Inst[15:13] ==  3'b110) & ID_EX_RegWrite & ((ID_EX_RegisterRd == IF_ID_RegisterRs) | (ID_EX_RegisterRd == IF_ID_RegisterRt))) | ((IF_ID_Inst[15:13] ==  3'b110) & EX_MEM_RegWrite & ((EX_MEM_RegisterRd == IF_ID_RegisterRs) | (EX_MEM_RegisterRd == IF_ID_RegisterRt)))) ? 1'b1 : 1'b0; //PC stall for data hazards

//Control Hazard
//assign IF_Flush = (br_true) ? 1'b1 : 1'b0;
//HOW TO CHECK WHETHER br_true is due to most recent flags.
assign IF_Flush = ((br_true && EX_MEM_flag_br_checker && (IF_ID_Inst[15:13] == 3'b110)) || ((IF_ID_Inst[15:13] == 3'b110) && (IF_ID_Inst[11:9] == 3'b111))) ? 1'b1 : 1'b0;	// to ensure unnecessary flushing of pipeline
endmodule
 
