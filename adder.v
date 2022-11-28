module AdderWrapper #(
    parameter WORD_WIDTH = 32
) (
    input clk,
    input reset_n,

    input [WORD_WIDTH-1:0] a,
    input [WORD_WIDTH-1:0] b,

    output cout,
    output [WORD_WIDTH-1:0] y
);

reg cout_reg;
reg [WORD_WIDTH-1:0] y_reg;

assign cout = cout_reg;
assign y = y_reg;

wire cout_w;
wire [WORD_WIDTH-1:0] y_w;

Adder #(.WORD_WIDTH(WORD_WIDTH)) adder_unit (
    .a(a), .b(b), .cout(cout_w), .y(y_w)
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        cout_reg <= 0;
        y_reg <= 0;
    end else begin
        cout_reg <= cout_w;
        y_reg <= y_w;
    end
end
    
endmodule


module Adder #(
    parameter WORD_WIDTH = 32
) (
    input [WORD_WIDTH-1:0] a,
    input [WORD_WIDTH-1:0] b,

    output cout,
    output [WORD_WIDTH-1:0] y
);

wire [WORD_WIDTH:0] carry;

assign carry[0] = 1'b0;
assign cout = carry[WORD_WIDTH];

genvar witer;

generate
    for (witer = 0; witer < WORD_WIDTH; witer = witer+1) begin: FADDERS
        FullAdder fadd(.a(a[witer]), .b(b[witer]), .Cin(carry[witer]), .s(y[witer]), .Cout(carry[witer+1]));
    end
endgenerate
    
endmodule


module FullAdder (
    input a,
    input b,
    input Cin,

    output s,
    output Cout
);

assign s = a ^ b ^ Cin;
assign Cout = (a & b) | (a & Cin) | (b & Cin);

endmodule