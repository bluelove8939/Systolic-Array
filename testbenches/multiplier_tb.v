`include "multiplier.v"

`timescale 1ns/1ps

module multiplier_tb;

parameter  CLOCK_PS = 10000;
localparam HCLOCK_PS = CLOCK_PS / 2;
localparam WORD_WIDTH = 8;

reg clk;

// Instantiation of processing element
reg [WORD_WIDTH-1:0] a, b;
wire [WORD_WIDTH*2-1:0] y;

Multiplier #(.WORD_WIDTH(WORD_WIDTH)) mul_unit (.a(a), .b(b), .y(y));

// Clock signal generation
initial begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # HCLOCK_PS clk = ~clk;
end


// PE test
initial begin : PE_TEST
    $dumpfile("multiplier_tb.vcd");
    $dumpvars(-1, a);
    $dumpvars(-1, b);
    $dumpvars(-1, y);
    $monitor("a: %d  b: %d  y: %d", a, b, y);

    a = 1;
    b = 3;

    #CLOCK_PS

    a = 3;
    b = 2;

    #CLOCK_PS

    a = 23;
    b = 37;

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule