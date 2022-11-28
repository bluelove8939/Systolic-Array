`include "fifo.v"
`include "adder.v"


module AccumulatorUnit #(
    parameter WORD_WIDTH = 32,   // data bitwidth
    parameter FIFO_CAP   = 2,  // FIFO capacity
    parameter PTR_WIDTH  = 1    // pointer bitwidth
) (
    input clk,
    input reset_n,

    input w_enable,  // FIFO write enable
    input r_enable,  // FIFO read enable
    input a_enable,  // accumulate enable

    input [WORD_WIDTH-1:0] d_in,  // data input
    
    output full,   // FIFO full flag
    output empty,  // FIFO empty flag

    output [WORD_WIDTH-1:0] d_out  // data output
);

// Accumulation operation
reg [WORD_WIDTH-1:0] psum;
wire overflow;  // overflow flag (unused)
wire [WORD_WIDTH-1:0] psum_out;

Adder #(.WORD_WIDTH(WORD_WIDTH)) adder_unit (
    .a(psum), .b(d_in), .cout(overflow), .y(psum_out)
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        psum <= 0;
    end else begin
        psum <= a_enable ? psum_out : d_in;
    end
end


// FIFO instanciation
FIFO #(
    .WORD_WIDTH(WORD_WIDTH), .FIFO_CAP(FIFO_CAP), .PTR_WIDTH(PTR_WIDTH)
) fifo_unit (
    .clk(clk), .reset_n(reset_n),
    .w_enable(w_enable), .r_enable(r_enable),
    .d_in(psum),
    .full(full), .empty(empty),
    .d_out(d_out)
);
    
endmodule