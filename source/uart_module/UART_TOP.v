//RS-232  Transmitter and receiver module

module uart_top
#(
	parameter	SYS_CLK_FRP		=	50_000_000,
	parameter	BAUDRATE		=	115200
)
(
//clock and resetn
	input						clk,
	input						rst_n,					

	input		wire	[7:0]	tx_data,
	input		wire			tx_en,
    output		wire			uart_tx,	
   
	output		wire	[7:0]	rx_data,
	output		wire			rx_done,
    input		wire			uart_rx
  
);

//Internal Signals
  
//Data I/O between AHB and FIFO
	wire [7:0]	uart_wdata;  
	wire [7:0] 	uart_rdata;
	wire [7:0] 	fifo_tx_data;
  
//Signals from TX/RX to FIFOs
	wire 			uart_wr;
	wire 			uart_rd;  
  
//FIFO Status
	wire			tx_full;
	wire			tx_empty; 
	wire			tx_done;  
  
//baud rate signal
	wire			b_tick;
  
	assign 	uart_wr 		= 	tx_en;
	assign 	uart_wdata		= 	tx_data;
	   

BAUDGEN 
#(
	.SYS_CLK_FRP	(	SYS_CLK_FRP	),
	.BAUDRATE		(	BAUDRATE	)
)
uBAUDGEN
(
    .clk		(	clk				),
    .resetn		(	rst_n			),
    .baudtick	(	b_tick			)
);
  
//Transmitter FIFO
FIFO  
   #(.DWIDTH(8), .AWIDTH(8))
uFIFO_TX 
(
    .clk		(	clk					),
    .resetn		(	rst_n					),
    .rd			(	tx_done				),
    .wr			(	uart_wr				),
    .w_data		(	uart_wdata[7:0]	),
    .empty		(	tx_empty				),
    .full		(	tx_full				),
    .r_data		(	fifo_tx_data[7:0]		)
);
  

  
//UART transmitter
UART_TX uUART_TX
(
	.clk		(	clk					),
	.resetn		(	rst_n					),
	.tx_start	(	!tx_empty			),
	.b_tick		(	b_tick				),
	.d_in		(	fifo_tx_data[7:0]		),
	.tx_done	(	tx_done				),
	.tx			(	uart_tx					)
);
 
//UART receiver
UART_RX uUART_RX
(
	.clk		(	clk					),
	.resetn		(	rst_n					),
	.b_tick		(	b_tick				),
	.rx			(	uart_rx					),
	.rx_done	(	rx_done				),
	.dout		(	rx_data[7:0]		)
);
 
  
endmodule
