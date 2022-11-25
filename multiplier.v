module Multiplier #(
    parameter WORD_WIDTH = 8
) (
    input [WORD_WIDTH-1:0] a,
    input [WORD_WIDTH-1:0] b,

    output [WORD_WIDTH*2-1:0] y
);

assign y = a * b;
    
endmodule