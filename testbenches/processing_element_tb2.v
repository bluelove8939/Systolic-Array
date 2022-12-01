`include "processing_element.v"

`timescale 1ns/1ps

module processing_element_tb;

parameter  CLOCK_PS = 10000;
localparam HCLOCK_PS = CLOCK_PS / 2;
localparam WORD_WIDTH = 8;

integer clk_count;

reg clk;
reg reset_n;

// Instantiation of processing element
reg [1:0] control;
reg [WORD_WIDTH-1:0] a_in;
reg [WORD_WIDTH*4-1:0] d_in;

wire [1:0] control_out;

wire [WORD_WIDTH-1:0] a_out;
wire [WORD_WIDTH*4-1:0] d_out;

ProcessingElementWS #(.WORD_WIDTH(WORD_WIDTH)) pe_unit (
    .clk(clk), .reset_n(reset_n),
    .control(control),
    .a_in(a_in), .d_in(d_in),
    .control_out(control_out),
    .a_out(a_out), .d_out(d_out)
);

// Instantiation of processing element2
reg [WORD_WIDTH-1:0] a_in2;

wire [1:0] control_out2;

wire [WORD_WIDTH-1:0] a_out2;
wire [WORD_WIDTH*4-1:0] d_out2;

ProcessingElementWS #(.WORD_WIDTH(WORD_WIDTH)) pe_unit2 (
    .clk(clk), .reset_n(reset_n),
    .control(control_out),
    .a_in(a_in2), .d_in(d_out),
    .control_out(control_out2),
    .a_out(a_out2), .d_out(d_out2)
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
    $dumpfile("processing_element_tb2.vcd");
    $dumpvars(-1, clk);
    $dumpvars(-1, reset_n);
    $dumpvars(-1, control);
    $dumpvars(-1, a_in);
    $dumpvars(-1, d_in);
    $dumpvars(-1, a_out);
    $dumpvars(-1, d_out);
    $dumpvars(-1, a_out2);
    $dumpvars(-1, d_out2);
    $monitor("clk: %2d  a_in: %2d  a_in2: %2d  d_out: %2d  d_out2: %2d", clk_count, a_in, a_in2, d_out, d_out2);

    reset_n = 1;
    # HCLOCK_PS

    reset_n = 0;
    # HCLOCK_PS

    reset_n = 1;
    control = 2'b00;

    // # HCLOCK_PS

    # CLOCK_PS

    control = 2'b01;
    d_in = 3;
    # CLOCK_PS

    d_in = 4;
    # CLOCK_PS

    d_in = 5;
    # CLOCK_PS

    control = 2'b10;
    d_in = 4;
    a_in = 2;
    a_in2 = 3;

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule