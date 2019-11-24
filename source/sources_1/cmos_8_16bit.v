//////////////////////////////////////////////////////////////////////////////////
//  CMOS sensor 8bit data is converted to 16bit data                            //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/7/19     meisq          1.0         Original
//*******************************************************************************/

module cmos_8_16bit
#(
	parameter	SAMPLING_RATE		=	2
)
(
	input              rst,
	input              pclk,
	input			   cmos_vsync,
	input [7:0]        pdata_i,
	input              de_i,
	output reg[15:0]   pdata_o,
	output reg         hblank,
output    reg	[5:0]	frame_cnt,
	output reg         de_o
);
reg[7:0] pdata_i_d0;
reg[11:0] x_cnt;

reg cmos_vsync_d0;
reg cmos_vsync_d1;

wire	data_en		=	x_cnt[0];


wire	frame_start	=	( cmos_vsync_d0 == 1'b1 && cmos_vsync_d1 == 1'b0 );

parameter	display_model	=	0;

always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		cmos_vsync_d0 <= 1'b0;
		cmos_vsync_d1 <= 1'b0;
	end
	else
	begin
		cmos_vsync_d0 <= cmos_vsync;
		cmos_vsync_d1 <= cmos_vsync_d0;
	end
end



always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		frame_cnt <=	1'b0;
	else if( frame_start ) 
		begin
			if( frame_cnt == ( SAMPLING_RATE -1 ) )
				frame_cnt <=	1'b0;
			else
				frame_cnt <= 	frame_cnt	+	1'b1;
	end
end


always@(posedge pclk)
begin
	pdata_i_d0 <= pdata_i;
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		x_cnt <= 12'd0;
	else if(de_i)
		x_cnt <= x_cnt + 12'd1;
	else
		x_cnt <= 12'd0;
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		de_o <= 1'b0;
//	else if( de_i && data_en && ( frame_cnt == ( SAMPLING_RATE -1 ) ) )
	else if( de_i && data_en  )
		de_o <= 1'b1;
	else
		de_o <= 1'b0;
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		hblank <= 1'b0;
	else
		hblank <= de_i;
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		pdata_o <= 16'd0;
		
//	else if(de_i && x_cnt[0])

	else if(de_i && data_en)
		pdata_o <= {pdata_i_d0,pdata_i};
	else
		pdata_o <= 16'd0;
end

endmodule 