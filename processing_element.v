`include "adder.v"
`include "multiplier.v"


module ProcessingElementWS #(
    parameter WORD_WIDTH = 8
) (
    input clk,      // global clock signal
    input reset_n,  // global reset signal

    input [1:0] control,  // control signal (00: IDLE, 01: WEIGHT_INPUT, 10: MULTIPLY)

    input  [WORD_WIDTH-1:0]   a_in,  // activation input port
    input  [WORD_WIDTH*4-1:0] d_in,  // data(weight and partial num) input port

    // output reg [1:0] control_out,  // propagation of control signal to right-adjacent PE

    output reg [WORD_WIDTH-1:0]   a_out,  // output port for activation propagation to right-adjacent PE
    output reg [WORD_WIDTH*4-1:0] d_out   // output port for data(weight and partial sum) propatation to bottom-adjacent PE
);

// Registers and output assignment
// reg [WORD_WIDTH-1:0]   w_out_reg;   // weight output register
// reg [WORD_WIDTH-1:0]   a_out_reg;   // activation output register
// reg [WORD_WIDTH*4-1:0] ps_out_reg;  // partial sum output register

// reg [1:0] control_out_reg;  // control propagation toward right-adjacent PE

// assign a_out = a_out_reg;
// assign d_out = (control[1] == 1'b0) ? { {WORD_WIDTH*3{1'b0}}, w_out_reg } : ps_out_reg;

// assign control_out = control_out_reg;

reg [WORD_WIDTH-1:0] w_stored;


// Multiplier Instantiation (weight and activation multiplication)
wire [WORD_WIDTH-1:0] w_val,    // weight value
                      a_val;    // activation value
wire [WORD_WIDTH*2-1:0] y_val;  // weight * activaiton

assign w_val = w_stored;
assign a_val = a_in;

Multiplier #(.WORD_WIDTH(WORD_WIDTH)) mul_unit (
    .a(w_val), .b(a_val), .y(y_val)
);


// Adder Instantiation (partial sum accumulation)
wire [WORD_WIDTH*4-1:0] ext_y_val,   // multiplication result extended to INT32 
                        ps_out_val;  // partial sum output value
wire ps_out_cout;  // overflow (unused)

assign ext_y_val = { {WORD_WIDTH*2{1'b0}}, y_val };

Adder #(.WORD_WIDTH(WORD_WIDTH*4)) add_unit (
    .a(ext_y_val), .b(d_in), .y(ps_out_val), .cout(ps_out_cout)
);


// // Main operation (proper operation with respect to control signal)
// always @(posedge clk or negedge reset_n) begin
//     if (!reset_n) begin
//         w_out_reg <= 0;
//         a_out_reg <= 0;
//         ps_out_reg <= 0;

//         control_out_reg <= 0;
//     end 
    
//     else begin
//         control_out_reg <= control;

//         case (control)
//             2'b00: begin  // IDLE
//                 w_out_reg <= 0;
//                 a_out_reg <= 0;
//                 ps_out_reg <= 0;
//             end

//             2'b01: begin  // WEIGHT INPUT MODE
//                 w_out_reg <= d_in[WORD_WIDTH-1:0];
//                 a_out_reg <= 0;
//                 ps_out_reg <= 0;
//             end

//             2'b10: begin  // COMPUTATION MODE
//                 a_out_reg <= a_in;
//                 ps_out_reg <= ps_out_val;
//             end

//             default: begin
//                 w_out_reg <= 0;
//                 a_out_reg <= 0;
//                 ps_out_reg <= 0;
//             end
//         endcase
//     end
// end

// Main operation (proper operation with respect to control signal)
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        // control_out <= 0;

        a_out <= 0;
        d_out <= 0;
        w_stored <= 0;
    end 
    
    else begin
        // control_out <= control;

        case (control)
            2'b00: begin  // IDLE
                a_out <= 0;
                d_out <= 0;
                w_stored <= 0;
            end

            2'b01: begin  // WEIGHT INPUT MODE
                d_out <= d_in[WORD_WIDTH-1:0];
                a_out <= 0;

                w_stored <= d_in[WORD_WIDTH-1:0];
            end

            2'b10: begin  // COMPUTATION MODE
                a_out <= a_in;
                d_out <= ps_out_val;
            end

            default: begin
                a_out <= 0;
                d_out <= 0;
                w_stored <= 0;
            end
        endcase
    end
end
  
endmodule