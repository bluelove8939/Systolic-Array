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
    input clk,      // clock signal
    input reset_n,  // reset signal
    input mode,     // current mode (weight load mode or partial sum computation mode)

    input  [WORDWIDTH:0]   w_in,
    input  [WORDWIDTH:0]   a_in,

    output [WORDWIDTH:0]   a_out,
    output [WORDWIDTH*4:0] ps_out
);

`include "./params.v"

reg [WORDWIDTH:0]   weight;
reg [WORDWIDTH:0]   activation;
reg [WORDWIDTH*4:0] partial_sum;

assign a_out = activation;
assign ps_out = partial_sum;

always @(posedge clk or negedge reset_n) begin : PSUM_CALC
    if (reset_n == 1'b0) begin
        weight <= 0;
        activation <= 0;
        partial_sum <= 0;
    end else begin
        if (mode == PEMODE_WL) begin
            weight <= w_in;
        end

        else if (mode == PEMODE_PS) begin
            activation <= a_in;
            partial_sum <= partial_sum + (weight * a_in);
        end
    end
end
    
endmodule