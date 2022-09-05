/*
 * Processing Element with Weight Stationary Dataflow
 *
 * Description
 *   Weight stationary processing element for systolic array
 *   For simplicity, this processor only utilizes integer values 
 *   (weight and input feature values)
 */

module ProcessingElementWS #(
    parameter WORDWIDTH = 8  // dtype: int8
) (
    input clk,      // global clock signal (positive edge triggered)
    input reset_n,  // global reset signal (asynchronous negative edge triggered)
    input mode,     // current mode (weight load mode or partial sum computation mode)

    input                    enable_in,
    input  [WORDWIDTH-1:0]   w_in,
    input  [WORDWIDTH-1:0]   a_in,
    input  [WORDWIDTH*4-1:0] ps_in,

    output                   enable_out,
    output [WORDWIDTH-1:0]   w_out,
    output [WORDWIDTH-1:0]   a_out,
    output [WORDWIDTH*4-1:0] ps_out
);

`include "./params.v"

reg enable_out_reg;
reg [WORDWIDTH*2-1:0] weight;
reg [WORDWIDTH-1:0]   activation;
reg [WORDWIDTH*4-1:0] partial_sum;

assign enable_out = enable_out_reg;
assign w_out = weight[WORDWIDTH*2-1:WORDWIDTH];
assign a_out = activation;
assign ps_out = partial_sum;

always @(posedge clk or negedge reset_n) begin : PSUM_CALC
    if (reset_n == 1'b0) begin
        weight <= 0;
        activation <= 0;
        partial_sum <= 0;
    end 
    
    else begin
        if (mode == MODE_WL) begin
            weight[WORDWIDTH*2-1:0] <= {weight[WORDWIDTH-1:0], w_in};
        end

        else if (mode == MODE_PS && enable_in == 1'b1) begin
            activation <= a_in;
            partial_sum <= ps_in + (weight[WORDWIDTH-1:0] * a_in);
            enable_out_reg <= 1'b1;
        end
    end
end
    
endmodule