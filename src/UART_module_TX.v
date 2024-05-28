module UART_module_TX
# (
    parameter INPUT_CLK = 50000000,
              BAUD_RATE = 230400
)
(
   input          clk,
	input          kill,
	
	input  [7 : 0]  send_byte,
	input           send_en,
	
	output          tx_uart,
	output [9 : 0]  send_byte_wire
);

localparam BIT_DURATION       = INPUT_CLK/BAUD_RATE;
localparam INTERVAL_CNTR_WIDTH = $clog2(BIT_DURATION);	

reg          enb_delay;
wire         enb_posedge;

wire         bit_cntr_done;
wire         interval_cntr_done;

reg          start;
reg  [9 : 0] send_byte_reg = 10'b1;

assign send_byte_wire = send_byte_reg;

reg  [ INTERVAL_CNTR_WIDTH : 0] interval_cntr;
reg  [ 3                   : 0] bit_cntr;
wire [ 3                   : 0] bit_cntr_wire;

always @( posedge clk )
  if ( kill )
    enb_delay <= 1'b0;
  else 
    enb_delay <= send_en;
	 
assign enb_posedge = send_en && ~enb_delay;

always @( posedge clk ) 
  if ( kill || bit_cntr_done ) 
    start <= 1'b0;
  else if ( enb_posedge )
	 start <= 1'b1;


always @( posedge clk ) 
  if ( kill || bit_cntr_done ) 
	 send_byte_reg <= 10'b1;
  else if ( enb_posedge ) 
	 send_byte_reg <= { 1'b1, send_byte, 1'b0 };
	    else if ( start && interval_cntr_done )
		   send_byte_reg <= {1'b1, send_byte_reg [9 : 1]};
  


always @( posedge clk )
  if ( kill || interval_cntr_done )
    interval_cntr <= { INTERVAL_CNTR_WIDTH { 1'b0 } };
  else if ( start )
    interval_cntr <= interval_cntr + 1'b1;
	 
assign interval_cntr_done = ( interval_cntr == BIT_DURATION );


always @( posedge clk ) 
  if ( kill || bit_cntr_done ) 
    bit_cntr  <= 4'b0;
  else if ( interval_cntr_done ) 
    bit_cntr  <= bit_cntr + 1'b1;

assign bit_cntr_done = ( bit_cntr == 9'd10 );

assign tx_uart = send_byte_reg[0];

endmodule