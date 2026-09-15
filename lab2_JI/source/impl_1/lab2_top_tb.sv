`timescale 1ns/1ps

module lab2_top_tb;

    logic reset;
    logic [3:0] hex_left;
    logic [3:0] hex_right;

    logic [6:0] seg;
    logic anode_left;
    logic anode_right;

    // Use small counter values for fast simulation.
    // HSOSC is still used normally.
    lab2_top #(
        .MUX_WIDTH(4),
        .MUX_MAX_COUNT(4'd7),
        .MUX_HALF_COUNT(4'd4)
    ) dut (
        .reset(reset),
        .hex_left(hex_left),
        .hex_right(hex_right),
        .seg(seg),
        .anode_left(anode_left),
        .anode_right(anode_right)
    );

    initial begin

        // Set display values
        hex_left  = 4'h1;
        hex_right = 4'hA;

        // Test reset

        reset = 0;

        #100;

        if (anode_left !== 1'b0)
            $error("ERROR: Reset failed. Expected anode_left = 0, got %b",
                   anode_left);
        else
            $display("PASS: Reset sets left anode = 0");

        if (anode_right !== 1'b1)
            $error("ERROR: Reset failed. Expected anode_right = 1, got %b",
                   anode_right);
        else
            $display("PASS: Reset sets right anode = 1");

        reset = 1;

        // Check left display

        #10;

        if (anode_left !== 1'b0)
            $error("ERROR: Expected anode_left = 0, got %b",
                   anode_left);
        else
            $display("PASS: Left display selected");

        if (anode_right !== 1'b1)
            $error("ERROR: Expected anode_right = 1, got %b",
                   anode_right);
        else
            $display("PASS: Right display inactive");

        // 7-segment pattern for 1
        if (seg !== 7'b1111001)
            $error("ERROR: Expected segment pattern for 1, got %b",
                   seg);
        else
            $display("PASS: Left display shows 1");

        // Wait for multiplexing transition

        // Small parameterized counter:
        // 0-3 -> left
        // 4-7 -> right
        //
        // Wait long enough for the counter to reach
        // the right-display region.
        #100;


        // Check right display

        if (anode_left !== 1'b1)
            $error("ERROR: Expected anode_left = 1, got %b",
                   anode_left);
        else
            $display("PASS: Left display inactive");

        if (anode_right !== 1'b0)
            $error("ERROR: Expected anode_right = 0, got %b",
                   anode_right);
        else
            $display("PASS: Right display selected");

        // 7-segment pattern for A
        if (seg !== 7'b0001000)
            $error("ERROR: Expected segment pattern for A, got %b",
                   seg);
        else
            $display("PASS: Right display shows A");

        // Test changing display values

        hex_left  = 4'h5;
        hex_right = 4'hC;

        // Wait for the next left-display interval
        #100;

        $display("Changed display values:");
        $display("hex_left = %h", hex_left);
        $display("hex_right = %h", hex_right);

        // Test reset again

        reset = 0;

        #10;

        if (anode_left !== 1'b0)
            $error("ERROR: Reset failed. Expected anode_left = 0, got %b",
                   anode_left);
        else
            $display("PASS: Reset returns to left display");

        if (anode_right !== 1'b1)
            $error("ERROR: Reset failed. Expected anode_right = 1, got %b",
                   anode_right);
        else
            $display("PASS: Reset returns right anode to inactive");

        reset = 1;

        $display("Top-level testbench complete.");

        $finish;

    end

endmodule
