module lab2_top #(
    parameter int MUX_WIDTH = 16,
    parameter logic [MUX_WIDTH-1:0] MUX_MAX_COUNT = 16'd47_999,
    parameter logic [MUX_WIDTH-1:0] MUX_HALF_COUNT = 16'd24_000
) (
    input logic reset,
    input logic [3:0] hex_left,
    input logic [3:0] hex_right,

    output logic [6:0] seg,
    output logic anode_left,
    output logic anode_right
);

    logic int_osc;
    logic digit_select;
    logic [3:0] selected_hex;

    // Internal oscillator
    HSOSC #(
        .CLKHF_DIV(2'b00)
    ) hf_osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(int_osc)
    );

    // Multiplexing counter
    lab2_multiplexing #(
        .WIDTH(MUX_WIDTH),
        .MAX_COUNT(MUX_MAX_COUNT),
        .HALF_COUNT(MUX_HALF_COUNT)
    ) mux (
        .clk(int_osc),
        .reset(reset),
        .digit_select(digit_select)
    );

    // Choose which hexadecimal value is displayed
    assign selected_hex = digit_select ? hex_right : hex_left;

    // ONE seven-segment decoder
    lab1_seven_segment decoder (
        .s(selected_hex),
        .seg(seg)
    );

    // Select active display
    assign anode_left  = digit_select;
    assign anode_right = ~digit_select;

endmodule
