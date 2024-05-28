`include "config.vh"

module seven_segment
# (
    parameter w              = 32,
              bits_per_digit = 4,
              n_digits       = w / bits_per_digit
)
(
    input                   clk,
    input                   reset,
    input  [w        - 1:0] num,
	 
    output [7:0]            abcdefg,
    output [n_digits - 1:0] anodes
);

    
	 wire strobe;

    strobe_gen # (.w (10))
        i_sevene_segmsent_strobe
            (clk, reset, strobe);
				
    function [7:0] dig_to_seg (input [3:0] dig);

        case (dig)
        'h0: dig_to_seg = 'b00000011;  // a b c d e f g
        'h1: dig_to_seg = 'b10011111;
        'h2: dig_to_seg = 'b00100101;  //   --a--
        'h3: dig_to_seg = 'b00001101;  //  |     |
        'h4: dig_to_seg = 'b10011001;  //  f     b
        'h5: dig_to_seg = 'b01001001;  //  |     |
        'h6: dig_to_seg = 'b01000001;  //   --g--
        'h7: dig_to_seg = 'b00011111;  //  |     |
        'h8: dig_to_seg = 'b00000001;  //  e     c
        'h9: dig_to_seg = 'b00011001;  //  |     |
        'ha: dig_to_seg = 'b00010001;  //   --d-- 
        'hb: dig_to_seg = 'b11000001;
        'hc: dig_to_seg = 'b01100011;
        'hd: dig_to_seg = 'b10000101;
        'he: dig_to_seg = 'b01100001;
        'hf: dig_to_seg = 'b01110001;
		  default: dig_to_seg = 'b11111101;
        endcase

    endfunction

    //------------------------------------------------------------------------

    reg [n_digits - 1:0] anodes_d, anodes_q;

    always @*
        anodes_d <= { anodes_q [0], anodes_q [n_digits - 1 : 1] };

    always @ (posedge clk or posedge reset)
        if (reset)
            anodes_q <= { { n_digits - 1 { 1'b1 } }, 1'b0 };
        else if (strobe)
            anodes_q <= anodes_d;
    
    assign anodes = anodes_q;
    
    //------------------------------------------------------------------------

    wire [bits_per_digit - 1:0] dig;

    selector # (.w (bits_per_digit), .n (n_digits)) i_sel_dig
        (.d (num), .sel (~ anodes_d), .y (dig));

		  
    reg [7:0] abcdefg_q;
	 
	 always @ (posedge clk)
        if (strobe)
            abcdefg_q <= dig_to_seg (dig);
				
	 assign abcdefg = abcdefg_q;
	 
	 
endmodule
