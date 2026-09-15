module lab2_scanning #(
    parameter int WIDTH = 25,
    parameter logic [WIDTH-1:0] MAX_COUNT = 25'd23_999_999,
    parameter logic [WIDTH-1:0] ROW1_END = 25'd5_999_999,
    parameter logic [WIDTH-1:0] ROW2_END = 25'd11_999_999,
    parameter logic [WIDTH-1:0] ROW3_END = 25'd17_999_999
) (
    input logic clk,
    input logic reset,
    input logic enable,
    output logic [3:0] row
);

    logic [WIDTH-1:0] count;

    lab1_counter #(
        .WIDTH(WIDTH),
        .MAX_COUNT(MAX_COUNT)
    ) scan_counter (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .count(count)
    );

    assign row[3] = (count <= ROW1_END);
    assign row[2] = (count > ROW1_END) && (count <= ROW2_END);
    assign row[1] = (count > ROW2_END) && (count <= ROW3_END);
    assign row[0] = (count > ROW3_END);

endmodule
