`include "processing_element.v"

/*
 * Systolic Array with Weight Stationary Dataflow
 *
 * Description
 *   For simplicity, this processor only utilizes integer values 
 *   (weight and input feature values)
 */

module SystolicArrayWS #(
    parameter ARRWIDTH  = 8,
    parameter ARRHEIGHT = 8,
    parameter WORDWIDTH = 8
) (
    input clk,      // global clock signal (positive edge triggered)
    input reset_n,  // global reset signal (asynchronous negative edge triggered)
    input mode,     // systolic mode signal

    input [WORDWIDTH * ARRWIDTH - 1:0] w_in_vec,    // systolic array weight input port
    input [WORDWIDTH * ARRHEIGHT - 1:0] a_in_vec,   // systolic array activation input port

    output [WORDWIDTH*4*ARRWIDTH - 1:0] ps_out_vec  // systolic array partial sum output port
);

`include "params.v"


// Split vector input and output port as an array
wire [WORDWIDTH-1:0] w_in [0:ARRWIDTH-1];
wire [WORDWIDTH-1:0] a_in [0:ARRHEIGHT-1];
wire [WORDWIDTH*4-1:0] ps_out [0:ARRWIDTH-1];

genvar w_in_idx;
genvar a_in_idx;
genvar ps_out_idx;

generate
    for (w_in_idx = 0; w_in_idx < ARRWIDTH; w_in_idx = w_in_idx+1) begin
        assign w_in[w_in_idx] = w_in_vec[(w_in_idx+1)*WORDWIDTH - 1 : w_in_idx * WORDWIDTH];
    end

    for (a_in_idx = 0; a_in_idx < ARRHEIGHT; a_in_idx = a_in_idx+1) begin
        assign a_in[a_in_idx] = a_in_vec[(a_in_idx+1)*WORDWIDTH - 1 : a_in_idx * WORDWIDTH];
    end

    for (ps_out_idx = 0; ps_out_idx < ARRWIDTH; ps_out_idx = ps_out_idx+1) begin
        assign ps_out_vec[(ps_out_idx+1)*WORDWIDTH*4 - 1 : ps_out_idx*WORDWIDTH*4] = ps_out[ps_out_idx];
    end
endgenerate


// Generate activation FIFO
wire                 act_fifo_enable;                   // activation FIFO enable
wire [WORDWIDTH-1:0] act_fifo_in      [0:ARRHEIGHT-1];  // activation FIFO input registers
wire [WORDWIDTH-1:0] act_fifo_out     [0:ARRHEIGHT-1];  // activation FIFO output registers

genvar act_fifo_idx;

generate
    for (act_fifo_idx = 0; act_fifo_idx < ARRHEIGHT; act_fifo_idx = act_fifo_idx+1) begin
        ShiftRegister #(
            .SIZ(act_fifo_idx+1),
            .WORDWIDTH(WORDWIDTH)
        ) act_fifo (
            .clk(clk),
            .reset_n(reset_n),
            .enable(act_fifo_enable),
            .in(act_fifo_in[act_fifo_idx]),
            .out(act_fifo_out[act_fifo_idx])
        );

        assign act_fifo_in[act_fifo_idx] = a_in[act_fifo_idx];
    end
endgenerate


// Generate partial sum FIFO
wire                   ps_fifo_enable;                   // partial sum FIFO enable
wire [WORDWIDTH*4-1:0] ps_fifo_in      [0:ARRWIDTH-1];  // partial sum FIFO input registers
wire [WORDWIDTH*4-1:0] ps_fifo_out     [0:ARRWIDTH-1];  // partial sum FIFO output registers

genvar ps_fifo_idx;

generate
    for (ps_fifo_idx = 0; ps_fifo_idx < ARRWIDTH; ps_fifo_idx = ps_fifo_idx+1) begin
        ShiftRegister #(
            .SIZ(ARRWIDTH - ps_fifo_idx),
            .WORDWIDTH(WORDWIDTH * 4)
        ) ps_fifo (
            .clk(clk),
            .reset_n(reset_n),
            .enable(ps_fifo_enable),
            .in(ps_fifo_in[ps_fifo_idx]),
            .out(ps_fifo_out[ps_fifo_idx])
        );

        assign ps_out[ps_fifo_idx] = ps_fifo_out[ps_fifo_idx];
    end
endgenerate


// Generate processing elements
wire pe_mode;     // PE mode
wire arr_enable;  // PE array enable

wire                   pe_enable_in  [0:ARRHEIGHT*ARRWIDTH-1];  // PE enable input ports
wire [WORDWIDTH-1:0]   pe_weight_in  [0:ARRHEIGHT*ARRWIDTH-1];  // PE weight input ports
wire [WORDWIDTH-1:0]   pe_act_in     [0:ARRHEIGHT*ARRWIDTH-1];  // PE activation input ports
wire [WORDWIDTH*4-1:0] pe_ps_in      [0:ARRHEIGHT*ARRWIDTH-1];  // PE partial sum input ports

wire                   pe_enable_out [0:ARRHEIGHT*ARRWIDTH-1];  // PE enable output ports
wire [WORDWIDTH-1:0]   pe_act_out    [0:ARRHEIGHT*ARRWIDTH-1];  // PE activation output ports
wire [WORDWIDTH-1:0]   pe_weight_out [0:ARRHEIGHT*ARRWIDTH-1];  // PE weight output ports
wire [WORDWIDTH*4-1:0] pe_ps_out     [0:ARRHEIGHT*ARRWIDTH-1];  // PE partial sum output ports

reg  [WORDWIDTH*4-1:0] global_ps_in;  // PE partial sum input value for first row

genvar pe_idx;
genvar cidx;
genvar ridx;

generate
    for (pe_idx = 0; pe_idx < ARRWIDTH * ARRHEIGHT; pe_idx = pe_idx+1) begin
        ProcessingElementWS #(
            .WORDWIDTH(WORDWIDTH)
        ) pe_arr (
            .clk(clk),
            .reset_n(reset_n),
            .mode(pe_mode),

            .enable_in(pe_enable_in[pe_idx]),
            .w_in(pe_weight_in[pe_idx]),
            .a_in(pe_act_in[pe_idx]),
            .ps_in(pe_ps_in[pe_idx]),

            .enable_out(pe_enable_out[pe_idx]),
            .w_out(pe_weight_out[pe_idx]),
            .a_out(pe_act_out[pe_idx]),
            .ps_out(pe_ps_out[pe_idx])
        );
    end

    assign pe_act_in[0]    = act_fifo_out[0];  // input of first PE is from first FIFO
    assign pe_enable_in[0] = arr_enable;       // array enable input is same with first PE enable input

    for (ridx = 1; ridx < ARRHEIGHT; ridx = ridx+1) begin
        assign pe_act_in[ridx * ARRWIDTH]   = act_fifo_out[ridx];                   // connect input of leftmost PE with fifo output
        assign pe_enable_in[ridx * ARRWIDTH] = pe_enable_out[(ridx-1) * ARRWIDTH];  // connect enable_in of leftmost PE
    end

    for (cidx = 0; cidx < ARRWIDTH; cidx = cidx+1) begin
        assign ps_fifo_in[cidx] = pe_ps_out[ARRWIDTH * (ARRHEIGHT-1) + cidx];  // bottom PE output is partial sum FIFO input
        assign pe_ps_in[cidx] = global_ps_in;
        assign pe_weight_in[cidx] = w_in[cidx];
    end

    for (cidx = 1; cidx < ARRWIDTH; cidx = cidx+1) begin       // column iteration
        for (ridx = 0; ridx < ARRHEIGHT; ridx = ridx+1) begin  // row iteration
            assign pe_act_in[ridx * ARRWIDTH + cidx]    = pe_act_out[ridx * ARRWIDTH + cidx - 1];     // connect a_in
            assign pe_enable_in[ridx * ARRWIDTH + cidx] = pe_enable_out[ridx * ARRWIDTH + cidx - 1];  // connect enable_in
        end
    end

    for (cidx = 0; cidx < ARRWIDTH; cidx = cidx+1) begin       // column iteration
        for (ridx = 1; ridx < ARRHEIGHT; ridx = ridx+1) begin  // row iteration
            assign pe_weight_in[ridx * ARRWIDTH + cidx] = pe_weight_out[(ridx-1) * ARRWIDTH + cidx];  // connect w_in
            assign pe_ps_in[ridx * ARRWIDTH + cidx]     = pe_ps_out[(ridx-1) * ARRWIDTH + cidx];      // connect ps_in
        end
    end

endgenerate


// Main operation of systolic array
wire enable;
assign enable = mode;

assign act_fifo_enable = enable;
assign ps_fifo_enable = enable;
assign arr_enable = enable;

assign pe_mode = mode;

always @(posedge clk or negedge reset_n) begin : SA_MAIN
    if (reset_n == 1'b0) begin
        global_ps_in <= 0;
    end
end

endmodule


/*
 * Shift Register (FIFO)
 *
 * Parameters
 *   1) SIZ: length of register
 *   2) WORDWIDTH: bit-width of each word
 */

module ShiftRegister #(
    parameter SIZ = 8,
    parameter WORDWIDTH = 8
) (
    input                  clk,      // global clock signal (positive edge triggered)
    input                  reset_n,  // global reset signal (asynchronous negative edge triggered)
    input                  enable,   // enable signal (shifts only if enable signal is 1)
    input  [WORDWIDTH-1:0] in,       // input port
    output [WORDWIDTH-1:0] out       // output port
);

reg [WORDWIDTH*(SIZ+1)-1:0] container;

assign out = container[WORDWIDTH*(SIZ+1)-1:WORDWIDTH*SIZ];  // last register of the container is used as output signal generator

always @(posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0) begin
        container <= 0;
    end 
    
    else begin
        if (enable == 1'b1) begin
            container[WORDWIDTH*(SIZ+1)-1:0] <= {container[WORDWIDTH*SIZ-1:0], in};
        end
    end
end
    
endmodule