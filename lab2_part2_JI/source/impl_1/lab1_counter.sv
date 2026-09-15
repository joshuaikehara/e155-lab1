module lab1_counter #(
    parameter int WIDTH = 24,
    parameter logic [WIDTH-1:0] MAX_COUNT = 24'd11_999_999
) (
    input  logic clk,
    input logic reset,
    input logic enable,
    output logic [WIDTH-1:0] count
);

    always_ff @(posedge clk) begin
        if (~reset) begin
            count <= '0;
        end
        else if (enable) begin
            if (count == MAX_COUNT) begin
                count <= '0;
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule
