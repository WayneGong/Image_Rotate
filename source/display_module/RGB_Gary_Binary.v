module  RGB_Gary_Binary
(
	input                   rst_n,   
	input                   clk,
	input                   i_hs,    
	input                   i_vs,    
	input                   i_de, 
    input       [7:0]       disp_model,
	input       [4:0]       display_model,
	input       [7:0]       threshold_set,
	input		[2:0]		key, 
	input		[11:0]		i_x,        // video position X
	input		[11:0]		i_y,         // video position y	
	input		[23:0]		i_data,
	output					th_flag,   
	output		[23:0]		o_data,
	output		[11:0]		o_x,        // video position X
	output		[11:0]		o_y,         // video position y	
	
	output                  o_hs,    
	output                  o_vs,    
	output                  o_de

);


reg		[30:0]				time_cnt;
reg		[2:0]				frame_count;
reg		[4:0]				model_count;
reg		[7:0]				threshold	;
reg		[23:0]				image_data;
reg 	[23:0]				vout_data;
wire	[16:0]				Gary_data;
wire						Binary_data;
reg							motion_data;

reg		[7:0]				Gary_extend;
wire	[11:0] 	x_cnt	=	i_x;
wire	[11:0]	y_cnt	=	i_y;


reg		i_vs_d0,i_vs_d1;


assign	o_data	=	image_data;
assign	o_hs	=	i_hs;
assign	o_vs	=	i_vs;	
assign	o_de	=	i_de;
assign	o_x		=	i_x;
assign	o_y		=   i_y;


assign	th_flag		=	Binary_data;
assign	Gary_data	=	i_data[23:16]*76+ i_data[15: 8]*150+i_data[ 7: 0]*30	;	
assign	Binary_data	=	(Gary_data[15:8]>=threshold)?1'b1:1'b0;



always@(*)
begin
	if( Gary_data[15:8] < 64 )
		Gary_extend	=	{1'b0,Gary_data[15:9]};
	else if( Gary_data[15:8] < 192)
		Gary_extend	=	32	+	( Gary_data[15:8] - 32 ) * 2;
	else
		Gary_extend	=	223	+	( Gary_data[15:8] - 255 ) / 2;
end

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		model_count	<=	2'd0;	
	else 
		model_count	<=	display_model	-	4;
end

//always@(posedge clk or negedge rst_n)
//begin
//	if(rst_n == 1'b0)
//		model_count	<=	2'd0;
//	else if( key[0] )
//		model_count	<=	model_count	+	1'b1;		
//	else if( disp_model == 8'b0000_0001 )
//		model_count	<=	2'd0;
//	else if( disp_model == 8'b0000_0010 )
//		model_count	<=	2'd1;
//	else if( disp_model == 8'b0000_0100 )
//		model_count	<=	2'd2;		
//	else
//		model_count	<=	model_count;
//end

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		threshold	<=	8'd40;
	else 
		threshold	<=	threshold_set;

end


//always@(posedge clk or negedge rst_n)
//begin
//	if(rst_n == 1'b0)
//		threshold	<=	8'd40;
//	else if(  key[1]  && ( model_count == 2 ) )
//		threshold	<=	threshold	+	8'd5;
//    else if(  key[2]  && ( model_count == 2 ) )
//		threshold	<=	threshold	-	8'd5;
//	else if( disp_model == 8'b0000_1000 )
//		threshold	<=	threshold_set;
//	else
//		threshold	<=	threshold;
//end


always@(*)
begin  
	case( model_count )
		0		:	image_data	=	i_data;
		1		:	image_data	=	{Gary_data[15:8] , Gary_data[15:8] , Gary_data[15:8]};
		2		:	image_data	=	{24{Binary_data} };
		3		:	image_data	=	{3{Gary_extend} };	
		default	:	image_data	=	i_data;
	endcase
end


//wire	[7:0]	dout0;
//wire	[7:0]	dout1;
//reg 			w_fifo_0_en,w_fifo_1_en;
//reg 	[7:0]	w_fifo_0_data;
//reg 	[7:0]	w_fifo_1_data;
//reg 			r_fifo_en;
//
//
//
//always @(*) 
//begin
//	if(	i_y != 'd0 	&& 	i_y != 'd1	)
//		r_fifo_en = i_de;	
//	else 
//		r_fifo_en =0;	
//end
//
//buffer_line_1024 buffer_line1 
//(
//    .clk        	(	clk						),
//    .rst        	(	~rst					),
//    .wr_en			(	w_fifo_0_en					),
//    .wr_data		(	w_fifo_0_data			),
//	.wr_full		(							),
//		
//    .rd_en			(	r_fifo_en				),
//	.rd_empty		(							),
//    .rd_data		(	fifo1_rd_data			)
//	
//);
//
//buffer_line_1024 buffer_line2 
//(
//    .clk        	(	clk			),
//    .rst        	(	~rst		),
//    
//	.wr_en			(	w_fifo_1_en			),
//    .wr_data		(	w_fifo_1_data		),
//	.wr_full		(				),
//		
//    .rd_en			(	r_fifo_en	),
//	.rd_empty		(				),
//    .rd_data		(	dout1		)
//	
//);
//
//reg 	[23:0]	reg000102,reg101112,reg202122;
//
//always @(posedge clk ) 
//begin
//	if (r_fifo_en == 1'b1) 
//		begin
//			reg000102 <= {reg000102[15:0],dout0};
//			reg101112 <= {reg101112[15:0],dout1};
//			reg202122 <= {reg202122[15:0],Gary_data[15:8]};
//		end
//end

//
//always@(posedge clk or negedge rst_n)
//begin
//	if(rst_n == 1'b0)
//		frame_count	<=	3'd0;
//	else if( frame_start )
//		frame_count	<=	frame_count	+	1'b1;
//	else
//		frame_count	<=	frame_count;
//end
//
//always@(posedge clk )
//begin
//	i_vs_d0	<=	i_vs;
//	i_vs_d1	<=	i_vs_d0;
//end
//
//reg	[19:0]	waddr;
//reg	[19:0]	raddr;
//
//always@(posedge clk or negedge rst_n)
//begin
//	if(rst_n == 1'b0)
//		waddr	<=	1'b0;
//	else if( waddr == (1024*768 -1 ))
//		waddr	<=	1'b0;
//	else if( i_de )
//		waddr	<=	waddr	+	1'b1;
//end
//
//always@(posedge clk or negedge rst_n)
//begin
//	if(rst_n == 1'b0)
//		raddr	<=	1'b0;
//	else if( raddr == (1024*768 -1 ))
//		raddr	<=	1'b0;
//	else if( i_de )
//		raddr	<=	raddr	+	1'b1;
//end

//wire		data_in	=	Binary_data;
//wire		wr_en	=	i_de &&	( frame_count == 3'b011);
//
//wire		data_out;
//
//always@(*)
//begin 
//    if( !wr_en ) begin
//        if( Binary_data == data_out )
//            motion_data	<=	1;
//        else
//            motion_data	<=	0;
//       end
//    
//    else
//        motion_data	<=	1;
//end
//
//BRAM BRAM_inst
//(
//	.clk		(	clk			) ,	// input  clk_sig
//	.wr_en		(	wr_en		) ,	// input  wr_en
//	.waddr		(	waddr		) ,	// input [MEMWIDTH-1:0] waddr
//	.raddr		(	raddr		) ,	// input [MEMWIDTH-1:0] raddr
//	.data_in	(	data_in		) ,	// input [DATAWIDTH-1:0] data_in
//	.data_out	(	data_out	) 	// output [DATAWIDTH-1:0] data_out
//);
//
//defparam BRAM_inst.MEMDEPTH 	= 1024*768;
//defparam BRAM_inst.MEMWIDTH 	= 20;
//defparam BRAM_inst.DATAWIDTH 	= 1;



endmodule
	  