module top
# (
    parameter debounce_depth             = 8,
              num_strobe_width           = 25
)
(
    input        clk,
    input        reset_n,
    
    input  [3:0] key_sw,
	 
	 input        rx_uart,
	 output       tx_uart,
	 
    output [3:0] led,

    output [7:0] abcdefgh,
    output [3:0] digit,

    output       buzzer,

    output       hsync,
    output       vsync,
    output [2:0] rgb

);

    assign buzzer = 1'b1;
    assign hsync  = 1'b1;
    assign vsync  = 1'b1;
    assign rgb    = 3'b0;
    assign led    = 4'b1111;
	 
	 //------------------------------------------------------------------------

    wire reset = ~ reset_n;
	 
	 wire cntr_enb;
	 wire send_tx_uart;
    
    //------------------------------------------------------------------------
	 
	 sync_and_debounce_one # (. depth ( 10 )) sync_counter_en 
	 (
	     .clk    ( clk        ),
		  .reset  ( reset      ),
		  .sw_in  ( ~key_sw[3] ),
		  .sw_out ( cntr_enb   )
	 );
	 
	 sync_and_debounce_one # (. depth ( 10 )) sync_send_en 
	 (
	     .clk    ( clk          ),
		  .reset  ( reset        ),
		  .sw_in  ( ~key_sw[2]   ),
		  .sw_out ( send_tx_uart )
	 );

    //------------------------------------------------------------------------
	 cntr_enb_by_posedge i_cntr_enb_by_posedge
	 (
	     .clk    ( clk         ),
		  .kill   ( reset       ),
		  .enb    ( cntr_enb    ),
		  .cnt    ( num_count3  )
	 );
	 
	 wire [3:0] rx_uart_byte;
	 wire [9:0] send_byte_dbg;
	 
	 UART_module_TX 
	 # ( .INPUT_CLK ( 50000000 ),
	     .BAUD_RATE ( 230400   )
		)
	 i_UART_module_TX
	 (
	     .clk       ( clk                  ),
		  .kill      ( reset                ),
		  
		  .send_byte ( { 4'b0, num_count3 } ),
		  .send_en   ( send_tx_uart         ),
		  
		  .tx_uart   ( tx_uart              ),
		  .send_byte_wire (send_byte_dbg)
    );		  
		  
	 
	 UART_module_RX 
	 # ( .INPUT_CLK ( 50000000 ),
	     .BAUD_RATE ( 230400   )
		)
	 i_UART_module_RX
	 (
	     .clk          ( clk          ),
		  .kill         ( reset        ),
		  
		  .rx_uart      ( rx_uart      ),
		  .recieve_byte ( rx_uart_byte )
    );		  
		  
	
    wire [3:0] num_count0;
    wire [3:0] num_count1;
    wire [3:0] num_count2;
    wire [3:0] num_count3;

    assign num_count0 = 4'b11;
    assign num_count1 = send_byte_dbg[3:0];
    assign num_count2 = send_byte_dbg[7:4];
    // assign num_count3 = 4'b00;
    //------------------------------------------------------------------------

    wire [15:0] number_to_display =
    {
        num_count3,
        num_count2,
        num_count1,
        rx_uart_byte
    };

    //------------------------------------------------------------------------

    seven_segment #(.w (16)) i_seven_segment
    (
        .clk     ( clk                  ),
        .reset   ( reset                ),
        .num     ( number_to_display    ),
        .abcdefg ( abcdefgh             ),
        .anodes  ( digit                )
    );

endmodule