`timescale 1ns/1ps

module lab2_multiplexing_tb;

    localparam int WIDTH = 4;
    localparam logic [WIDTH-1:0] MAX_COUNT = 4'd7;
    localparam logic [WIDTH-1:0] HALF_COUNT = 4'd4;

    logic clk;
    logic reset;
    logic digit_select;

    lab2_multiplexing #(
        .WIDTH(WIDTH),
        .MAX_COUNT(MAX_COUNT),
        .HALF_COUNT(HALF_COUNT)
    ) dut (
        .clk(clk),
        .reset(reset),
        .digit_select(digit_select)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        // Test reset
        #12;
        reset = 1;

        // Counts 0-3 -> digit_select = 0
        repeat (3) @(posedge clk);
        #1;

        if (digit_select !== 1'b0)
            $error("ERROR: Expected digit_select = 0, got %b",
                   digit_select);
        else
            $display("PASS: Left digit selected");

        // Counts 4-7 -> digit_select = 1
        repeat (4) @(posedge clk);
        #1;

        if (digit_select !== 1'b1)
            $error("ERROR: Expected digit_select = 1, got %b",
                   digit_select);
        else
            $display("PASS: Right digit selected");

        // Counter wraps back to 0
        @(posedge clk);
        #1;

        if (digit_select !== 1'b0)
            $error("ERROR: Expected digit_select = 0 after wraparound, got %b",
                   digit_select);
        else
            $display("PASS: Multiplexing counter wraparound");

        // Test reset
        reset = 0;

        @(posedge clk);
        #1;

        if (digit_select !== 1'b0)
            $error("ERROR: Reset failed. Expected digit_select = 0, got %b",
                   digit_select);
        else
            $display("PASS: Multiplexing reset");

        reset = 0;

        $display("Multiplexing testbench complete.");

        $finish;

    end

endmodule
