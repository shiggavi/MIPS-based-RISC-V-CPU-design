
//Tag Array of 128  blocks
//64 sets with 2 blocks each
//Each block will have 1 byte
//BlockEnable is one-hot
//WriteEnable is one on writes and zero on reads

module MetaDataArray(input clk, input rst, input [15:0] DataIn, input Write, input LRU_en, input [63:0] BlockEnable0, input [63:0] BlockEnable1, output [15:0] DataOut);
  MBlock Mblk0[63:0]( .clk(clk), .rst(rst), .Din(DataIn[7:0]), .WriteEnable(Write), .LRU_en(LRU_en), .Enable(BlockEnable0[63:0]), .Dout(DataOut[7:0]));
  MBlock Mblk1[63:0]( .clk(clk), .rst(rst), .Din(DataIn[15:8]), .WriteEnable(Write), .LRU_en(LRU_en), .Enable(BlockEnable1[63:0]), .Dout(DataOut[15:8]));
endmodule

module MBlock( input clk, input rst, input [7:0] Din, input WriteEnable, input LRU_en, input Enable, output [7:0] Dout);
	MCell mc[6:0]( .clk(clk), .rst(rst), .Din(Din[6:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[6:0]));
        MCell LRU( .clk(clk), .rst(rst), .Din(Din[7]), .WriteEnable(WriteEnable | LRU_en), .Enable(Enable), .Dout(Dout[7]));
endmodule

module MCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~(WriteEnable)) ? q:'bz;
	dff dffm(.q(q), .d(Din), .wen(Enable & (WriteEnable)), .clk(clk), .rst(rst));
endmodule
