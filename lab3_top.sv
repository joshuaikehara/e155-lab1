module lab3_top #(
    parameter int MUX_WIDTH = 16,
    parameter logic [MUX_WIDTH-1:0] MUX_MAX_COUNT = 16'd47_999,
    parameter logic [MUX_WIDTH-1:0] MUX_HALF_COUNT = 16'd24_000
) (
    input logic reset,
    input logic [3:0] keypad_col,

    output logic [3:0] keypad_row,

    output logic [6:0] seg,
    output logic anode_left,
    output logic anode_right
);

    logic int_osc;

    logic digit_select;
    logic [3:0] selected_hex;

    logic [3:0] hex_left;
    logic [3:0] hex_right;

    logic [3:0] key;
    logic key_valid;

     // Internal oscillator

    HSOSC #(
        .CLKHF_DIV(2'b00)
    ) i_hf_osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(int_osc)
    );

    // Keypad controller

    lab3_keypad_controller i_keypad_controller (
        .clk(int_osc),
        .reset(reset),
        .keypad_col(keypad_col),
        .keypad_row(keypad_row),
        .key(key),
        .key_valid(key_valid)
    );

    // Store last two valid keys

    lab3_key_history i_key_history (
        .clk(int_osc),
        .reset(reset),
        .key(key),
        .key_valid(key_valid),
        .hex_left(hex_left),
        .hex_right(hex_right)
    );

    // Reuse Lab 2 multiplexing

    lab2_multiplexing #(
        .WIDTH(MUX_WIDTH),
        .MAX_COUNT(MUX_MAX_COUNT),
        .HALF_COUNT(MUX_HALF_COUNT)
    ) i_mux (
        .clk(int_osc),
        .reset(reset),
        .digit_select(digit_select)
    );


    // Select which hexadecimal digit goes to the decoder


    assign selected_hex = digit_select ? hex_right : hex_left;

    // Reuse Lab 1 seven-segment decoder

    lab1_seven_segment i_decoder (
        .s(selected_hex),
        .seg(seg)
    );

    // Select active seven-segment display

    assign anode_left  = digit_select;
    assign anode_right = ~digit_select;

endmodule
