`timescale 1ns/1ps
module lab2_top_tb;

    logic reset;
    logic [3:0] keypad_col;

    logic [3:0] keypad_row;
    logic [3:0] led;

    // Small counter values for fast simulation.
    // HSOSC is still used normally.
    lab2_top #(
        .SCAN_WIDTH(4),
        .SCAN_MAX_COUNT(4'd11),
        .ROW1_END(4'd2),
        .ROW2_END(4'd5),
        .ROW3_END(4'd8)
    ) dut (
        .reset(reset),
        .keypad_col(keypad_col),
        .keypad_row(keypad_row),
        .led(led)
    );

    initial begin

        // Initial conditions
        reset = 0;
        keypad_col = 4'b1111;

        // Allow reset to occur
        #100;

        if (keypad_row !== 4'b1000)
            $error("ERROR: Reset failed. Expected keypad_row = 1000, got %b",
                   keypad_row);
        else
            $display("PASS: Reset sets keypad_row = 1000");

        reset = 1;

        // Test LED inversion

        keypad_col = 4'b1111;
        #10;

        if (led !== 4'b0000)
            $error("ERROR: keypad_col = 1111, expected led = 0000");
        else
            $display("PASS: LED inversion for 1111");

        keypad_col = 4'b0000;
        #10;

        if (led !== 4'b1111)
            $error("ERROR: keypad_col = 0000, expected led = 1111");
        else
            $display("PASS: LED inversion for 0000");

        keypad_col = 4'b1010;
        #10;

        if (led !== 4'b0101)
            $error("ERROR: keypad_col = 1010, expected led = 0101");
        else
            $display("PASS: LED inversion for 1010");

        // Test keypad scanning

        keypad_col = 4'b1111;

        // Count 0-2 -> row 1000
        repeat (3) @(posedge dut.int_osc);
        #1;

        if (keypad_row !== 4'b1000)
            $error("ERROR: Expected keypad_row = 1000, got %b",
                   keypad_row);
        else
            $display("PASS: Keypad row 1000");

        // Count 3-5 -> row 0100
        repeat (3) @(posedge dut.int_osc);
        #1;

        if (keypad_row !== 4'b0100)
            $error("ERROR: Expected keypad_row = 0100, got %b",
                   keypad_row);
        else
            $display("PASS: Keypad row 0100");

        // Count 6-8 -> row 0010
        repeat (3) @(posedge dut.int_osc);
        #1;

        if (keypad_row !== 4'b0010)
            $error("ERROR: Expected keypad_row = 0010, got %b",
                   keypad_row);
        else
            $display("PASS: Keypad row 0010");

        // Count 9-11 -> row 0001
        repeat (3) @(posedge dut.int_osc);
        #1;

        if (keypad_row !== 4'b0001)
            $error("ERROR: Expected keypad_row = 0001, got %b",
                   keypad_row);
        else
            $display("PASS: Keypad row 0001");

        // Test wraparound

        repeat (1) @(posedge dut.int_osc);
        #1;

        if (keypad_row !== 4'b1000)
            $error("ERROR: Expected keypad_row = 1000 after wraparound, got %b",
                   keypad_row);
        else
            $display("PASS: Keypad scanning wraparound");

        // Test multiple column inputs

        keypad_col = 4'b1010;
        #10;

        if (led !== 4'b0101)
            $error("ERROR: Expected led = 0101, got %b", led);
        else
            $display("PASS: Multiple column inputs 1010");

        keypad_col = 4'b0101;
        #10;

        if (led !== 4'b1010)
            $error("ERROR: Expected led = 1010, got %b", led);
        else
            $display("PASS: Multiple column inputs 0101");

        // Test reset

        reset = 0;
        #10;

        if (keypad_row !== 4'b1000)
            $error("ERROR: Reset failed. Expected keypad_row = 1000, got %b",
                   keypad_row);
        else
            $display("PASS: Top-level reset");

        reset = 1;

        $display("Top-level testbench complete.");

        $finish;

    end

endmodule
