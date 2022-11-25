`include "adder.v"

`timescale 1ns/1ps

module tb_adder;

parameter  CLOCK_PS = 10000;
localparam HCLOCK_PS = CLOCK_PS / 2;
localparam WORD_WIDTH = 8;

reg clk;

// Instantiation of processing element
reg [WORD_WIDTH-1:0] a, b;
wire c_out;
wire [WORD_WIDTH-1:0] y;

Adder #(.WORD_WIDTH(WORD_WIDTH)) add_unit (.a(a), .b(b), .cout(cout), .y(y));

// Clock signal generation
initial begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # HCLOCK_PS clk = ~clk;
end


// PE test
initial begin : PE_TEST
    $dumpfile("adder_tb.vcd");
    $dumpvars(-1, a);
    $dumpvars(-1, b);
    $dumpvars(-1, y);
    $dumpvars(-1, cout);
    $monitor("a: %d  b: %d  y: %d  cout: %d", a, b, y, cout);

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