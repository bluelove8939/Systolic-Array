`include "systolic_array.v"

`timescale 1ns/1ps

module systolic_array_tb;

parameter  CLOCK_PS = 10000;
localparam HCLOCK_PS = CLOCK_PS / 2;

localparam ARR_WIDTH = 4;
localparam ARR_HEIGHT = 4;
localparam WORD_WIDTH = 8;

integer clk_count;

reg clk;
reg reset_n;

// Instantiation of processing element
reg [1:0] control;

wire [WORD_WIDTH*ARR_WIDTH-1:0] w_in_vec;
wire [WORD_WIDTH*ARR_HEIGHT-1:0] a_in_vec;

wire [WORD_WIDTH*4*ARR_WIDTH-1:0] ps_out_vec;

SystolicArrayWS #(
    .ARR_WIDTH(ARR_WIDTH), .ARR_HEIGHT(ARR_HEIGHT), .WORD_WIDTH(WORD_WIDTH)
) sa_unit (
    .clk(clk), .reset_n(reset_n),
    .control(control),
    .w_in_vec(w_in_vec), .a_in_vec(a_in_vec),
    .ps_out_vec(ps_out_vec)
);


// Wire split (vector to array)
reg [WORD_WIDTH-1:0] w_in [0:ARR_WIDTH-1];
reg [WORD_WIDTH-1:0] a_in [0:ARR_HEIGHT-1];
wire [WORD_WIDTH*4-1:0] ps_out [0:ARR_WIDTH-1];

genvar w_in_idx;
genvar a_in_idx;
genvar ps_out_idx;

generate
    for (w_in_idx = 0; w_in_idx < ARR_WIDTH; w_in_idx = w_in_idx+1) begin
        assign w_in_vec[WORD_WIDTH*(w_in_idx+1)-1:WORD_WIDTH*w_in_idx] = w_in[w_in_idx];
    end

    for (a_in_idx = 0; a_in_idx < ARR_HEIGHT; a_in_idx = a_in_idx+1) begin
        assign a_in_vec[WORD_WIDTH*(a_in_idx+1)-1:WORD_WIDTH*a_in_idx] = a_in[a_in_idx];
    end

    for (ps_out_idx = 0; ps_out_idx < ARR_WIDTH; ps_out_idx = ps_out_idx+1) begin
        assign ps_out[ps_out_idx] = ps_out_vec[(ps_out_idx+1)*WORD_WIDTH*4-1:ps_out_idx*WORD_WIDTH*4];
    end
endgenerate


// Clock signal generation
initial begin : CLOCK_GENERATOR
    clk = 1'b0;
    clk_count = 0;
    forever
        # HCLOCK_PS clk = ~clk;
end

always @(posedge clk) begin
    clk_count  = clk_count + 1;
end


// PE test
initial begin : PE_TEST
    $dumpfile("systolic_array_ws_tb.vcd");
    
    $dumpvars(-1, clk);
    $dumpvars(-1, reset_n);
    $dumpvars(-1, control);

    for (integer ridx = 0; ridx < ARR_HEIGHT; ridx = ridx+1) begin
        $dumpvars(-1, a_in[ridx]);
    end

    for (integer cidx = 0; cidx < ARR_WIDTH; cidx = cidx+1) begin
        $dumpvars(-1, w_in[cidx]);
        $dumpvars(-1, ps_out[cidx]);
    end

    $monitor("clk: %2d   control: %b ", clk_count, control);

    reset_n = 1;
    # HCLOCK_PS

    reset_n = 0;
    # HCLOCK_PS

    reset_n = 1;
    control = 2'b00;

    # CLOCK_PS

    control = 2'b01;

    w_in[0] = 1;
    w_in[1] = 2;
    w_in[2] = 3;
    w_in[3] = 4;
    # CLOCK_PS

    w_in[0] = 4;
    w_in[1] = 3;
    w_in[2] = 2;
    w_in[3] = 1;
    # CLOCK_PS

    w_in[0] = 1;
    w_in[1] = 3;
    w_in[2] = 2;
    w_in[3] = 4;
    # CLOCK_PS

    w_in[0] = 4;
    w_in[1] = 2;
    w_in[2] = 1;
    w_in[3] = 3;
    # CLOCK_PS

    control = 2'b10;

    a_in[0] = 1;
    a_in[1] = 2;
    a_in[2] = 3;
    a_in[3] = 4;
    # CLOCK_PS

    a_in[0] = 4;
    a_in[1] = 3;
    a_in[2] = 2;
    a_in[3] = 1;
    # CLOCK_PS

    a_in[0] = 1;
    a_in[1] = 3;
    a_in[2] = 2;
    a_in[3] = 4;
    # CLOCK_PS

    a_in[0] = 4;
    a_in[1] = 2;
    a_in[2] = 1;
    a_in[3] = 3;
    # CLOCK_PS

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule