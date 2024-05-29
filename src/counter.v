module counter
# (
    parameter w = 1
) 
(
    input                  clk,
    input                  kill,
    input                  en,
    output reg [w - 1 : 0] cnt
);

    always @ (posedge clk )
        if ( kill )
            cnt <= { w { 1'b0 } };
        else if (en)
            cnt <= cnt + 1'b1;

endmodule