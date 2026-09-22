`timescale 1ns/1ps

module tb_lab3_scanner;

    localparam int WIDTH = 4;
    localparam logic [WIDTH-1:0] MAX_COUNT = 4'd3;

    logic clk;
    logic reset;

    logic [3:0] keypad_col;
    logic [3:0] keypad_row;

    logic [15:0] key_matrix;
    logic scan_complete;

    lab3_scanner #(
        .WIDTH(WIDTH),
        .MAX_COUNT(MAX_COUNT)
    ) dut (
        .clk(clk),
        .reset(reset),
        .keypad_col(keypad_col),
        .keypad_row(keypad_row),
        .key_matrix(key_matrix),
        .scan_complete(scan_complete)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Wait for scan_complete

    task automatic wait_for_scan_complete;
        begin
            @(posedge scan_complete);
            #1;
        end
    endtask

    // Check the current row

    task automatic check_row(
        input logic [3:0] expected_row
    );
        begin
            if (keypad_row !== expected_row)
                $fatal(
                    "Incorrect keypad row. Expected %b, got %b",
                    expected_row,
                    keypad_row
                );
        end
    endtask

    // Test

    initial begin

        reset = 1'b0;
        keypad_col = 4'b1111;

        repeat (2) @(posedge clk);

        if (key_matrix !== 16'b0)
            $fatal("Scanner reset failed: key_matrix != 0");

        if (scan_complete !== 1'b0)
            $fatal("Scanner reset failed: scan_complete != 0");

        reset = 1'b1;

        // Row 0

        check_row(4'b0001);

        // Press column 0 on row 0.
        // Columns are active-low.
        keypad_col = 4'b1110;

        repeat (4) @(posedge clk);
        #1;

        if (key_matrix[3:0] !== 4'b0001)
            $fatal(
                "Row 0 capture failed. Expected 0001, got %b",
                key_matrix[3:0]
            );

        // Row 1

        keypad_col = 4'b1101;

        repeat (4) @(posedge clk);
        #1;

        if (key_matrix[7:4] !== 4'b0010)
            $fatal(
                "Row 1 capture failed. Expected 0010, got %b",
                key_matrix[7:4]
            );

        // Row 2

        keypad_col = 4'b1011;

        repeat (4) @(posedge clk);
        #1;

        if (key_matrix[11:8] !== 4'b0100)
            $fatal(
                "Row 2 capture failed. Expected 0100, got %b",
                key_matrix[11:8]
            );

        // Row 3

        keypad_col = 4'b0111;

        repeat (4) @(posedge clk);
        #1;

        if (key_matrix[15:12] !== 4'b1000)
            $fatal(
                "Row 3 capture failed. Expected 1000, got %b",
                key_matrix[15:12]
            );

        // scan_complete occurs after row 3
        wait_for_scan_complete;

        if (scan_complete !== 1'b1)
            $fatal("scan_complete was not asserted");

        // Verify entire matrix
        if (key_matrix !== 16'b1000_0100_0010_0001)
            $fatal(
                "Complete matrix incorrect. Got %b",
                key_matrix
            );

        // Verify scan_complete is a one-clock pulse
        @(posedge clk);
        #1;

        if (scan_complete !== 1'b0)
            $fatal("scan_complete is not a one-clock pulse");

        // Verify scanner continues operating

        keypad_col = 4'b1111;

        wait_for_scan_complete;

        if (key_matrix !== 16'b0)
            $fatal(
                "Scanner failed to clear released keys. Got %b",
                key_matrix
            );

        $display("PASS: tb_lab3_scanner");

        $finish;
    end

endmodule
