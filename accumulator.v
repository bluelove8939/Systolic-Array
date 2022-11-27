module AccumulatorUnit #(
    parameter WORD_WIDTH = 8,  // data bitwidth
    parameter PSUM_WIDTH = 8,  // partial sum bitwidth
    parameter FIFO_CAPAC = 16  // FIFO capacity
) (
    input clk,
    input reset_n,

    input [1:0] control,

    input [WORD_WIDTH-1:0] d_in,
    
    output [WORD_WIDTH-1:0] d_out
);
    
endmodule