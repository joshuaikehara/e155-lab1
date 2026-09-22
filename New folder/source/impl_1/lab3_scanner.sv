module lab3_scanner #(
    parameter int WIDTH = 16,
    parameter logic [WIDTH-1:0] MAX_COUNT = 16'd479
) (
    input logic        clk,
    input logic        reset,

    input logic [3:0]  keypad_col,

    output logic [3:0]  keypad_row,

    output logic [15:0] key_matrix,
    output logic        scan_complete
);

    logic [WIDTH-1:0] count;
    logic [1:0] row_index;

    logic scan_tick;
    logic complete_pending;

    // Reuse Lab 1 counter

    lab1_counter #(
        .WIDTH(WIDTH),
        .MAX_COUNT(MAX_COUNT)
    ) scan_counter (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .count(count)
    );

    assign scan_tick = (count == MAX_COUNT);

    // Row index

    always_ff @(posedge clk) begin

        if (~reset) begin
            row_index <= 2'd0;
        end

        else if (scan_tick) begin

            if (row_index == 2'd3)
                row_index <= 2'd0;
            else
                row_index <= row_index + 1'b1;

        end

    end

    // Drive one keypad row at a time

    always_comb begin

        case (row_index)

            2'd0: keypad_row = 4'b0001;
            2'd1: keypad_row = 4'b0010;
            2'd2: keypad_row = 4'b0100;
            2'd3: keypad_row = 4'b1000;

            default: keypad_row = 4'b0000;

        endcase

    end

    // key_matrix[n] = 1 means key n is pressed.

    always_ff @(posedge clk) begin

        if (~reset) begin

            key_matrix       <= 16'b0;
            complete_pending <= 1'b0;
            scan_complete    <= 1'b0;

        end

        else begin

            // scan_complete is a one-clock strobe
            scan_complete <= 1'b0;

            // Generate scan_complete one clock after the fourth row has been captured.
            if (complete_pending) begin

                scan_complete    <= 1'b1;
                complete_pending <= 1'b0;

            end

            if (scan_tick) begin

                case (row_index)

                    2'd0: begin
                        key_matrix[3:0] <= ~keypad_col;
                    end

                    2'd1: begin
                        key_matrix[7:4] <= ~keypad_col;
                    end

                    2'd2: begin
                        key_matrix[11:8] <= ~keypad_col;
                    end

                    2'd3: begin

                        key_matrix[15:12] <= ~keypad_col;

                        // The complete matrix will be valid after this clock edge.
                        complete_pending <= 1'b1;

                    end

                endcase

            end

        end

    end

endmodule
