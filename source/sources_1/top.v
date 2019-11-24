//////////////////////////////////////////////////////////////////////////////////
//  ov5640 lcd display                                                          //
//                                                                              //
//  Author: lhj                                                                 //
//                                                                              //
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
//  2018/01/11     lhj          1.0         Original
//*******************************************************************************/

 module top(
input                       sys_clk,
input                       rst_n,
input		[3:1]			key,
output			            uart_tx,
input			            uart_rx,
output       [3:0]            led,

inout                       cmos_scl,         
inout                       cmos_sda,         
input                       cmos_vsync,       
input                       cmos_href,        
input                       cmos_pclk,         
output                      cmos_xclk,         
input[7:0]                  cmos_db,
//ddr                                                           
//output reg                           clk_led                ,
//output                               pll_lock               ,
//output                               ddr_init_done          ,
//output                               ddrphy_rst_done        ,                                                                                                                          
input                                pad_loop_in            ,
input                                pad_loop_in_h          ,
output                               pad_rstn_ch0           ,
output                               pad_ddr_clk_w          ,
output                               pad_ddr_clkn_w         ,
output                               pad_csn_ch0            ,
output [15:0]                        pad_addr_ch0           ,
inout  [16-1:0]                      pad_dq_ch0             ,
inout  [16/8-1:0]                    pad_dqs_ch0            ,
inout  [16/8-1:0]                    pad_dqsn_ch0           ,
output [16/8-1:0]                    pad_dm_rdqs_ch0        ,
output                               pad_cke_ch0            ,
output                               pad_odt_ch0            ,
output                               pad_rasn_ch0           ,
output                               pad_casn_ch0           ,
output                               pad_wen_ch0            ,
output [2:0]                         pad_ba_ch0             ,
output                               pad_loop_out           ,
output                               pad_loop_out_h         ,
//output                               err_flag,   
//hdmi output        
output                             tmds_clk_p,
output                             tmds_clk_n,
output[2:0]                        tmds_data_p,       
output[2:0]                        tmds_data_n                       
);

parameter	SAMPLING_RATE		=	2;

parameter MEM_DATA_BITS          = 64;             //external memory user interface data width
parameter ADDR_BITS              = 25;             //external memory user interface address width
parameter BUSRT_BITS             = 10;             //external memory user interface burst width

wire                            wr_burst_data_req;
wire                            wr_burst_finish;
wire                            rd_burst_finish;
wire                            rd_burst_req;
wire                            wr_burst_req;
wire[BUSRT_BITS - 1:0]          rd_burst_len;
wire[BUSRT_BITS - 1:0]          wr_burst_len;
wire[ADDR_BITS - 1:0]           rd_burst_addr;
wire[ADDR_BITS - 1:0]           wr_burst_addr;
wire                            rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data;

//axi 2

wire                            wr_burst_data_req_2;
wire                            wr_burst_finish_2;
wire                            rd_burst_finish_2;
wire                            rd_burst_req_2;
wire                            wr_burst_req_2;
wire[BUSRT_BITS - 1:0]          rd_burst_len_2;
wire[BUSRT_BITS - 1:0]          wr_burst_len_2;
wire[ADDR_BITS - 1:0]           rd_burst_addr_2;
wire[ADDR_BITS - 1:0]           wr_burst_addr_2;
wire                            rd_burst_data_valid_2;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data_2;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data_2;

wire                            read_req;
wire                            read_req_ack;
wire                            read_en;
wire[15:0]                      read_data;
wire                            write_en;
wire[15:0]                      write_data;
wire                            write_req;
wire                            write_req_ack;
wire                            video_clk;         //video pixel clock
wire                            video_clk5x;


wire[15:0]                      cmos_16bit_data;
wire                            cmos_16bit_wr;
wire[1:0]                       write_addr_index;
wire[1:0]                       read_addr_index;
wire[9:0]                       lut_index;
wire[31:0]                      lut_data;

wire                            ui_clk;
wire                            ui_clk_sync_rst;
wire                            init_calib_complete;
// Master Write Address
wire [3:0]                      s00_axi_awid;
wire [63:0]                     s00_axi_awaddr;
wire [7:0]                      s00_axi_awlen;    // burst length: 0-255
wire [2:0]                      s00_axi_awsize;   // burst size: fixed 2'b011
wire [1:0]                      s00_axi_awburst;  // burst type: fixed 2'b01(incremental burst)
wire                            s00_axi_awlock;   // lock: fixed 2'b00
wire [3:0]                      s00_axi_awcache;  // cache: fiex 2'b0011
wire [2:0]                      s00_axi_awprot;   // protect: fixed 2'b000
wire [3:0]                      s00_axi_awqos;    // qos: fixed 2'b0000
wire [0:0]                      s00_axi_awuser;   // user: fixed 32'd0
wire                            s00_axi_awvalid;
wire                            s00_axi_awready;
// master write data
wire [63:0]                     s00_axi_wdata;
wire [7:0]                      s00_axi_wstrb;
wire                            s00_axi_wlast;
wire [0:0]                      s00_axi_wuser;
wire                            s00_axi_wvalid;
wire                            s00_axi_wready;
// master write response
wire [3:0]                      s00_axi_bid;
wire [1:0]                      s00_axi_bresp;
wire [0:0]                      s00_axi_buser;
wire                            s00_axi_bvalid;
wire                            s00_axi_bready;
// master read address
wire [3:0]                      s00_axi_arid;
wire [63:0]                     s00_axi_araddr;
wire [7:0]                      s00_axi_arlen;
wire [2:0]                      s00_axi_arsize;
wire [1:0]                      s00_axi_arburst;
wire [1:0]                      s00_axi_arlock;
wire [3:0]                      s00_axi_arcache;
wire [2:0]                      s00_axi_arprot;
wire [3:0]                      s00_axi_arqos;
wire [0:0]                      s00_axi_aruser;
wire                            s00_axi_arvalid;
wire                            s00_axi_arready;
// master read data
wire [3:0]                      s00_axi_rid;
wire [63:0]                     s00_axi_rdata;
wire [1:0]                      s00_axi_rresp;
wire                            s00_axi_rlast;
wire [0:0]                      s00_axi_ruser;
wire                            s00_axi_rvalid;
wire                            s00_axi_rready;

//axi  2

// Master Write Address
wire [3:0]                      s01_axi_awid;
wire [63:0]                     s01_axi_awaddr;
wire [7:0]                      s01_axi_awlen;    // burst length: 0-255
wire [2:0]                      s01_axi_awsize;   // burst size: fixed 2'b011
wire [1:0]                      s01_axi_awburst;  // burst type: fixed 2'b01(incremental burst)
wire                            s01_axi_awlock;   // lock: fixed 2'b00
wire [3:0]                      s01_axi_awcache;  // cache: fiex 2'b0011
wire [2:0]                      s01_axi_awprot;   // protect: fixed 2'b000
wire [3:0]                      s01_axi_awqos;    // qos: fixed 2'b0000
wire [0:0]                      s01_axi_awuser;   // user: fixed 32'd0
wire                            s01_axi_awvalid;
wire                            s01_axi_awready;
// master write data
wire [63:0]                     s01_axi_wdata;
wire [7:0]                      s01_axi_wstrb;
wire                            s01_axi_wlast;
wire [0:0]                      s01_axi_wuser;
wire                            s01_axi_wvalid;
wire                            s01_axi_wready;
// master write response
wire [3:0]                      s01_axi_bid;
wire [1:0]                      s01_axi_bresp;
wire [0:0]                      s01_axi_buser;
wire                            s01_axi_bvalid;
wire                            s01_axi_bready;
// master read address
wire [3:0]                      s01_axi_arid;
wire [63:0]                     s01_axi_araddr;
wire [7:0]                      s01_axi_arlen;
wire [2:0]                      s01_axi_arsize;
wire [1:0]                      s01_axi_arburst;
wire [1:0]                      s01_axi_arlock;
wire [3:0]                      s01_axi_arcache;
wire [2:0]                      s01_axi_arprot;
wire [3:0]                      s01_axi_arqos;
wire [0:0]                      s01_axi_aruser;
wire                            s01_axi_arvalid;
wire                            s01_axi_arready;
// master read data
wire [3:0]                      s01_axi_rid;
wire [63:0]                     s01_axi_rdata;
wire [1:0]                      s01_axi_rresp;
wire                            s01_axi_rlast;
wire [0:0]                      s01_axi_ruser;
wire                            s01_axi_rvalid;
wire                            s01_axi_rready;


wire                            clk_200MHz;

wire             [5:0]			frame_cnt;

wire                            hdmi_hs;
wire                            hdmi_vs;
wire                            hdmi_de;
wire[7:0]                       hdmi_r;
wire[7:0]                       hdmi_g;
wire[7:0]                       hdmi_b;

wire	[2:0]					key_out;

wire[23:0]             			vout_data;
wire							vout_hs,vout_vs,vout_de;
		
wire[15:0]						timing_data;
wire							timing_hs,	timing_vs,	timing_de;

wire[23:0]						xy_data;
wire							xy_hs,	xy_vs,	xy_de;
wire[11:0]						gen_x,	gen_y;

wire[23:0]						GB_data;
wire							GB_hs,	GB_vs,	GB_de;
wire[11:0]						GB_x,	GB_y;

wire[23:0]						char_data;
wire							char_hs,	char_vs,	char_de;





wire			image_addr_flag;

assign 	vout_hs    	=	char_hs;
assign 	vout_vs    	= 	char_vs;
assign 	vout_de    	= 	char_de;
assign	vout_data	=	char_data;

//IO ¶Ë¿ÚÊä³ö									   
assign 	hdmi_hs 	= 	vout_hs;
assign 	hdmi_vs		= 	vout_vs;
assign 	hdmi_de 	= 	vout_de;	
	
assign 	hdmi_r 	 	= 	vout_data[23:16];
assign 	hdmi_g  	= 	vout_data[15:8];
assign 	hdmi_b  	= 	vout_data[7:0];


assign write_en = cmos_16bit_wr;
assign write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};



/* clk_200M clk_ref_m0
(
.pll_rst(1'b0),
.clkin1(sys_clk),
.pll_lock(),
.clkout0(clk_200MHz),
.clkout1(cmos_xclk)
);*/

assign			led		=	{key,1'b1};

//
//wire	[7:0]	tx_data;	
//wire	[7:0]	rx_data;

//wire			tx_en;		
//wire			rx_done;
//wire	[7:0]	uart_code_out;

//
//assign			tx_data	=	rx_data;
//assign			tx_en	=	rx_done;
//
//uart_top 
//#(
//	.SYS_CLK_FRP	(	65_000_000	),
//	.BAUDRATE		(	115200    	)
//)
//uart_top_test
//(
//	.clk			(	video_clk		),
//	.rst_n			(	rst_n		),	
//	
//	.tx_data		(	tx_data		),		//input
//	.tx_en			(	tx_en		),		//input
//	.uart_tx		(	uart_tx		),		//output
//					
//	.rx_data		(	rx_data		),		//output	
//	.rx_done		(	rx_done		),		//output
//	.uart_rx		(	uart_rx		)		//input
//);
//
//uart_decode uart_decode_m0 
//(
//    .clk			(	video_clk		),
//    .rst_n			(	rst_n		),
//    .rx_en			(	rx_done		),
//    .rx_data		(	rx_data		),
//	.threshold		(	threshold	),
//    .code_out		(	uart_code_out	)
//);
//
//reg		[3:0]	led_reg;
//
//always@(posedge video_clk,negedge rst_n)
//begin
//	if(!rst_n)
//		led_reg	<=	4'b0000;
//	else 
//		led_reg	<=	~uart_code_out[3:0];	
//end

video_pll video_pll_m0
(
  .clkin1                    (sys_clk                  ),
  .clkout0                   (video_clk                ),		//65MHz 
  .clkout1                   (video_clk5x              ),		//325MHz
  .clkout2                   (cmos_xclk                ),		//24MHz
  .pll_rst                   (1'b0                     ),
  .pll_lock                  (                         )
);

dvi_encoder dvi_encoder_m0
(
	.pixelclk      (video_clk          ),// system clock
	.pixelclk5x    (video_clk5x        ),// system clock x5
	.rstin         (~rst_n             ),// reset
	.blue_din      (hdmi_b            ),// Blue data in
	.green_din     (hdmi_g            ),// Green data in
	.red_din       (hdmi_r            ),// Red data in
	.hsync         (hdmi_hs           ),// hsync data
	.vsync         (hdmi_vs           ),// vsync data
	.de            (hdmi_de         ),// data enable
	.tmds_clk_p    (tmds_clk_p         ),
	.tmds_clk_n    (tmds_clk_n         ),
	.tmds_data_p   (tmds_data_p        ),//rgb
	.tmds_data_n   (tmds_data_n        ) //rgb
);

//I2C master controller
i2c_config i2c_config_m0(
	.rst                        (~rst_n                   ),
	.clk                        (sys_clk                  ),
	.clk_div_cnt                (16'd99                   ),
	.i2c_addr_2byte             (1'b1                     ),
	.lut_index                  (lut_index                ),
	.lut_dev_addr               (lut_data[31:24]          ),
	.lut_reg_addr               (lut_data[23:8]           ),
	.lut_reg_data               (lut_data[7:0]            ),
	.error                      (                         ),
	.done                       (                         ),
	.i2c_scl                    (cmos_scl                 ),
	.i2c_sda                    (cmos_sda                 )
);
////configure look-up table
lut_ov5640_rgb565_1024_768 lut_ov5640_rgb565_1024_768_m0(
	.lut_index                  (lut_index                ),
	.lut_data                   (lut_data                 )
);
//CMOS sensor 8bit data is converted to 16bit data
cmos_8_16bit 
#(
	.SAMPLING_RATE	(	SAMPLING_RATE	)
)
cmos_8_16bit_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.cmos_vsync                 (cmos_vsync               ),
    .pdata_i                    (cmos_db                  ),
	.de_i                       (cmos_href                ),
	.pdata_o                    (cmos_16bit_data          ),
	.hblank                     (                         ),
    .frame_cnt                  (frame_cnt                ),
	.de_o                       (cmos_16bit_wr            )
);
//CMOS sensor writes the request and generates the read and write address index
cmos_write_req_gen 
#(
	.SAMPLING_RATE	(	SAMPLING_RATE	)
)
cmos_write_req_gen_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.frame_cnt                   (frame_cnt        ),
    .cmos_vsync                 (cmos_vsync               ),
	.write_req                  (write_req                ),
	.write_addr_index           (write_addr_index         ),
	.read_addr_index            (read_addr_index          ),
	.write_req_ack              (write_req_ack            )
);


//video frame data read-write control
frame_read_write frame_read_write_m0
(
	.rst                        (~rst_n                   ),
	.mem_clk                    (ui_clk                   ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.read_clk                   (video_clk                ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_finish                (                         ),
	.read_addr_0                (24'd0                    ), //The first frame address is 0
	.read_addr_1                (24'd2073600              ), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (24'd4147200              ),
	.read_addr_3                (24'd6220800              ),
	
//	.read_addr_index            (read_addr_index          ),
//	.read_addr_index            (1							),
	.read_addr_index            (image_addr_flag + 2	),
	
	.read_len                   (786432                ),//frame size  786432
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),

	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.write_clk                  (cmos_pclk                ),
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_finish               (                         ),
	.write_addr_0               (24'd0                    ),
	.write_addr_1               (24'd2073600              ),
	.write_addr_2               (24'd4147200              ),
	.write_addr_3               (24'd6220800              ),
	
//	.write_addr_index           (write_addr_index         ),	
	.write_addr_index           (image_addr_flag         ),
	
	.write_len                  (786432                    ), //frame size  = 1024*768
	.write_en                   (write_en                 ),
	.write_data                 (write_data               )
);

key_Module key_Module_inst
(
	.clk			(	ui_clk		) ,	// input  clk_sig
	.rst_n			(	rst_n			) ,	// input  rst_n_sig
	.key_in			(	key				) ,	// input [2:0] key_in_sig
	.key_out		(	key_out			) 	// output [2:0] key_out_sig
);

wire    [15:0]	display_number;
wire    [4:0]	display_model;
wire	[7:0]	threshold;

image_processing image_process_m0 (
    .rst					(	~rst_n	),
    .mem_clk				(	ui_clk	),
	.key_out                (    key_out                	),
	.wr_burst_req			(	wr_burst_req_2				),
	.wr_burst_addr			(	wr_burst_addr_2				),
	.wr_burst_len			(	wr_burst_len_2				),	
	.wr_burst_data_req		(	wr_burst_data_req_2			),
	.wr_burst_data			(	wr_burst_data_2				),
	.wr_burst_finish		(	wr_burst_finish_2			),
	
    .rd_burst_req			(	rd_burst_req_2				),
    .rd_burst_addr			(	rd_burst_addr_2				),
	.rd_burst_len			(	rd_burst_len_2				),	
    .rd_burst_data_valid	(	rd_burst_data_valid_2		),
    .rd_burst_data			(	rd_burst_data_2				),
    .rd_burst_finish		(	rd_burst_finish_2			), 
	.image_addr_flag		(	image_addr_flag				),
	.display_number         ( 	display_number             	),
    .display_model          (  	display_model           	),
	.threshold				(	threshold					),
	.error					(								)
);




ddr3 u_ipsl_hmemc_top (
    .pll_refclk_in        (sys_clk        ),
    .ddr_rstn_key         (rst_n          ),   
    .pll_aclk_0           (              ),
    .pll_aclk_1           (ui_clk       ),
    .pll_aclk_2           (              ),
    .pll_lock             (      ),
    .ddrphy_rst_done      (),
 
    .ddrc_init_done       ( ),
   // .pll_lock             (pll_lock      ),
   // .ddrphy_rst_done      (ddrphy_rst_done),
  //  .ddrphy_rst_done      (ui_clk_sync_rst),
   // .ddrc_init_done       (ddr_init_done ),
    .ddrc_rst         (0),    
      
    .areset_1         (0),               
    .aclk_1           (ui_clk),                                                        
    .awid_1           (s00_axi_awid),       
    .awaddr_1         (s00_axi_awaddr),     
    .awlen_1          (s00_axi_awlen),      
    .awsize_1         (s00_axi_awsize),     
    .awburst_1        (s00_axi_awburst),    
    .awlock_1         (s00_axi_awlock),                       
    .awvalid_1        (s00_axi_awvalid),    
    .awready_1        (s00_axi_awready),    
  //  .awurgent_1       (axi_awurgent),  //? 
  //  .awpoison_1       (axi_awpoison),   //?     
    .awurgent_1       (1'b0),  //? 
    .awpoison_1       (1'b0),   //?                 
    .wdata_1          (s00_axi_wdata),      
    .wstrb_1          (s00_axi_wstrb),      
    .wlast_1          (s00_axi_wlast),      
    .wvalid_1         (s00_axi_wvalid),     
    .wready_1         (s00_axi_wready),                       
    .bid_1            (s00_axi_bid),        
    .bresp_1          (s00_axi_bresp),      
    .bvalid_1         (s00_axi_bvalid),     
    .bready_1         (s00_axi_bready),                                    
    .arid_1           (s00_axi_arid     ),  
    .araddr_1         (s00_axi_araddr   ),  
    .arlen_1          (s00_axi_arlen    ),  
    .arsize_1         (s00_axi_arsize   ),  
    .arburst_1        (s00_axi_arburst  ),  
    .arlock_1         (s00_axi_arlock   ),                      
    .arvalid_1        (s00_axi_arvalid  ),  
    .arready_1        (s00_axi_arready  ),  
   // .arpoison_1       (s00_axi_arqos ),   //?   
    .arpoison_1       (1'b0 ),   //?                  
    .rid_1            (s00_axi_rid      ),  
    .rdata_1          (s00_axi_rdata    ),  
    .rresp_1          (s00_axi_rresp    ),  
    .rlast_1          (s00_axi_rlast    ),  
    .rvalid_1         (s00_axi_rvalid   ),  
    .rready_1         (s00_axi_rready   ),  
   // .arurgent_1       (axi_arurgent ),    //?    
    .arurgent_1       (1'b0),    //?        
    .csysreq_1        (1'b1),               
    .csysack_1        (),           
    .cactive_1        (), 

//axi 2

    .areset_2         (0),               
    .aclk_2           (ui_clk),                                                        
    .awid_2           (s01_axi_awid),       
    .awaddr_2         (s01_axi_awaddr),     
    .awlen_2          (s01_axi_awlen),      
    .awsize_2         (s01_axi_awsize),     
    .awburst_2        (s01_axi_awburst),    
    .awlock_2         (s01_axi_awlock),                       
    .awvalid_2        (s01_axi_awvalid),    
    .awready_2        (s01_axi_awready),    
  //  .awurgent_2       (axi_awurgent),  //? 
  //  .awpoison_2       (axi_awpoison),   //?     
    .awurgent_2       (1'b0),  //? 
    .awpoison_2       (1'b0),   //?                 
    .wdata_2          (s01_axi_wdata),      
    .wstrb_2          (s01_axi_wstrb),      
    .wlast_2          (s01_axi_wlast),      
    .wvalid_2         (s01_axi_wvalid),     
    .wready_2         (s01_axi_wready),                       
    .bid_2            (s01_axi_bid),        
    .bresp_2          (s01_axi_bresp),      
    .bvalid_2         (s01_axi_bvalid),     
    .bready_2         (s01_axi_bready),                                    
    .arid_2           (s01_axi_arid     ),  
    .araddr_2         (s01_axi_araddr   ),  
    .arlen_2          (s01_axi_arlen    ),  
    .arsize_2         (s01_axi_arsize   ),  
    .arburst_2        (s01_axi_arburst  ),  
    .arlock_2         (s01_axi_arlock   ),                      
    .arvalid_2        (s01_axi_arvalid  ),  
    .arready_2        (s01_axi_arready  ),  
   // .arpoison_2       (s01_axi_arqos ),   //?   
    .arpoison_2       (1'b0 ),   //?                  
    .rid_2            (s01_axi_rid      ),  
    .rdata_2          (s01_axi_rdata    ),  
    .rresp_2          (s01_axi_rresp    ),  
    .rlast_2          (s01_axi_rlast    ),  
    .rvalid_2         (s01_axi_rvalid   ),  
    .rready_2         (s01_axi_rready   ),  
   // .arurgent_2       (axi_arurgent ),    //?    
    .arurgent_2       (1'b0),    //?        
    .csysreq_2        (1'b1),               
    .csysack_2        (),           
    .cactive_2        (), 


       
    .csysreq_ddrc     (1'b1),
    .csysack_ddrc     (),
    .cactive_ddrc     (),
             
    .pad_loop_in           (pad_loop_in),
    .pad_loop_in_h         (pad_loop_in_h),
    .pad_rstn_ch0          (pad_rstn_ch0),
    .pad_ddr_clk_w         (pad_ddr_clk_w),
    .pad_ddr_clkn_w        (pad_ddr_clkn_w),
    .pad_csn_ch0           (pad_csn_ch0),
    .pad_addr_ch0          (pad_addr_ch0),
    .pad_dq_ch0            (pad_dq_ch0),
    .pad_dqs_ch0           (pad_dqs_ch0),
    .pad_dqsn_ch0          (pad_dqsn_ch0),
    .pad_dm_rdqs_ch0       (pad_dm_rdqs_ch0),
    .pad_cke_ch0           (pad_cke_ch0),
    .pad_odt_ch0           (pad_odt_ch0),
    .pad_rasn_ch0          (pad_rasn_ch0),
    .pad_casn_ch0          (pad_casn_ch0),
    .pad_wen_ch0           (pad_wen_ch0),
    .pad_ba_ch0            (pad_ba_ch0),
    .pad_loop_out          (pad_loop_out),
    .pad_loop_out_h        (pad_loop_out_h)                                
);   
aq_axi_master u_aq_axi_master
	(
      .ARESETN                     (rst_n                                     ),
	 // .ARESETN                     (~ui_clk_sync_rst                          ),
	  .ACLK                        (ui_clk                                    ),
	  .M_AXI_AWID                  (s00_axi_awid                              ),
	  .M_AXI_AWADDR                (s00_axi_awaddr                            ),
	  .M_AXI_AWLEN                 (s00_axi_awlen                             ),
	  .M_AXI_AWSIZE                (s00_axi_awsize                            ),
	  .M_AXI_AWBURST               (s00_axi_awburst                           ),
	  .M_AXI_AWLOCK                (s00_axi_awlock                            ),
	  .M_AXI_AWCACHE               (s00_axi_awcache                           ),
	  .M_AXI_AWPROT                (s00_axi_awprot                            ),
	  .M_AXI_AWQOS                 (s00_axi_awqos                             ),
	  .M_AXI_AWUSER                (s00_axi_awuser                            ),
	  .M_AXI_AWVALID               (s00_axi_awvalid                           ),
	  .M_AXI_AWREADY               (s00_axi_awready                           ),
	  .M_AXI_WDATA                 (s00_axi_wdata                             ),
	  .M_AXI_WSTRB                 (s00_axi_wstrb                             ),
	  .M_AXI_WLAST                 (s00_axi_wlast                             ),
	  .M_AXI_WUSER                 (s00_axi_wuser                             ),
	  .M_AXI_WVALID                (s00_axi_wvalid                            ),
	  .M_AXI_WREADY                (s00_axi_wready                            ),
	  .M_AXI_BID                   (s00_axi_bid                               ),
	  .M_AXI_BRESP                 (s00_axi_bresp                             ),
	  .M_AXI_BUSER                 (s00_axi_buser                             ),
	  .M_AXI_BVALID                (s00_axi_bvalid                            ),
	  .M_AXI_BREADY                (s00_axi_bready                            ),
	  
	  .M_AXI_ARID                  (s00_axi_arid                              ),
	  .M_AXI_ARADDR                (s00_axi_araddr                            ),
	  .M_AXI_ARLEN                 (s00_axi_arlen                             ),
	  .M_AXI_ARSIZE                (s00_axi_arsize                            ),
	  .M_AXI_ARBURST               (s00_axi_arburst                           ),
	  .M_AXI_ARLOCK                (s00_axi_arlock                            ),
	  .M_AXI_ARCACHE               (s00_axi_arcache                           ),
	  .M_AXI_ARPROT                (s00_axi_arprot                            ),
	  .M_AXI_ARQOS                 (s00_axi_arqos                             ),
	  .M_AXI_ARUSER                (s00_axi_aruser                            ),
	  .M_AXI_ARVALID               (s00_axi_arvalid                           ),
	  .M_AXI_ARREADY               (s00_axi_arready                           ),
	 
	  .M_AXI_RID                   (s00_axi_rid                               ),
	  .M_AXI_RDATA                 (s00_axi_rdata                             ),
	  .M_AXI_RRESP                 (s00_axi_rresp                             ),
	  .M_AXI_RLAST                 (s00_axi_rlast                             ),
	  .M_AXI_RUSER                 (s00_axi_ruser                             ),
	  .M_AXI_RVALID                (s00_axi_rvalid                            ),
	  .M_AXI_RREADY                (s00_axi_rready                            ),
	 
	 .MASTER_RST                  (1'b0                                     ),
	  .WR_START                    (wr_burst_req                             ),
	  .WR_ADRS                     ({wr_burst_addr,3'd0}                     ),
	  .WR_LEN                      ({wr_burst_len,3'd0}                      ),
	  .WR_READY                    (                                         ),
	  .WR_FIFO_RE                  (wr_burst_data_req                        ),
	  .WR_FIFO_EMPTY               (1'b0                                     ),
	  .WR_FIFO_AEMPTY              (1'b0                                     ),
	  .WR_FIFO_DATA                (wr_burst_data                            ),
	  .WR_DONE                     (wr_burst_finish                          ),
	  .RD_START                    (rd_burst_req                             ),
	  .RD_ADRS                     ({rd_burst_addr,3'd0}                     ),
	  .RD_LEN                      ({rd_burst_len,3'd0}                      ),
	  .RD_READY                    (                                         ),
	  .RD_FIFO_WE                  (rd_burst_data_valid                      ),
	  .RD_FIFO_FULL                (1'b0                                     ),
	  .RD_FIFO_AFULL               (1'b0                                     ),
	  .RD_FIFO_DATA                (rd_burst_data                            ),
	  .RD_DONE                     (rd_burst_finish                          ),
	  .DEBUG                       (                                         )
);

aq_axi_master u_aq_axi_master_m2
	(
      .ARESETN                     (rst_n                                     ),
	 // .ARESETN                     (~ui_clk_sync_rst                          ),
	  .ACLK                        (ui_clk                                    ),
	  .M_AXI_AWID                  (s01_axi_awid                              ),
	  .M_AXI_AWADDR                (s01_axi_awaddr                            ),
	  .M_AXI_AWLEN                 (s01_axi_awlen                             ),
	  .M_AXI_AWSIZE                (s01_axi_awsize                            ),
	  .M_AXI_AWBURST               (s01_axi_awburst                           ),
	  .M_AXI_AWLOCK                (s01_axi_awlock                            ),
	  .M_AXI_AWCACHE               (s01_axi_awcache                           ),
	  .M_AXI_AWPROT                (s01_axi_awprot                            ),
	  .M_AXI_AWQOS                 (s01_axi_awqos                             ),
	  .M_AXI_AWUSER                (s01_axi_awuser                            ),
	  .M_AXI_AWVALID               (s01_axi_awvalid                           ),
	  .M_AXI_AWREADY               (s01_axi_awready                           ),
	  .M_AXI_WDATA                 (s01_axi_wdata                             ),
	  .M_AXI_WSTRB                 (s01_axi_wstrb                             ),
	  .M_AXI_WLAST                 (s01_axi_wlast                             ),
	  .M_AXI_WUSER                 (s01_axi_wuser                             ),
	  .M_AXI_WVALID                (s01_axi_wvalid                            ),
	  .M_AXI_WREADY                (s01_axi_wready                            ),
	  .M_AXI_BID                   (s01_axi_bid                               ),
	  .M_AXI_BRESP                 (s01_axi_bresp                             ),
	  .M_AXI_BUSER                 (s01_axi_buser                             ),
	  .M_AXI_BVALID                (s01_axi_bvalid                            ),
	  .M_AXI_BREADY                (s01_axi_bready                            ),
	  
	  .M_AXI_ARID                  (s01_axi_arid                              ),
	  .M_AXI_ARADDR                (s01_axi_araddr                            ),
	  .M_AXI_ARLEN                 (s01_axi_arlen                             ),
	  .M_AXI_ARSIZE                (s01_axi_arsize                            ),
	  .M_AXI_ARBURST               (s01_axi_arburst                           ),
	  .M_AXI_ARLOCK                (s01_axi_arlock                            ),
	  .M_AXI_ARCACHE               (s01_axi_arcache                           ),
	  .M_AXI_ARPROT                (s01_axi_arprot                            ),
	  .M_AXI_ARQOS                 (s01_axi_arqos                             ),
	  .M_AXI_ARUSER                (s01_axi_aruser                            ),
	  .M_AXI_ARVALID               (s01_axi_arvalid                           ),
	  .M_AXI_ARREADY               (s01_axi_arready                           ),
	 
	  .M_AXI_RID                   (s01_axi_rid                               ),
	  .M_AXI_RDATA                 (s01_axi_rdata                             ),
	  .M_AXI_RRESP                 (s01_axi_rresp                             ),
	  .M_AXI_RLAST                 (s01_axi_rlast                             ),
	  .M_AXI_RUSER                 (s01_axi_ruser                             ),
	  .M_AXI_RVALID                (s01_axi_rvalid                            ),
	  .M_AXI_RREADY                (s01_axi_rready                            ),
	 
	 .MASTER_RST                   (1'b0                                     ),
	  .WR_START                    (wr_burst_req_2                             ),
	  .WR_ADRS                     ({wr_burst_addr_2,3'd0}                     ),
	  .WR_LEN                      ({wr_burst_len_2,3'd0}                      ),
	  .WR_READY                    (                                         ),
	  .WR_FIFO_RE                  (wr_burst_data_req_2                        ),
	  .WR_FIFO_EMPTY               (1'b0                                     ),
	  .WR_FIFO_AEMPTY              (1'b0                                     ),
	  .WR_FIFO_DATA                (wr_burst_data_2                            ),
	  .WR_DONE                     (wr_burst_finish_2                          ),
	  .RD_START                    (rd_burst_req_2                             ),
	  .RD_ADRS                     ({rd_burst_addr_2,3'd0}                     ),
	  .RD_LEN                      ({rd_burst_len_2,3'd0}                      ),
	  .RD_READY                    (                                         ),
	  .RD_FIFO_WE                  (rd_burst_data_valid_2                      ),
	  .RD_FIFO_FULL                (1'b0                                     ),
	  .RD_FIFO_AFULL               (1'b0                                     ),
	  .RD_FIFO_DATA                (rd_burst_data_2                            ),
	  .RD_DONE                     (rd_burst_finish_2                          ),
	  .DEBUG                       (                                         )
);


//The video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n                   ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),
	.hs                         (timing_hs                       ),
	.vs                         (timing_vs                       ),
	.de                         (timing_de                       ),
	.vout_data                  (timing_data                )
);

timing_gen_xy timing_gen_xy_inst
(
	.rst_n						(	rst_n			) ,	// input  rst_n_sig
	.clk						(	video_clk		) ,	// input  clk_sig
	.i_hs						(	timing_hs 		) ,	// input  i_hs_sig
	.i_vs						(	timing_vs 		) ,	// input  i_vs_sig
	.i_de						(	timing_de 		) ,	// input  i_de_sig
	.i_data						(	timing_data		) ,	// input [15:0] i_data_sig
	.o_hs						(	xy_hs		) ,	// output  o_hs_sig
	.o_vs						(	xy_vs		) ,	// output  o_vs_sig
	.o_de						(	xy_de		) ,	// output  o_de_sig
	.o_data						(	xy_data		) ,	// output [23:0] o_data_sig
	.x							(	gen_x		) ,	// output [11:0] x_sig
	.y							(	gen_y		) 	// output [11:0] y_sig
);



RGB_Gary_Binary RGB_Gary_Binary_inst
(
	.rst_n			(	rst_n				) ,	// input  rst_n_sig
	.clk			(	video_clk			) ,	// input  clk_sig
	.disp_model     (   uart_code_out       ),
	.display_model	(	display_model		),
    .threshold_set	(	threshold			),
	.i_hs			(	xy_hs				) ,	// input  i_hs_sig
	.i_vs			(	xy_vs				) ,	// input  i_vs_sig
	.i_de			(	xy_de				) ,	// input  i_de_sig

//	.key			(	key_out				) ,	// input [2:0] key_sig
	.key			(	0				) ,	// input [2:0] key_sig	

    .i_x			(	gen_x				) ,	// input [11:0] i_x_sig
	.i_y			(	gen_y				) ,	// input [11:0] i_y_sig
	.i_data			(	xy_data				) ,	// input [23:0] i_data_sig
	.th_flag		(						) ,	// output  th_flag_sig
	.o_data			(	GB_data				) ,	// output [23:0] o_data_sig
	.o_x			(	GB_x				) ,	// output [11:0] o_x_sig
	.o_y			(	GB_y				) ,	// output [11:0] o_y_sig
	.o_hs			(	GB_hs				) ,	// output  o_hs_sig
	.o_vs			(	GB_vs				) ,	// output  o_vs_sig
	.o_de			(	GB_de				) 	// output  o_de_sig
);


Char_Pic_Disply Char_Pic_Disply_inst
(
	.rst_n					(	rst_n		) ,	// input  rst_n_sig
	.clk						(	video_clk	) ,	// input  clk_sig
	.x							(	GB_x		) ,	// input [11:0] x_sig
	.y							(	GB_y		) ,	// input [11:0] y_sig
	.i_hs						(	GB_hs		) ,	// input  i_hs_sig
	.i_vs						(	GB_vs		) ,	// input  i_vs_sig
	.i_de						(	GB_de		) ,	// input  i_de_sig
	.i_data					(	GB_data		) ,	// input [23:0] i_data_sig
	.display_number            ( display_number    ),
    .display_model          (  display_model            ),
    .o_hs						(	char_hs		) ,	// output  o_hs_sig
	.o_vs						(	char_vs		) ,	// output  o_vs_sig
	.o_de						(	char_de		) ,	// output  o_de_sig
	.o_data					(	char_data	) 	// output [23:0] o_data_sig
);

defparam Char_Pic_Disply_inst.LSB = 2;


endmodule