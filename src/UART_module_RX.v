module UART_module_RX
# (
    parameter INPUT_CLK = 50000000,
              BAUD_RATE = 230400
)
(
   input          clk,
	input          kill,
	
	input          rx_uart,
	
	output [7 : 0] recieve_byte
);
localparam START_BIT_DURATION = INPUT_CLK/BAUD_RATE/2;
localparam BIT_DURATION       = INPUT_CLK/BAUD_RATE;	
localparam INTERVAL_CNTR_WIDTH = $clog2(BIT_DURATION);

reg         ff_stage_1;
reg         ff_stage_2;	

reg         rx_uart_delay;
wire        rx_uart_negedge;

reg [INTERVAL_CNTR_WIDTH : 0] start_cntr;
reg                           start_cntr_en;
wire                          start_cntr_done;

reg [INTERVAL_CNTR_WIDTH : 0] interval_cntr;
reg                           interval_cntr_en;
wire                          interval_cntr_done;

reg [4 : 0] bit_cntr;
wire        bit_cntr_done;

reg [8 : 0] shift_reg;
reg [7 : 0] rx_byte;
wire        recieve_byte_valid;

// syncronization rx_uart in clk domain. Metastability protection
always @( posedge clk ) begin
  if ( kill ) begin
    ff_stage_1 <= 1'b1;
	ff_stage_2 <= 1'b1;
  end else begin
    ff_stage_1 <= rx_uart;
	ff_stage_2 <= ff_stage_1;
  end
end

// debouncing


// detect falling egde
always @( posedge clk ) 
  if ( kill ) 
    rx_uart_delay <= 1'b1;
  else 
	rx_uart_delay <= ff_stage_2;
	
assign rx_uart_negedge = ( ~ff_stage_2 ) && rx_uart_delay;

// Count half of start bit
always @( posedge clk )
  if ( kill || start_cntr_done )
    start_cntr_en <= 1'b0;
  else if ( rx_uart_negedge )
    start_cntr_en <= 1'b1;
	
always @( posedge clk )
  if ( kill || start_cntr_done )
    start_cntr <= { INTERVAL_CNTR_WIDTH { 1'b0 } };
  else if ( start_cntr_en )
    start_cntr <= start_cntr + 1'b1;	  

assign start_cntr_done = ( start_cntr == START_BIT_DURATION);

// check start bit is remain zero
always @ ( posedge clk )
  if ( kill || bit_cntr_done )
    interval_cntr_en <= 1'b0;
  else if (start_cntr_done && ( ~ff_stage_2 ) )
    interval_cntr_en <= 1'b1;	

// count between latch bit
always @( posedge clk )
  if ( kill || interval_cntr_done )
    interval_cntr <= { INTERVAL_CNTR_WIDTH { 1'b0 } };
  else if ( interval_cntr_en )
    interval_cntr <= interval_cntr + 1'b1;
	
assign interval_cntr_done = ( interval_cntr == BIT_DURATION);

// write rx bit to shift register, increment bit cntr	
always @( posedge clk ) begin
  if ( kill || bit_cntr_done ) begin
    shift_reg <= 9'b0;
	bit_cntr  <= 4'b0;
  end else if ( interval_cntr_done ) begin 
    shift_reg <= {ff_stage_2, shift_reg[8 : 1]};
	bit_cntr  <= bit_cntr + 1'b1;
  end
end

assign bit_cntr_done = ( bit_cntr == 9'd9 );
assign recieve_byte_valid = bit_cntr_done && ( shift_reg[8] == 1'b1 );

always @( posedge clk )
  if ( kill ) 
    rx_byte <= 8'b0;
  else if ( recieve_byte_valid )
	rx_byte <= shift_reg[7:0];
	
assign recieve_byte = rx_byte;

endmodule