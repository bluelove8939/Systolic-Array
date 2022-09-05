`include "../systolic_array.v"


/*
 * Testbench for Weight Stationary Systolic Array
 *
 * Description
 *   Weight stationary systolic array
 *   For simplicity, this processor only utilizes integer values 
 *   (weight and input feature values)
 */

module tb_systolic_array_ws;

// Params
`include "./params.v"

parameter  CLOCK_PS = 10000;
localparam HCLOCK_PS = CLOCK_PS / 2;
localparam WORDWIDTH = 8;
localparam ARRWIDTH = 4;
localparam ARRHEIGHT = 4;

integer clk_counter;


// Instantiation of processing element
reg clk;
reg reset_n;
reg mode;

reg [WORDWIDTH*ARRWIDTH-1:0] w_in_vec;
reg [WORDWIDTH*ARRHEIGHT-1:0] a_in_vec;
wire [WORDWIDTH*4*ARRWIDTH-1:0] ps_out_vec;

SystolicArrayWS #(
    .WORDWIDTH(WORDWIDTH),
    .ARRHEIGHT(ARRHEIGHT),
    .ARRWIDTH(ARRWIDTH)
) sa (
    .clk(clk),
    .reset_n(reset_n),
    .mode(mode),

    .w_in_vec(w_in_vec),
    .a_in_vec(a_in_vec),
    .ps_out_vec(ps_out_vec)
);


// Clock signal generation
initial begin : CLOCK_GENERATOR
    clk = 1'b0;
    clk_counter = 0;
    forever
        # HCLOCK_PS clk = ~clk;
end

always @(posedge clk) begin
    clk_counter = clk_counter + 1;
end

// PE test
initial begin : PE_TEST
    $dumpfile("tb_systolic_array_ws.vcd");
    $dumpvars(-1, sa);

    $monitor("clk: %3d  ps_out: %b\n", clk_counter, ps_out_vec);
    
    reset_n = 1;
    # HCLOCK_PS
    reset_n = 0;
    # HCLOCK_PS
    reset_n = 1;

    mode = 1'b0;  // SAMODE_WL
    w_in_vec[7:0]   = 1;
    w_in_vec[15:8]  = 2;
    w_in_vec[23:16] = 3;
    w_in_vec[31:24] = 4;
    # CLOCK_PS

    w_in_vec[7:0]   = 4;
    w_in_vec[15:8]  = 3;
    w_in_vec[23:16] = 2;
    w_in_vec[31:24] = 1;
    # CLOCK_PS

    w_in_vec[7:0]   = 1;
    w_in_vec[15:8]  = 2;
    w_in_vec[23:16] = 3;
    w_in_vec[31:24] = 4;
    # CLOCK_PS

    w_in_vec[7:0]   = 4;
    w_in_vec[15:8]  = 3;
    w_in_vec[23:16] = 2;
    w_in_vec[31:24] = 1;
    # CLOCK_PS

    mode = 1'b1;  // SAMODE_PS
    a_in_vec[7:0]   = 1;
    a_in_vec[15:8]  = 2;
    a_in_vec[23:16] = 3;
    a_in_vec[31:24] = 4;
    # CLOCK_PS

    a_in_vec[7:0]   = 4;
    a_in_vec[15:8]  = 3;
    a_in_vec[23:16] = 2;
    a_in_vec[31:24] = 1;
    # CLOCK_PS

    a_in_vec[7:0]   = 1;
    a_in_vec[15:8]  = 2;
    a_in_vec[23:16] = 3;
    a_in_vec[31:24] = 4;
    # CLOCK_PS

    a_in_vec[7:0]   = 4;
    a_in_vec[15:8]  = 3;
    a_in_vec[23:16] = 2;
    a_in_vec[31:24] = 1;
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