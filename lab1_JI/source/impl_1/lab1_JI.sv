module lab1_JI #(
    parameter int COUNTER_WIDTH = 24,
    parameter logic [COUNTER_WIDTH-1:0] COUNTER_MAX = 24'd9_999_999
) (
    input  logic [3:0] s,
    output logic [2:0] led,
    output logic [6:0] seg
);

    logic int_osc;
    logic blink;

    // Internal oscillator
    HSOSC #(
        .CLKHF_DIV(2'b00)
    ) hf_osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(int_osc)
    );

    // Seven-segment decoder
    lab1_seven_segment seven_segment (
        .s(s),
        .seg(seg)
    );

    // Counter used for blinking LED
    lab1_counter #(
        .WIDTH(COUNTER_WIDTH),
        .MAX_COUNT(COUNTER_MAX)
    ) blink_counter (
        .clk(int_osc),
        .reset(1'b0),
        .enable(1'b1),
        .blink(blink)
    );

    // Switch-to-LED combinational logic
    assign led[0] = s[1] ^ s[0];
    assign led[1] = s[3] & s[2];

    // Blinking LED
    assign led[2] = blink;

endmodule
