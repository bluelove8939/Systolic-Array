`include "processing_element.v"

`timescale 1ns/1ps


/*
 * Testbench for Weight Stationary Processing Element
 *
 * Description
 *   Weight stationary processing element for systolic array
 *   For simplicity, this processor only utilizes integer values 
 *   (weight and input feature values)
 */

module tb_processing_element;

// Params
`include "./params.v"

parameter  CLOCK_PS = 10000;
localparam HCLOCK_PS = CLOCK_PS / 2;
localparam WORDWIDTH = 8;


// Instantiation of processing element
reg clk;
reg reset_n;
reg mode;

reg                    enable_in;
reg [WORDWIDTH-1:0]    w_in;
reg [WORDWIDTH-1:0]    a_in;
reg [WORDWIDTH*4-1:0]  ps_in;

wire                   enable_out;
wire [WORDWIDTH-1:0]   w_out;
wire [WORDWIDTH-1:0]   a_out;
wire [WORDWIDTH*4-1:0] ps_out;

ProcessingElementWS #(
    .WORDWIDTH(WORDWIDTH)
) pe (
    .clk(clk),
    .reset_n(reset_n),
    .mode(mode),

    .enable_in(enable_in),
    .w_in(w_in),
    .a_in(a_in),
    .ps_in(ps_in),
    
    .enable_out(enable_out),
    .w_out(w_out),
    .a_out(a_out),
    .ps_out(ps_out)
);


// Clock signal generation
initial begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # HCLOCK_PS clk = ~clk;
end


// PE test
initial begin : PE_TEST
    $dumpfile("tb_processing_element.vcd");
    $dumpvars(-1, pe);
    $monitor("a_out:  %d\n", a_out);
    $monitor("ps_out: %d\n", ps_out);

    w_in = 3;
    a_in = 2;

    reset_n = 1;
    # HCLOCK_PS
    reset_n = 0;
    # HCLOCK_PS

    reset_n = 1;
    enable_in = 1'b1;
    mode = 1'b0;
    # CLOCK_PS

    ps_in = 5;
    mode = 1'b1;
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule