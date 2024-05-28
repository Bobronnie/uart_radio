module cntr_enb_by_posedge
(
   input          clk,
	input          kill,
	
	input          enb,
	
	output reg [3 : 0] cnt
);

reg enb_delay;
wire enb_posedge;

always @( posedge clk )
  if ( kill )
    enb_delay <= 1'b0;
  else 
    enb_delay <= enb;
	 
assign enb_posedge = enb && ~enb_delay;	 
	 
always @( posedge clk )
  if ( kill )
    cnt <= 4'b0;
  else if ( enb_posedge )
    cnt <= cnt + 1'b1;  
	 
endmodule