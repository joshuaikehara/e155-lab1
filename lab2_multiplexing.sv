module lab2_multiplexing #(
    parameter int WIDTH = 16,
    parameter logic [WIDTH-1:0] MAX_COUNT = 16'd47_999,
    parameter logic [WIDTH-1:0] HALF_COUNT = 16'd24_000
) (
    input logic clk,
    input logic reset,

    output logic digit_select
);

    logic [WIDTH-1:0] count;

    lab1_counter #(
        .WIDTH(WIDTH),
        .MAX_COUNT(MAX_COUNT)
    ) i_mux_counter (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .count(count)
    );

    assign digit_select = (count >= HALF_COUNT);

endmodule
