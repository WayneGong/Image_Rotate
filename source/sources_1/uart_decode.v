module uart_decode
(
	input				clk,
	input				rst_n,
	
	input				rx_en,
	input	[7:0]		rx_data,
	output	reg	[7:0]	threshold,
	output	[7:0]		code_out

);

reg	[39:0]	data_reg;

reg			color_en;
reg			gary_en;
reg			binary_en;

reg			threshold_en;

assign		code_out	=	{4'b0,threshold_en,binary_en,gary_en,color_en};

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		data_reg	<=	'b0;
	else if( rx_en )
		data_reg	<=	{data_reg[32:0],rx_data};
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		color_en	<=	1'b0;
	else if( data_reg == 40'h4d_4f_44_01_01  )
		color_en	<=	1'b1;
	else 
		color_en	<=	1'b0;
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		gary_en	<=	1'b0;
	else if( data_reg == 40'h4d_4f_44_02_02  )
		gary_en	<=	1'b1;
	else 
		gary_en	<=	1'b0;
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		binary_en	<=	1'b0;
	else if( data_reg == 40'h4d_4f_44_03_03  )
		binary_en	<=	1'b1;
	else 
		binary_en	<=	1'b0;
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		threshold	<=	8'b0;
	else if( data_reg[39:8] == 32'h4d_4f_44_04  )
		threshold	<=	data_reg[7:0];
	else 
		threshold	<=	8'b0;
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		threshold_en	<=	1'b0;
	else if( data_reg[39:8] == 32'h4d_4f_44_04  )
		threshold_en	<=	1'b1;
	else 
		threshold_en	<=	1'b0;
end



endmodule 