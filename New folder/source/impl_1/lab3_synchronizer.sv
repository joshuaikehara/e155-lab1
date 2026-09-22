module lab3_synchronizer (
    input logic       clk,
    input logic       reset,
    input logic [3:0] async_signal,

    output logic [3:0] sync_signal
);

    logic [3:0] sync_ff1;

    always_ff @(posedge clk) begin

        if (~reset) begin
            sync_ff1   <= 4'b1111;
            sync_signal <= 4'b1111;
        end

        else begin
            sync_ff1    <= async_signal;
            sync_signal <= sync_ff1;
        end

    end

endmodule
