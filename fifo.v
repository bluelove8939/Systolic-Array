module FIFO #(
    parameter WORD_WIDTH = 8,
    parameter FIFO_CAP   = 16,
    parameter PTR_WIDTH  = 4
) (
    input clk,
    input reset_n,

    input w_enable,
    input r_enable,

    input [WORD_WIDTH-1:0] d_in,

    output full,
    output empty,

    output [WORD_WIDTH-1:0] d_out
);

// Output assignment
wire full_flag, empty_flag;
wire [WORD_WIDTH-1:0] d_out_reg;

assign full = full_flag;
assign empty = empty_flag;
assign d_out = d_out_reg;


// Container and pointers
reg [WORD_WIDTH-1:0] container [0:FIFO_CAP-1];  // memory block

reg [PTR_WIDTH-1:0] w_ptr,  // current write pointer
                    r_ptr,  // current read pointer
                    w_ptr_nxt,  // next write pointer
                    r_ptr_nxt;  // next read pointer

reg w_ptr_phase,  // write pointer phase (indicates whether the pointer is wrapped up)
    r_ptr_phase,  // read pointer phase (indicates whether the pointer is wrapped up)
    w_ptr_nxt_phase,  // next write pointer phase
    r_ptr_nxt_phase;  // next read pointer phase


// Next write pointer
always @(w_ptr) begin
    if (w_ptr == (FIFO_CAP-1)) begin
        w_ptr_nxt = 0;
        w_ptr_nxt_phase = ~w_ptr_phase;
    end else begin
        w_ptr_nxt = w_ptr + 1;
        w_ptr_nxt_phase = w_ptr_phase;
    end
end


// Next read pointer
always @(r_ptr) begin
    if (r_ptr == (FIFO_CAP-1)) begin
        r_ptr_nxt = 0;
        r_ptr_nxt_phase = ~r_ptr_phase;
    end else begin
        r_ptr_nxt = r_ptr + 1;
        r_ptr_nxt_phase = r_ptr_phase;
    end
end


// Main operation
integer idx;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        for (idx = 0; idx < FIFO_CAP; idx = idx+1) begin
            container[idx] <= 0;
        end

        w_ptr <= 0;
        w_ptr_phase <= 0;

        r_ptr <= 0;
        r_ptr_phase <= 0;
    end

    else begin
        if (!full_flag && w_enable) begin
            container[w_ptr] <= d_in;
            w_ptr <= w_ptr_nxt + 1;
            w_ptr_phase <= w_ptr_nxt_phase;
        end 
        
        else if (!empty_flag && r_enable) begin
            r_ptr <= r_ptr_nxt + 1;
            r_ptr_phase <= r_ptr_nxt_phase;
        end
    end
end

assign full_flag = (w_ptr_phase != r_ptr_phase) && (w_ptr == r_ptr);
assign empty_flag = (w_ptr_phase == r_ptr_phase) && (w_ptr == r_ptr);
assign d_out_reg = container[r_ptr];

endmodule