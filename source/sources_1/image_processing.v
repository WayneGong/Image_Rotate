//////////////////////////////////////////////////////////////////////////////////
 
//////////////////////////////////////////////////////////////////////////////////
module image_processing
#(
	parameter MEM_DATA_BITS = 64,
	parameter ADDR_BITS = 32
)
(
	input rst,                                 /*复位*/
	input mem_clk,                               /*接口时钟*/
    input     [2:0]          key_out,   	
    output reg rd_burst_req,                          /*读请求*/
	output reg wr_burst_req,                          /*写请求*/
	output reg[9:0] rd_burst_len,                     /*读数据长度*/
	output reg[9:0] wr_burst_len,                     /*写数据长度*/
	output reg[ADDR_BITS - 1:0] rd_burst_addr,        /*读首地址*/
	output reg[ADDR_BITS - 1:0] wr_burst_addr,        /*写首地址*/
	input rd_burst_data_valid,                  /*读出数据有效*/
	input wr_burst_data_req,                    /*写数据信号*/
	input[MEM_DATA_BITS - 1:0] rd_burst_data,   /*读出的数据*/
	output[MEM_DATA_BITS - 1:0] wr_burst_data,    /*写入的数据*/
	input rd_burst_finish,                      /*读完成*/
	input wr_burst_finish,                      /*写完成*/
	output	reg			image_addr_flag,
    output reg		[4:0]	display_model,
    output reg		[15:0]	display_number,
	output reg		[10:0]   threshold,
	output reg error
);
parameter IDLE = 3'd0;
parameter MEM_READ = 3'd1;
parameter MEM_WRITE  = 3'd2;
parameter BURST_LEN = 1;


reg[2:0] state;
reg[7:0] wr_cnt;
reg[MEM_DATA_BITS - 1:0] wr_burst_data_reg;
reg	[15:0]				wr_burst_data_reg_add;
assign wr_burst_data = wr_burst_data_reg;
reg[7:0] rd_cnt;
reg[31:0] write_read_len;

reg	[10:0]	time_cnt;

always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		time_cnt	<=	'b0;
	else if( state == IDLE )
		time_cnt	<=	time_cnt	+	1'b1;
	else
		time_cnt	<=	'b0;
end

parameter	[31:0]	IMAGE_SIZE	=	32'hc0000;

always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		wr_burst_data_reg_add	<=	16'h1111;
    else if( wr_burst_data_reg_add	>=	16'hefff)
        wr_burst_data_reg_add	<=	16'h1111;
	else if(   (write_read_len == IMAGE_SIZE ))
		wr_burst_data_reg_add	<=	wr_burst_data_reg_add	+	16'h1111;
end


wire    [12:0]  x_cnt    =    write_read_len[9:0]; 
wire    [12:0]  y_cnt    =    write_read_len[31:10];

parameter	MAX_X	=	256*4;
parameter	MAX_Y	=	768;


always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		wr_burst_data_reg <= 64'b0;
		
	else if( x_cnt == 1024/Scaling_Ratio  ||  y_cnt == 768/Scaling_Ratio  )	
		wr_burst_data_reg	<=    {4{wr_burst_data_reg_add}};

    else if( ( x_cnt == 1024/2  ||  y_cnt == 768/2 ) && display_model == 1 )	
		wr_burst_data_reg	<=    {4{wr_burst_data_reg_add}};
		
//	else if( x_cnt == 50 || x_cnt == 250|| x_cnt == 500|| x_cnt == 750 || x_cnt == 1000 )
//		wr_burst_data_reg	<=    {4{wr_burst_data_reg_add}};
//	else if( y_cnt == 300 || y_cnt == 100 || y_cnt == 500 || y_cnt == 700 )
//		wr_burst_data_reg	<=    {4{wr_burst_data_reg_add}};

	else if( y_cnt >= ( MAX_Y/Scaling_Ratio )|| x_cnt >=( MAX_X/Scaling_Ratio ) )	
		wr_burst_data_reg <= 64'b0;

	else if( x_cnt < x_shift_cnt || y_cnt < y_shift_cnt)	
		wr_burst_data_reg <= 64'b0;	
  	
	else if( x_rotate > 1024 || y_rotate >= 768 )
		wr_burst_data_reg <= 64'hdddd;

	else if(state == MEM_READ && rd_burst_data_valid )
		wr_burst_data_reg <= rd_burst_data;
end

wire		[12:0]	x_rotate;
wire		[12:0]	y_rotate;
reg					i_en;
wire				o_en;

reg		[10:0]	angle_temp;
reg		[10:0]	x_shift_cnt;
reg		[10:0]	y_shift_cnt;
reg   	[3:0]	Scaling_Ratio;
reg		[10:0]	angle;


always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		display_model	<=	0;
	else if( display_model == 8 )
		display_model	<=	'b0;
    else if( key_out[0] )
		display_model	<=	display_model	+	5'd1;	
end

always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		angle_temp	<=	9'b0;
	else if( angle_temp == 0 && key_out[1] )
        angle_temp	<=	360;
    else if( angle_temp == 360 && key_out[2] )
		angle_temp	<=	9'b0;
	else if( display_model != 1 )
		angle_temp	<=	16'b0;
    else if( key_out[2]  && display_model == 1)
		angle_temp	<=	angle_temp	+	16'd1;	
	else if( key_out[1]  && display_model == 1)
		angle_temp	<=	angle_temp	-	16'd1;	
end

always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		x_shift_cnt	<=	0;
	else if( x_shift_cnt == 0 && key_out[1] )
		x_shift_cnt	<=	1024;
	else if( x_shift_cnt == 1024 && key_out[2] )
		x_shift_cnt	<=	0;	
	
	else if( display_model != 2 )
		x_shift_cnt	<=	11'b0;		
    else if( key_out[2] && display_model == 2 )
		x_shift_cnt	<=	x_shift_cnt	+	11'd5;	
	else if( key_out[1] && display_model == 2 )
		x_shift_cnt	<=	x_shift_cnt	-	11'd5;
end

always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		y_shift_cnt	<=	0;
		
		
	else if( y_shift_cnt == 0 && key_out[1] )
		y_shift_cnt	<=	768;
	else if( y_shift_cnt == 768 && key_out[2] )
		y_shift_cnt	<=	0;	
		
		
	else if( display_model != 3 )
		y_shift_cnt	<=	11'b0;		
    else if( key_out[2] && display_model == 3 )
		y_shift_cnt	<=	y_shift_cnt	+	11'd5;	
	else if( key_out[1] && display_model == 3 )
		y_shift_cnt	<=	y_shift_cnt	-	11'd5;
end


always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		Scaling_Ratio	<=	1;
	else if( Scaling_Ratio == 1 && key_out[1])
		Scaling_Ratio	<=	6;
    else if( Scaling_Ratio == 6 && key_out[2])
		Scaling_Ratio	<=	1;
	
    else if( display_model != 4 )		
		Scaling_Ratio	<=	11'b1;
    else if( key_out[2] && display_model == 4)
		Scaling_Ratio	<=	Scaling_Ratio	+	11'd1;	
	else if( key_out[1] && display_model == 4)
		Scaling_Ratio	<=	Scaling_Ratio	-	11'd1;
end


always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		threshold	<=	10;
	else if( threshold == 10 && key_out[1])
		threshold	<=	250;
    else if( threshold >= 250 && key_out[2])
		threshold	<=	10;
	
    else if( display_model != 6 )		
		threshold	<=	10;
    else if( key_out[2] && display_model == 6)
		threshold	<=	threshold	+	11'd5;	
	else if( key_out[1] && display_model == 6)
		threshold	<=	threshold	-	11'd5;
end


always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		rd_burst_addr 		<='h000000;
	else if( write_read_len == IMAGE_SIZE )
		rd_burst_addr 		<='h000000;
	else case( display_model )
		0	:	
			rd_burst_addr 	<= 	rd_burst_addr_start	+	write_read_len;
		1	:	
			rd_burst_addr 	<= 	rd_burst_addr_start	+	x_rotate	+	1024*y_rotate;
		2	:	
			rd_burst_addr 	<= 	rd_burst_addr_start	+	x_cnt	+	1024*y_cnt    - x_shift_cnt ;	
		3	:	
			rd_burst_addr 	<= 	rd_burst_addr_start	+	x_cnt	+	1024*y_cnt    -   1024*y_shift_cnt;
		4	:	
			rd_burst_addr 	<= 	rd_burst_addr_start	+	Scaling_Ratio*x_cnt	+	Scaling_Ratio*1024*y_cnt;                
		default:	
			rd_burst_addr 	<= 	rd_burst_addr_start	+	write_read_len;	
	
	endcase
end
		
always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		display_number 		<=0;
	else case( display_model )
		0	:	
			display_number 	<= 0;
		1	:	
			display_number 	<= 	angle;
		2	:	
			display_number 	<= 	x_shift_cnt ;	
		3	:	
			display_number 	<= 	y_shift_cnt;
		4	:	
			display_number 	<=  Scaling_Ratio;
        6    :    
            display_number 	<=  threshold;
		default:	
			display_number 	<= 0;		
	endcase
end			


coor_trans coor_trans_inst
(
    .clk		(	mem_clk			),
    .rst_n		(	rst_n			),
    
    
    .angle		(	angle			),
    .x_in		(	x_cnt			),
    .y_in		(	y_cnt			),
   

	.x_out		(	x_rotate		),
    .y_out		(	y_rotate		)
);


reg	[31:0]	wr_burst_addr_start;
reg	[31:0]	rd_burst_addr_start;


always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		wr_burst_addr_start	<=32'd6220800 ;
	else if( image_addr_flag )					//image_addr_flag==1
		wr_burst_addr_start	<=32'd4147200 ;
	else	
		wr_burst_addr_start	<=32'd6220800;		//image_addr_flag==0
end

always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		rd_burst_addr_start	<=32'd2073600;
	else if( image_addr_flag )					//image_addr_flag==1
		rd_burst_addr_start	<=32'd0  ;
	else	
		rd_burst_addr_start	<=32'd2073600;		//image_addr_flag==0
end


always@(posedge mem_clk or posedge rst)
begin
	if(rst)
	begin
        angle                <=    'b0;
        state 				<= IDLE;
		i_en				<=	1'b1;
		image_addr_flag		<=	1'b0;
		
		wr_burst_req 		<= 1'b0;
		rd_burst_req 		<= 1'b0;
		
		rd_burst_len 		<= BURST_LEN;
		wr_burst_len 		<= BURST_LEN;
		
		wr_burst_addr 		<='h000000;
//		rd_burst_addr 		<='h000000;
		
		write_read_len 		<= 32'd0;
	end

    else if( write_read_len == IMAGE_SIZE )
        begin
//           if( angle == 359 )                
//               angle	<=	'b0;
//           else
//               angle	<=	angle	+	16'd1;  

			angle	<=		angle_temp;

			i_en			<=	1'b0;
			state			<=	IDLE;
            write_read_len	<= 	32'd0;
			image_addr_flag	<=	~image_addr_flag;	
			
			wr_burst_req 	<=	1'b0;
			rd_burst_req 	<=	1'b0;		
		
			wr_burst_addr 	<=	32'd2073600;
//			rd_burst_addr 	<=	'h000000;
			
        end


	else
	begin
		case(state)
			IDLE:			

//			if( time_cnt == 3  ) 
			begin
				i_en			<=	1'b0;
				state 			<= 	MEM_READ;
				rd_burst_req 	<= 	1'b1;									

//				rd_burst_addr 	<= 	rd_burst_addr_start	+	write_read_len;					
//				rd_burst_addr 	<= 	rd_burst_addr_start	+	x_cnt	+	256*y_cnt    - x_shift_cnt -   3*256*y_shift_cnt;					
//				rd_burst_addr 	<= 	rd_burst_addr_start	+	Scaling_Ratio*x_cnt	+	Scaling_Ratio*256*y_cnt- x_shift_cnt -   3*256*y_shift_cnt;					
//				rd_burst_addr 	<= 	rd_burst_addr_start	+	x_rotate	+	1024*y_rotate;

					
			end
			
			MEM_READ:
			begin
				if(rd_burst_finish)
				begin
					state 			<= 	MEM_WRITE;					
					rd_burst_req 	<= 	1'b0;				
					wr_burst_req 	<=	1'b1;
					
//					wr_burst_addr 	<= 	wr_burst_addr_start  +	write_read_len;					
					wr_burst_addr 	<= 	wr_burst_addr_start  +	x_cnt	+	1024*y_cnt;
				end
			end
			
			MEM_WRITE:
			begin
				if(wr_burst_finish)
				begin
					state 			<=	IDLE;
					wr_burst_req 	<=	1'b0;
					write_read_len 	<= write_read_len +	1'b1;
					i_en			<=	1'b1;
				end
			end

			default:
				state <= IDLE;
		endcase
	end
end


endmodule