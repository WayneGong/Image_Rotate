module  char2_array_decode
(
	char2,
	char2_array

);

input			[4:0]		char2;
output  reg		[255:0]     char2_array;
	
reg [255:0] char00_Template = {8'hFF,8'hFF,8'hE0,8'h0F,8'hEF,8'hEF,8'hEF,8'hEF,8'hE0,8'h0F,8'hEF,8'hEF,8'hEF,8'hEF,8'hE0,8'h0F,8'hFB,8'hBF,8'hBB,8'hBB,8'hDB,8'hBB,8'hEB,8'hB7,8'hEB,8'hAF,8'hFB,8'hBF,8'h00,8'h01,8'hFF,8'hFF};/*"显",0*/
reg [255:0] char01_Template = {8'hFF,8'hFF,8'hC0,8'h07,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h00,8'h01,8'hFE,8'hFF,8'hFE,8'hFF,8'hEE,8'hEF,8'hEE,8'hF7,8'hDE,8'hFB,8'hBE,8'hFD,8'h7E,8'hFD,8'hFA,8'hFF,8'hFD,8'hFF};/*"示",1*/
reg [255:0] char02_Template = {8'hEE,8'hEF,8'hEE,8'hEF,8'hE8,8'h03,8'hEE,8'hEF,8'h03,8'hFF,8'hEC,8'h07,8'hCD,8'hF7,8'hC4,8'h07,8'hA9,8'hF7,8'hAC,8'h07,8'h6F,8'hBF,8'hE8,8'h03,8'hEF,8'h5F,8'hEE,8'hEF,8'hED,8'hF7,8'hEB,8'hF9};/*"模",2*/
reg [255:0] char03_Template = {8'hFF,8'hB7,8'hFF,8'hBB,8'hFF,8'hBB,8'hFF,8'hBF,8'h00,8'h01,8'hFF,8'hBF,8'hFF,8'hBF,8'hC1,8'hBF,8'hF7,8'hBF,8'hF7,8'hBF,8'hF7,8'hDF,8'hF7,8'hDD,8'hF0,8'hED,8'h87,8'hF5,8'hDF,8'hF9,8'hFF,8'hFD};/*"式",3*/
reg [255:0] char04_Template = {8'hDF,8'hFF,8'hE8,8'h03,8'hFF,8'h7B,8'hBF,8'h5B,8'hBF,8'h6B,8'hA0,8'h0B,8'hBF,8'h7B,8'hB1,8'h5B,8'hB5,8'h5B,8'hB1,8'h5B,8'hBF,8'h3B,8'hB9,8'hAB,8'hA7,8'h4B,8'hBE,8'hEB,8'hBD,8'hFB,8'hBF,8'hF3};/*"阈",0*/
reg [255:0] char05_Template = {8'hF7,8'hBF,8'hF7,8'hBF,8'hF0,8'h03,8'hEF,8'hBF,8'hEF,8'hBF,8'hCC,8'h07,8'hCD,8'hF7,8'hAC,8'h07,8'h6D,8'hF7,8'hEC,8'h07,8'hED,8'hF7,8'hEC,8'h07,8'hED,8'hF7,8'hED,8'hF7,8'hE0,8'h01,8'hEF,8'hFF};/*"值",1*/
reg [255:0] char06_Template = {8'hDF,8'h7F,8'hEF,8'h7F,8'hEF,8'h01,8'hFE,8'hFF,8'h01,8'hFF,8'hDE,8'h03,8'hDF,8'hDB,8'hC3,8'hDB,8'hDB,8'h5F,8'hDB,8'h5F,8'hDB,8'h43,8'hDB,8'h5F,8'hDB,8'h5F,8'hBA,8'h9F,8'hAA,8'hC1,8'h75,8'hFF};/*"旋",0*/
reg [255:0] char07_Template = {8'hDF,8'hDF,8'hDF,8'hDF,8'hDF,8'hDF,8'h02,8'h03,8'hBF,8'hDF,8'hAF,8'hBF,8'h6C,8'h01,8'h03,8'hBF,8'hEF,8'h7F,8'hEE,8'h03,8'hE3,8'hFB,8'h0F,8'h77,8'hAF,8'hAF,8'hEF,8'hDF,8'hEF,8'hEF,8'hEF,8'hEF};/*"转",1*/
reg [255:0] char08_Template = {8'hDF,8'hBF,8'hDF,8'hDF,8'hD8,8'h01,8'hBB,8'hFD,8'hAE,8'hFF,8'h0E,8'h01,8'hDD,8'hEF,8'hD9,8'hDF,8'hB5,8'h83,8'h0D,8'hBB,8'hBD,8'hBB,8'hFD,8'h83,8'hCD,8'hBB,8'h3D,8'hBB,8'hFD,8'h83,8'hFD,8'hBB};/*"缩",0*/
reg [255:0] char09_Template = {8'hDF,8'hBF,8'hEF,8'hBF,8'hFF,8'hBF,8'h01,8'h7F,8'hDF,8'h01,8'hDE,8'hF7,8'hC1,8'h77,8'hDB,8'h77,8'hDB,8'h77,8'hDB,8'hAF,8'hDB,8'hAF,8'hDB,8'hDF,8'hBB,8'hAF,8'hAB,8'h77,8'h76,8'hFB,8'hFD,8'hFD};/*"放",1*/
reg [255:0] char10_Template = {8'hFF,8'hFF,8'h80,8'h03,8'hFE,8'hFF,8'hFE,8'hFF,8'hEE,8'hEF,8'hF6,8'hEF,8'hF6,8'hDF,8'hFE,8'hFF,8'h00,8'h01,8'hFE,8'hFF,8'hFE,8'hFF,8'hFE,8'hFF,8'hFE,8'hFF,8'hFE,8'hFF,8'hFE,8'hFF,8'hFE,8'hFF};/*"平",0*/
reg [255:0] char11_Template = {8'hF7,8'hDF,8'hE3,8'hDF,8'h0F,8'h83,8'hEF,8'h7B,8'hEE,8'hB7,8'h03,8'hCF,8'hEF,8'hDF,8'hCF,8'hB7,8'hC6,8'h6F,8'hAB,8'hC1,8'hAB,8'hBD,8'h6E,8'h5B,8'hEF,8'hE7,8'hEF,8'hEF,8'hEF,8'h9F,8'hEE,8'h7F};/*"移",1*/
reg [255:0] char12_Template = {8'hFB,8'hFF,8'hFB,8'hFF,8'hFB,8'hFF,8'h00,8'h01,8'hF7,8'hFF,8'hF7,8'h7F,8'hF7,8'h7B,8'hED,8'h7B,8'hED,8'h77,8'hDB,8'h6F,8'hD6,8'hBF,8'hBE,8'hBF,8'h7D,8'hDF,8'hFB,8'hEF,8'hE7,8'hF7,8'h9F,8'hF9};/*"灰",0*/
reg [255:0] char13_Template = {8'hFE,8'hFF,8'hFF,8'h7F,8'hC0,8'h01,8'hDD,8'hDF,8'hDD,8'hDF,8'hC0,8'h03,8'hDD,8'hDF,8'hDD,8'hDF,8'hDC,8'h1F,8'hDF,8'hFF,8'hD0,8'h0F,8'hDB,8'hEF,8'hBD,8'hDF,8'hBE,8'h3F,8'h79,8'hCF,8'hC7,8'hF1};/*"度",1*/
reg [255:0] char14_Template = {8'hFF,8'hFF,8'hC0,8'h07,8'hDE,8'hF7,8'hD6,8'hD7,8'hDA,8'hB7,8'hC0,8'h07,8'hFE,8'hFF,8'hFE,8'hFF,8'hC0,8'h07,8'hFE,8'hFF,8'hFE,8'hFF,8'h00,8'h01,8'hFF,8'hFF,8'hB7,8'h77,8'hBB,8'hBB,8'h7B,8'hBB};/*"黑",0*/
reg [255:0] char15_Template = {8'hFE,8'hFF,8'hFD,8'hFF,8'hFB,8'hFF,8'hC0,8'h07,8'hDF,8'hF7,8'hDF,8'hF7,8'hDF,8'hF7,8'hDF,8'hF7,8'hC0,8'h07,8'hDF,8'hF7,8'hDF,8'hF7,8'hDF,8'hF7,8'hDF,8'hF7,8'hDF,8'hF7,8'hC0,8'h07,8'hDF,8'hF7};/*"白",1*/
reg [255:0] char16_Template = {8'hFF,8'hFF,8'h80,8'h03,8'hFE,8'hFF,8'hFE,8'hFF,8'hFE,8'hFF,8'hFE,8'hFF,8'hEE,8'hFF,8'hEE,8'h07,8'hEE,8'hFF,8'hEE,8'hFF,8'hEE,8'hFF,8'hEE,8'hFF,8'hEE,8'hFF,8'hEE,8'hFF,8'h00,8'h01,8'hFF,8'hFF};/*"正",0*/
reg [255:0] char17_Template = {8'hFE,8'hFF,8'hEE,8'hEF,8'hF6,8'hDF,8'h80,8'h01,8'hBF,8'hFD,8'h60,8'h0B,8'hEF,8'hEF,8'hE0,8'h0F,8'hFE,8'hFF,8'hC0,8'h07,8'hDE,8'hF7,8'hDE,8'hF7,8'hDE,8'hD7,8'hDE,8'hEF,8'hFE,8'hFF,8'hFE,8'hFF};/*"常",1*/


always@(*)
begin
	case(char2)
		0		:	char2_array = char00_Template	;	/*"显",0*/
		1		:	char2_array = char01_Template	;   /*"示",1*/
		2		:	char2_array = char02_Template	;   /*"模",2*/
		3		:	char2_array = char03_Template	;   /*"式",3*/
		4		:	char2_array = char04_Template	;   /*"阈",0*/
		5		:   char2_array = char05_Template	;   /*"值",1*/
		6		:	char2_array = char06_Template	;   /*"旋",0*/
		7		:	char2_array = char07_Template	;   /*"转",1*/
		8		:	char2_array = char08_Template	;   /*"缩",0*/
		9		:	char2_array = char09_Template	;   /*"放",1*/
		10		:	char2_array = char10_Template	;   /*"平",0*/
		11      :   char2_array = char11_Template	;   /*"移",1*/
		12      :   char2_array = char12_Template	;   /*"灰",0*/
		13      :   char2_array = char13_Template	;   /*"度",1*/
		14		:   char2_array = char14_Template	;   /*"黑",0*/
		15      :   char2_array = char15_Template	;   /*"白",1*/
		16      :   char2_array = char16_Template	;   /*"正",0*/
		17		:	char2_array	= char17_Template	;   /*"常",1*/
		default :	char2_array = char00_Template  ;
	endcase
end



endmodule
