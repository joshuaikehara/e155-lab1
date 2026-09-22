module lab3_key_history (
    input logic       clk,
    input logic       reset,

    input logic [3:0] key,
    input logic       key_valid,

    output logic [3:0] hex_left,
    output logic [3:0] hex_right
);

    always_ff @(posedge clk) begin

        if (~reset) begin

            hex_left  <= 4'h0;
            hex_right <= 4'h0;

        end

        else if (key_valid) begin

            hex_left  <= hex_right;
            hex_right <= key;

        end

    end

endmodule
