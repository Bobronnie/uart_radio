`include "config.vh"

module strobe_gen
# (
    parameter w = 24
)
(
    input  clk,
    input  reset,
    output strobe
);
 
    reg [w - 1:0] cnt;

    always @ (posedge clk or posedge reset)
        if (reset)
            cnt <= { w { 1'b0 } };
        else 
            cnt <= cnt + 1'b1;
	 
    assign strobe = (cnt == { w { 1'b0 } } );

endmodule
