`timescale 1ns/1ps

module tb_lab3_key_history;

    logic clk;
    logic reset;

    logic [3:0] key;
    logic key_valid;

    logic [3:0] hex_left;
    logic [3:0] hex_right;

    lab3_key_history dut (
        .clk(clk),
        .reset(reset),
        .key(key),
        .key_valid(key_valid),
        .hex_left(hex_left),
        .hex_right(hex_right)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin

        reset = 1'b0;
        key = 4'h0;
        key_valid = 1'b0;

        repeat (2) @(posedge clk);
        #1;

        if (hex_left !== 4'h0 || hex_right !== 4'h0)
            $fatal("Key history reset failed");

        reset = 1'b1;

        // First key
        key = 4'h5;
        key_valid = 1'b1;

        @(posedge clk);
        #1;

        if (hex_left !== 4'h0 || hex_right !== 4'h5)
            $fatal(
                "First key failed. Expected 05, got %h%h",
                hex_left,
                hex_right
            );

        // No new key
        key_valid = 1'b0;
        key = 4'hA;

        @(posedge clk);
        #1;

        if (hex_left !== 4'h0 || hex_right !== 4'h5)
            $fatal("History changed when key_valid was low");

        // Second key
        key = 4'hA;
        key_valid = 1'b1;

        @(posedge clk);
        #1;

        if (hex_left !== 4'h5 || hex_right !== 4'hA)
            $fatal(
                "Second key failed. Expected 5A, got %h%h",
                hex_left,
                hex_right
            );

        // Third key
        key = 4'h3;

        @(posedge clk);
        #1;

        if (hex_left !== 4'hA || hex_right !== 4'h3)
            $fatal(
                "Third key failed. Expected A3, got %h%h",
                hex_left,
                hex_right
            );

        $display("PASS: tb_lab3_key_history");

        $finish;
    end

endmodule
