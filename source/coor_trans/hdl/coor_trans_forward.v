module	coor_trans_forward
#(
	parameter	IMAGE_W	=	1024,
	parameter	IMAGE_H	=	768	

)
(	
	input					clk,
	input					rst_n,
	
	input	signed	[31:0]	x_in,
	input	signed	[31:0]	y_in,

	output	signed	[31:0]	x_out,
	output	signed	[31:0]	y_out

);

assign	x_out	=	x_in		-	IMAGE_W/2;
assign	y_out	=	IMAGE_H/2	-	y_in;

endmodule
