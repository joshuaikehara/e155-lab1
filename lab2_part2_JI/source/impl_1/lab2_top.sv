module lab2_top #(
    parameter int SCAN_WIDTH = 25,
    parameter logic [SCAN_WIDTH-1:0] SCAN_MAX_COUNT = 25'd23_999_999,
    parameter logic [SCAN_WIDTH-1:0] ROW1_END = 25'd5_999_999,
    parameter logic [SCAN_WIDTH-1:0] ROW2_END = 25'd11_999_999,
    parameter logic [SCAN_WIDTH-1:0] ROW3_END = 25'd17_999_999
) (
    input logic reset,
    input logic [3:0] keypad_col,

    output logic [3:0] keypad_row,
    output logic [3:0] led
);

    logic int_osc;

    // HSOSC
    HSOSC #(
        .CLKHF_DIV(2'b00)
    ) hf_osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(int_osc)
    );

    // Keypad scanning
    lab2_scanning #(
        .WIDTH(SCAN_WIDTH),
        .MAX_COUNT(SCAN_MAX_COUNT),
        .ROW1_END(ROW1_END),
        .ROW2_END(ROW2_END),
        .ROW3_END(ROW3_END)
    ) scanner (
        .clk(int_osc),
        .reset(reset),
        .enable(1'b1),
        .row(keypad_row)
    );

    // Display keypad column activity on LEDs
    assign led = ~keypad_col;

endmodule
