`include "accumulator.v"

`timescale 1ns/1ps

module accumulator_tb;

parameter  CLOCK_PS = 10000;
localparam HCLOCK_PS = CLOCK_PS / 2;

localparam WORD_WIDTH = 8;
localparam FIFO_CAP = 16;
localparam PTR_WIDTH = 4;

integer clk_count;

reg clk;
reg reset_n;

// Instantiation of processing element
reg w_enable, r_enable, a_enable;
reg [WORD_WIDTH-1:0] d_in;
wire full, empty;
wire [WORD_WIDTH-1:0] d_out;

AccumulatorUnit #(
    .WORD_WIDTH(WORD_WIDTH), .FIFO_CAP(FIFO_CAP), .PTR_WIDTH(PTR_WIDTH)
) acc_unit (
    .clk(clk), .reset_n(reset_n),
    .w_enable(w_enable), .r_enable(r_enable), .a_enable(a_enable),
    .d_in(d_in),
    .full(full), .empty(empty),
    .d_out(d_out)
);

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
    $dumpfile("accumulator_tb.vcd");
    $dumpvars(-1, clk);
    $dumpvars(-1, reset_n);
    $dumpvars(-1, w_enable);
    $dumpvars(-1, r_enable);
    $dumpvars(-1, a_enable);
    $dumpvars(-1, d_in);
    $dumpvars(-1, full);
    $dumpvars(-1, empty);
    $dumpvars(-1, d_out);
    // $monitor("clk: %2d   control: %b  a_in: %3d  d_in: %3d  a_out: %3d  d_out: %3d", 
    //           clk_count, control,     a_in,      d_in,       a_out,        d_out);

    reset_n = 1;
    # HCLOCK_PS

    reset_n = 0;
    # HCLOCK_PS

    reset_n = 1;

    w_enable = 0;
    r_enable = 0;
    a_enable = 1;

    d_in = 4;
    # CLOCK_PS
    d_in = 3;
    # CLOCK_PS
    d_in = 5;
    # CLOCK_PS

    w_enable = 1;
    r_enable = 0;
    a_enable = 0;

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    w_enable = 0;
    r_enable = 1;
    a_enable = 0;

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule