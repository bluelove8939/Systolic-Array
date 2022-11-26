`include "processing_element.v"


module SystolicArrayWS #(
    parameter ARR_WIDTH  = 8,
    parameter ARR_HEIGHT = 8,
    parameter WORD_WIDTH = 8
) (
    input clk,      // global clock signal
    input reset_n,  // global reset signal
    
    input [1:0] control,  // systolic array control signal

    input [WORD_WIDTH*ARR_WIDTH-1:0]  w_in_vec,  // weight input port
    input [WORD_WIDTH*ARR_HEIGHT-1:0] a_in_vec,  // activation input port

    output [WORD_WIDTH*4*ARR_WIDTH-1:0] ps_out_vec  // partial sum output port
);

// Wire split (vector to array)
wire [WORD_WIDTH*4-1:0] w_in   [0:ARR_WIDTH-1];
wire [WORD_WIDTH-1:0]   a_in   [0:ARR_HEIGHT-1];
wire [WORD_WIDTH*4-1:0] ps_out [0:ARR_WIDTH-1];

genvar w_in_idx;
genvar a_in_idx;
genvar ps_out_idx;

generate
    for (w_in_idx = 0; w_in_idx < ARR_WIDTH; w_in_idx = w_in_idx+1) begin
        assign w_in[w_in_idx] = { {WORD_WIDTH*3{1'b0}}, w_in_vec[(w_in_idx+1)*WORD_WIDTH-1:w_in_idx*WORD_WIDTH] };
    end

    for (a_in_idx = 0; a_in_idx < ARR_HEIGHT; a_in_idx = a_in_idx+1) begin
        assign a_in[a_in_idx] = a_in_vec[(a_in_idx+1)*WORD_WIDTH-1:a_in_idx*WORD_WIDTH];
    end

    for (ps_out_idx = 0; ps_out_idx < ARR_WIDTH; ps_out_idx = ps_out_idx+1) begin
        assign ps_out_vec[(ps_out_idx+1)*WORD_WIDTH*4-1:ps_out_idx*WORD_WIDTH*4] = ps_out[ps_out_idx];
    end
endgenerate


// Generate systolic array
wire [WORD_WIDTH-1:0]   a_in_arr [0:ARR_HEIGHT*ARR_WIDTH-1];
wire [WORD_WIDTH*4-1:0] d_in_arr [0:ARR_HEIGHT*ARR_WIDTH-1];

wire [1:0] control_arr [0:ARR_HEIGHT*ARR_WIDTH-1];
wire [1:0] control_out_arr [0:ARR_HEIGHT*ARR_WIDTH-1];

wire [WORD_WIDTH-1:0]   a_out_arr [0:ARR_HEIGHT*ARR_WIDTH-1];
wire [WORD_WIDTH*4-1:0] d_out_arr [0:ARR_HEIGHT*ARR_WIDTH-1];

genvar pe_idx;
genvar ro_idx;
genvar co_idx;

generate
    for (pe_idx = 0; pe_idx < ARR_HEIGHT*ARR_WIDTH; pe_idx = pe_idx+1) begin
        ProcessingElementWS #(
            .WORD_WIDTH(WORD_WIDTH)
        ) pe_unit (
            .clk(clk), .reset_n(reset_n),
            .control(control_arr[pe_idx]),
            .a_in(a_in_arr[pe_idx]), .d_in(d_in_arr[pe_idx]),
            .control_out(control_out_arr[pe_idx]),
            .a_out(a_out_arr[pe_idx]), .d_out(d_out_arr[pe_idx])
        );
    end

    for (ro_idx = 0; ro_idx < ARR_HEIGHT-1; ro_idx = ro_idx+1) begin
        for (co_idx = 0; co_idx < ARR_WIDTH; co_idx = co_idx+1) begin
            assign d_in_arr[(ro_idx+1)*ARR_WIDTH+co_idx] = d_out_arr[ro_idx*ARR_WIDTH+co_idx];
        end
    end

    for (co_idx = 0; co_idx < ARR_WIDTH-1; co_idx = co_idx+1) begin
        for (ro_idx = 0; ro_idx < ARR_HEIGHT; ro_idx = ro_idx+1) begin
            assign a_in_arr[ro_idx*ARR_WIDTH+co_idx+1] = a_out_arr[ro_idx*ARR_WIDTH+co_idx];
            assign control_arr[ro_idx*ARR_WIDTH+co_idx+1] = control_out_arr[ro_idx*ARR_WIDTH+co_idx];
        end
    end

    for (co_idx = 0; co_idx < ARR_WIDTH; co_idx = co_idx+1) begin
        assign d_in_arr[co_idx] = w_in[co_idx];
        assign ps_out[co_idx] = d_out_arr[(ARR_HEIGHT-1)*ARR_WIDTH+co_idx];
    end

    for (ro_idx = 0; ro_idx < ARR_HEIGHT-1; ro_idx = ro_idx+1) begin
        assign control_arr[ARR_WIDTH*(ro_idx+1)] = control_out_arr[ARR_WIDTH*ro_idx];
    end

    for (ro_idx = 0; ro_idx < ARR_HEIGHT; ro_idx = ro_idx+1) begin
        assign a_in_arr[ARR_WIDTH*ro_idx] = a_in[ro_idx];
    end
endgenerate

assign control_arr[0] = control;
    
endmodule