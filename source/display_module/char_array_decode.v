module  char_array_decode
(
	char,
	char_array

);

input			[3:0]		char;
output	reg		[127:0]		char_array;
	
reg	[127:0]	char0_Template	={8'hFF,8'hFF,8'hFF,8'hE7,8'hDB,8'hBD,8'hBD,8'hBD,8'hBD,8'hBD,8'hBD,8'hBD,8'hDB,8'hE7,8'hFF,8'hFF};
reg	[127:0]	char1_Template	={8'hFF,8'hFF,8'hFF,8'hF7,8'hC7,8'hF7,8'hF7,8'hF7,8'hF7,8'hF7,8'hF7,8'hF7,8'hF7,8'hC1,8'hFF,8'hFF};
reg	[127:0]	char2_Template	={8'hFF,8'hFF,8'hFF,8'hC3,8'hBD,8'hBD,8'hBD,8'hFD,8'hFB,8'hF7,8'hEF,8'hDF,8'hBD,8'h81,8'hFF,8'hFF};
reg	[127:0]	char3_Template	={8'hFF,8'hFF,8'hFF,8'hC3,8'hBD,8'hBD,8'hFD,8'hFB,8'hE7,8'hFB,8'hFD,8'hBD,8'hBD,8'hC3,8'hFF,8'hFF};
reg	[127:0]	char4_Template	={8'hFF,8'hFF,8'hFF,8'hFB,8'hF3,8'hF3,8'hEB,8'hDB,8'hDB,8'hBB,8'h80,8'hFB,8'hFB,8'hE0,8'hFF,8'hFF};
reg	[127:0]	char5_Template	={8'hFF,8'hFF,8'hFF,8'h81,8'hBF,8'hBF,8'hBF,8'h87,8'hBB,8'hFD,8'hFD,8'hBD,8'hBB,8'hC7,8'hFF,8'hFF};
reg	[127:0]	char6_Template	={8'hFF,8'hFF,8'hFF,8'hE7,8'hDB,8'hBF,8'hBF,8'hA3,8'h9D,8'hBD,8'hBD,8'hBD,8'hDD,8'hE3,8'hFF,8'hFF};
reg	[127:0]	char7_Template	={8'hFF,8'hFF,8'hFF,8'h81,8'hBD,8'hFB,8'hFB,8'hF7,8'hF7,8'hEF,8'hEF,8'hEF,8'hEF,8'hEF,8'hFF,8'hFF};
reg	[127:0]	char8_Template	={8'hFF,8'hFF,8'hFF,8'hC3,8'hBD,8'hBD,8'hBD,8'hDB,8'hE7,8'hDB,8'hBD,8'hBD,8'hBD,8'hC3,8'hFF,8'hFF};
reg	[127:0]	char9_Template	={8'hFF,8'hFF,8'hFF,8'hC7,8'hBB,8'hBD,8'hBD,8'hBD,8'hB9,8'hC5,8'hFD,8'hFD,8'hDB,8'hE7,8'hFF,8'hFF};

always@(*)
begin
	case(char)
		0		:	char_array	=	char0_Template	;	
		1		:	char_array	=	char1_Template	;	
		2		:	char_array	=	char2_Template	;	
		3		:	char_array	=	char3_Template	;
		4		:	char_array	=	char4_Template	;	
		5		:	char_array	=	char5_Template	;	
		6		:	char_array	=	char6_Template	;	
		7		:	char_array	=	char7_Template	;
		8		:	char_array	=	char8_Template	;
		9		:	char_array	=	char9_Template	;
		default	:	char_array	=	char0_Template	;		
	endcase
end


endmodule
