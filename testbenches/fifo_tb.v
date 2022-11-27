`include "fifo.v"

`timescale 1ns/1ps

module fifo_tb;

parameter  CLOCK_PS = 10000;
localparam HCLOCK_PS = CLOCK_PS / 2;

localparam WORD_WIDTH = 8;
localparam FIFO_CAP   = 16;
localparam PTR_WIDTH  = 4;

reg clk;
reg reset_n;


// Instantiation of processing element
reg w_enable, r_enable;
reg [WORD_WIDTH-1:0] d_in;
wire full, empty;
wire [WORD_WIDTH-1:0] d_out;

FIFO #(
    .WORD_WIDTH(WORD_WIDTH), .FIFO_CAP(FIFO_CAP), .PTR_WIDTH(PTR_WIDTH)
) fifo_unit (
    .clk(clk), .reset_n(reset_n),
    .w_enable(w_enable), .r_enable(r_enable),
    .d_in(d_in),
    .full(full), .empty(empty),
    .d_out(d_out)
);


// Clock signal generation
initial begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # HCLOCK_PS clk = ~clk;
end


// PE test
initial begin : PE_TEST
    $dumpfile("fifo_tb.vcd");
    $dumpvars(-1, w_enable);
    $dumpvars(-1, r_enable);
    $dumpvars(-1, d_in);
    $dumpvars(-1, full);
    $dumpvars(-1, empty);
    $dumpvars(-1, d_out);

    // $monitor("a: %d  b: %d  y: %d  cout: %d", a, b, y, cout);

    reset_n = 1;
    # HCLOCK_PS

    reset_n = 0;
    # HCLOCK_PS

    reset_n = 1;

    r_enable = 0;
    w_enable = 1;
    d_in = 3;

    #CLOCK_PS

    d_in = 2;

    #CLOCK_PS

    d_in = 1;

    # CLOCK_PS

    w_enable = 0;
    r_enable = 1;

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule