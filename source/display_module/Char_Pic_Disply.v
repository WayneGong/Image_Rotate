module Char_Pic_Disply
( 	
	input                   rst_n,   
	input                   clk,
	input		[11:0]		x,        // video position X
	input		[11:0]		y,         // video position y
		
	input                   i_hs,    
	input                   i_vs,    
	input                   i_de,    
	input		[23:0]		i_data,
    input       [15:0]	    display_number,
    input       [4:0]       display_model,	

	output                  o_hs,    
	output                  o_vs,    
	output                  o_de,    
	output		[23:0]		o_data

);

reg       [40:0]    time_cnt;

reg 			de_d0;
reg 			de_d1;
reg 			vs_d0;
reg 			vs_d1;
reg 			hs_d0;
reg 			hs_d1;
reg		[23:0]	vout_data;	

wire	[11:0] 	x_cnt	=	x;
wire	[11:0]	y_cnt	=	y;


parameter	LSB			=	2;
parameter	LSB2		=	2;

parameter	L_y			=  	0;
parameter	N_y			=	1;

parameter	X_L			=	12;
parameter	X_N			=	27;

assign o_de 	= 	de_d0;
assign o_vs 	= 	vs_d0;
assign o_hs 	= 	hs_d0;
assign o_data 	= 	vout_data;

always@(posedge clk)
begin
	de_d0 		<= 	i_de	;
	vs_d0 		<= 	i_vs	;	
	hs_d0 		<= 	i_hs	;
end

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
        time_cnt    <=    'b0;
    else 
        time_cnt    <=    time_cnt    +    5;
end


wire	[3:0]	char1	=	0	;
wire	[3:0]	char2	=	0	;
wire	[3:0]	char3	=	(display_number%1000)/100	;
wire	[3:0]	char4	=	(display_number%100)/10	;
wire	[3:0]	char5	=	(display_number%10)/1		;

reg    	[4:0]	char_xian	;
reg	    [4:0]	char_shi	;
reg	    [4:0]	char_mo		;
reg	    [4:0]	char_shi2	;

always@( posedge clk  )
begin
    case( display_model )
        0        :
            begin
                char_xian	<=   16     ;
                char_shi	<=   17     ;
                char_mo		<=   2     ;
                char_shi2	<=   3     ;
            end
        1        :begin
                char_xian	<=  6      ;
                char_shi	<=   7     ;
                char_mo		<=  2      ;
                char_shi2	<=  3      ;
            end
        2        :begin
                char_xian	<=  10      ;
                char_shi	<=  11      ;
                char_mo		<=  2      ;
                char_shi2	<=  3      ;

            end
        3        :begin
                char_xian	<=  10      ;
                char_shi	<=  11      ;
                char_mo		<=  2      ;
                char_shi2	<=  3      ;

            end
        4        :begin
                char_xian	<=   8     ;
                char_shi	<=   9     ;
                char_mo		<=  2      ;
                char_shi2	<=   3     ;

            end
        5        :begin
                char_xian	<=  12      ;
                char_shi	<=  13     ;
                char_mo		<=  0      ;
                char_shi2	<=  1     ;
            end
        6        :begin
                char_xian	<=  14      ;
                char_shi	<=   15    ;
                char_mo		<=  0      ;
                char_shi2	<=  1     ;
            end
			
        default    :
            begin
                char_xian	<=   16     ;
                char_shi	<=    17    ;
                char_mo		<=  2      ;
                char_shi2	<=  3      ;
            end	
    endcase
end

wire	disp_region1	=	( y_cnt[11:4+LSB2] == L_y )&& ( x_cnt[11:4+LSB2] == X_L );
wire	disp_region2	=	( y_cnt[11:4+LSB2] == L_y )&& ( x_cnt[11:4+LSB2] == X_L+1 );
wire	disp_region3	=	( y_cnt[11:4+LSB2] == L_y )&& ( x_cnt[11:4+LSB2] == X_L+2 );
wire	disp_region4	=	( y_cnt[11:4+LSB2] == L_y )&& ( x_cnt[11:4+LSB2] == X_L+3 );  
                                                              
wire	disp_region5	=	( y_cnt[11:4+LSB] == N_y )&& ( x_cnt[11:3+LSB] == X_N );
wire	disp_region6	=	( y_cnt[11:4+LSB] == N_y )&& ( x_cnt[11:3+LSB] == X_N+1 );
wire	disp_region7	=	( y_cnt[11:4+LSB] == N_y )&& ( x_cnt[11:3+LSB] == X_N+2 );
wire	disp_region8	=	( y_cnt[11:4+LSB] == N_y )&& ( x_cnt[11:3+LSB] == X_N+3 );
wire	disp_region9	=	( y_cnt[11:4+LSB] == N_y )&& ( x_cnt[11:3+LSB] == X_N+4 );
	
wire		[255:0]		char2_array_xian;
wire		[255:0]		char2_array_shi;
wire		[255:0]		char2_array_mo;
wire		[255:0]		char2_array_shi2;

wire		[127:0]		char_array1;
wire		[127:0]		char_array2;
wire		[127:0]		char_array3;
wire		[127:0]		char_array4;
wire		[127:0]		char_array5;

char2_array_decode  char2_array_decode_m1(	.char2(	char_xian	),	.char2_array(	char2_array_xian	)	);	
char2_array_decode  char2_array_decode_m2(	.char2(	char_shi 	),	.char2_array(	char2_array_shi		)	);	
char2_array_decode  char2_array_decode_m3(	.char2(	char_mo		),	.char2_array(	char2_array_mo		)	);	
char2_array_decode  char2_array_decode_m4(	.char2(	char_shi2   ),	.char2_array(	char2_array_shi2	)	);

char_array_decode  char_array_decode_m1(	.char(	char1	),	.char_array(	char_array1	)	);	
char_array_decode  char_array_decode_m2(	.char(	char2	),	.char_array(	char_array2	)	);	
char_array_decode  char_array_decode_m3(	.char(	char3	),	.char_array(	char_array3	)	);	
char_array_decode  char_array_decode_m4(	.char(	char4	),	.char_array(	char_array4	)	);	
char_array_decode  char_array_decode_m5(	.char(	char5	),	.char_array(	char_array5	)	);	

parameter OSD_WIDTH   =  12'd512;
parameter OSD_HEGIHT  =  12'd33;//OK

reg        [15:0]  osd_ram_addr;
wire        [7:0]  q;
reg[11:0]  osd_x;
reg[11:0]  osd_y;
reg        region_active;
reg        region_active_d0;
reg        region_active_d1;
reg        region_active_d2;

always@(posedge clk)
begin
	if(y_cnt >= 12'd9 && y_cnt <= 12'd9 + OSD_HEGIHT - 12'd1 && x_cnt >= 12'd9 && x_cnt  <= 12'd9 + OSD_WIDTH - 12'd1)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
end

always@(posedge clk)
begin
	region_active_d0 <= region_active;
	region_active_d1 <= region_active_d0;
	region_active_d2 <= region_active_d1;
end

//delay 2 clock
//region_active_d0
always@(posedge clk)
begin
	if(region_active_d0 == 1'b1)
		osd_x <= osd_x + 12'd1;
	else
		osd_x <= 12'd0;
end

always@(posedge clk)
begin
	if( vs_d0 == 1'b1 && i_vs == 1'b0)
		osd_ram_addr <= 16'd0;
	else if(region_active == 1'b1)
		osd_ram_addr <= osd_ram_addr + 16'd1;
end

osd_rom osd_rom_m0 
(
    .addr       (osd_ram_addr[15:3]),
    .clk        (clk),
    .rst        (1'b0),
    .rd_data    (q)
);


always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		vout_data	<=	24'b0;
    else if(region_active_d0 == 1'b1 && q[osd_x[2:0]] == 1'b1)		
        vout_data <= 24'hff0000;  
    else if(region_active_d0 == 1'b1 )      
        vout_data <= 24'hffffff;
    else if( ( ( x_cnt >= 1024-4*16*4 )  && ( y_cnt == 16*4 ) ) || ( ( x_cnt >= 1024-5*8*4 )  && ( y_cnt == 16*4*2 ) )  )  
        vout_data	<=	24'h0;
	else if( disp_region1 )
		vout_data	<=	{24{char2_array_xian[255-(16*y_cnt[3+LSB2:0+LSB2]+x_cnt[3+LSB2:0+LSB2])]}};
	else if( disp_region2 )
		vout_data	<=	{24{char2_array_shi[255-(16*y_cnt[3+LSB2:0+LSB2]+x_cnt[3+LSB2:0+LSB2])]}};
	else if( disp_region3 )
		vout_data	<=	{24{char2_array_mo[255-(16*y_cnt[3+LSB2:0+LSB2]+x_cnt[3+LSB2:0+LSB2])]}};
	else if( disp_region4 )
		vout_data	<=	{24{char2_array_shi2[255-(16*y_cnt[3+LSB2:0+LSB2]+x_cnt[3+LSB2:0+LSB2])]}};
		
	else if( disp_region5 )
		vout_data	<=	{24{char_array1[127-(8*y_cnt[3+LSB:0+LSB]+x_cnt[2+LSB:0+LSB])]}};
	else if( disp_region6 )
		vout_data	<=	{24{char_array2[127-(8*y_cnt[3+LSB:0+LSB]+x_cnt[2+LSB:0+LSB])]}};
	else if( disp_region7 )
		vout_data	<=	{24{char_array3[127-(8*y_cnt[3+LSB:0+LSB]+x_cnt[2+LSB:0+LSB])]}};
	else if( disp_region8 )
		vout_data	<=	{24{char_array4[127-(8*y_cnt[3+LSB:0+LSB]+x_cnt[2+LSB:0+LSB])]}};
	else if( disp_region9 )
		vout_data	<=	{24{char_array5[127-(8*y_cnt[3+LSB:0+LSB]+x_cnt[2+LSB:0+LSB])]}};
	
	else
		vout_data	<=	i_data;
end


endmodule 