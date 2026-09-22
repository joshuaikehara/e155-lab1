`timescale 1ns/1ps

module tb_lab3_keypad_controller;

    logic       clk;
    logic       reset;
    logic [3:0] keypad_col;
    logic [3:0] keypad_row;
    logic [3:0] key;
    logic       key_valid;

    lab3_keypad_controller dut (
        .clk        (clk),
        .reset      (reset),
        .keypad_col (keypad_col),
        .keypad_row (keypad_row),
        .key        (key),
        .key_valid  (key_valid)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;


    logic [15:0] pressed_keys;

    always_comb begin

        keypad_col = 4'b1111;

        case (keypad_row)

            4'b0001: begin
                if (pressed_keys[0]) keypad_col[0] = 1'b0;
                if (pressed_keys[1]) keypad_col[1] = 1'b0;
                if (pressed_keys[2]) keypad_col[2] = 1'b0;
                if (pressed_keys[3]) keypad_col[3] = 1'b0;
            end

            4'b0010: begin
                if (pressed_keys[4]) keypad_col[0] = 1'b0;
                if (pressed_keys[5]) keypad_col[1] = 1'b0;
                if (pressed_keys[6]) keypad_col[2] = 1'b0;
                if (pressed_keys[7]) keypad_col[3] = 1'b0;
            end

            4'b0100: begin
                if (pressed_keys[8])  keypad_col[0] = 1'b0;
                if (pressed_keys[9])  keypad_col[1] = 1'b0;
                if (pressed_keys[10]) keypad_col[2] = 1'b0;
                if (pressed_keys[11]) keypad_col[3] = 1'b0;
            end

            4'b1000: begin
                if (pressed_keys[12]) keypad_col[0] = 1'b0;
                if (pressed_keys[13]) keypad_col[1] = 1'b0;
                if (pressed_keys[14]) keypad_col[2] = 1'b0;
                if (pressed_keys[15]) keypad_col[3] = 1'b0;
            end

            default:
                keypad_col = 4'b1111;

        endcase
    end

    // Key press/release tasks

    task automatic press_key(input integer key_number);
        begin
            pressed_keys[key_number] = 1'b1;

            $display(
                "  PRESS key %0d at %0t ns",
                key_number,
                $time
            );
        end
    endtask

    task automatic release_key(input integer key_number);
        begin
            pressed_keys[key_number] = 1'b0;

            $display(
                "  RELEASE key %0d at %0t ns",
                key_number,
                $time
            );
        end
    endtask

    // Wait for complete keypad scans

    task automatic wait_scans(input integer num_scans);
        integer i;

        begin
            for (i = 0; i < num_scans; i = i + 1)
                @(posedge dut.i_scanner.scan_complete);

            #1;
        end
    endtask

    // Expect a key_valid pulse
    task automatic expect_key(input logic [3:0] expected_key);
        begin

            @(posedge key_valid);
            #1;

            if (key !== expected_key) begin
                $fatal(
                    1,
                    "FAIL: Expected key %h, got %h at %0t ns",
                    expected_key,
                    key,
                    $time
                );
            end

            $display(
                "  PASS: key_valid = 1, key = %h at %0t ns",
                key,
                $time
            );

            @(negedge key_valid);
        end
    endtask

    // Verify no key_valid occurs

    task automatic expect_no_key(input integer num_clocks);
        integer i;

        begin
            for (i = 0; i < num_clocks; i = i + 1) begin
                @(negedge clk);

                if (key_valid !== 1'b0) begin
                    $fatal(
                        1,
                        "FAIL: Unexpected key_valid at %0t ns, key = %h",
                        $time,
                        key
                    );
                end
            end
        end
    endtask

    // Reset

    task automatic reset_dut;
        begin

            pressed_keys = 16'b0;
            reset = 1'b0;

            repeat (5)
                @(posedge clk);

            // Deassert reset away from a clock edge.
            #2;
            reset = 1'b1;

            repeat (5)
                @(posedge clk);

            $display("");
            $display(" RESET COMPLETE");
            $display("");
        end
    endtask

    // TEST SEQUENCE

    initial begin

        reset = 1'b0;
        pressed_keys = 16'b0;

        reset_dut();

        // TEST 1: Single key press

        $display("TEST 1: Single key press");

        press_key(5);
        expect_key(4'h5);

        // Holding the key must not cause repeated registration.
        expect_no_key(5000);

        release_key(5);
        wait_scans(5);

        $display("TEST 1 PASSED");
        $display("");

        // TEST 2: New key after release

        $display("TEST 2: New key after release");

        press_key(6);
        expect_key(4'h6);

        expect_no_key(3000);

        release_key(6);
        wait_scans(5);

        $display("TEST 2 PASSED");
        $display("");

        // TEST 3: Switch bounce

        $display("TEST 3: Switch bounce");

        // Simulated mechanical bounce.
        press_key(9);
        #20;
        release_key(9);
        #20;

        press_key(9);
        #15;
        release_key(9);
        #15;

        press_key(9);
        #10;
        release_key(9);
        #10;

        // Final stable press.
        press_key(9);

        expect_key(4'h8);

        // Only one registration should occur.
        expect_no_key(3000);

        release_key(9);
        wait_scans(5);

        $display("TEST 3 PASSED");
        $display("");

        // TEST 4: Multiple keys, then one NEW key remains

        $display("TEST 4: Multiple keys -> new remaining key");

        // First register key 2.
        press_key(1);
        expect_key(4'h2);

        // Press key 3 while key 2 is still held.
        press_key(2);

        // Multiple keys are now held.
        expect_no_key(3000);

        // Release the ORIGINAL key.
        release_key(1);

        // Key 3 is now the only remaining key.
        // It should eventually register.
        expect_key(4'h3);

        expect_no_key(3000);

        release_key(2);
        wait_scans(5);

        $display("TEST 4 PASSED");
        $display("");

        // TEST 5: Multiple simultaneous keys from beginning

        $display("TEST 5: Multiple simultaneous keys");

        press_key(0);
        press_key(5);
        press_key(10);

        // No key should register while multiple keys are held.
        expect_no_key(5000);

        release_key(0);
        release_key(5);
        release_key(10);

        wait_scans(5);

        $display("TEST 5 PASSED");
        $display("");

        // TEST 6: Multiple keys -> one remains

        $display("TEST 6: Multiple keys -> one remains");


        press_key(3);
        press_key(7);
        press_key(11);

        expect_no_key(4000);

        // Leave key 7 as the only remaining key.
        release_key(3);
        release_key(11);

        expect_key(4'hB);

        expect_no_key(3000);

        release_key(7);
        wait_scans(5);

        $display("TEST 6 PASSED");
        $display("");

        // TEST 7: Multiple keys -> all released -> new key

        $display("TEST 7: Multiple keys -> all released -> new key");

        press_key(4);
        press_key(8);

        expect_no_key(4000);

        release_key(4);
        release_key(8);

        wait_scans(5);

        // Completely new key after all keys are released.
        press_key(10);

        expect_key(4'h9);

        expect_no_key(3000);

        release_key(10);
        wait_scans(5);

        $display("TEST 7 PASSED");
        $display("");

        // TEST 8: Key mapping

        $display("TEST 8: Key mapping");

        press_key(0);
        expect_key(4'h1);
        release_key(0);
        wait_scans(5);

        press_key(3);
        expect_key(4'hA);
        release_key(3);
        wait_scans(5);

        press_key(8);
        expect_key(4'h7);
        release_key(8);
        wait_scans(5);

        press_key(11);
        expect_key(4'hC);
        release_key(11);
        wait_scans(5);

        press_key(12);
        expect_key(4'hE);
        release_key(12);
        wait_scans(5);

        press_key(13);
        expect_key(4'h0);
        release_key(13);
        wait_scans(5);

        press_key(14);
        expect_key(4'hF);
        release_key(14);
        wait_scans(5);

        press_key(15);
        expect_key(4'hD);
        release_key(15);
        wait_scans(5);

        $display("TEST 8 PASSED");
        $display("");

        // TEST 9: Asynchronous transition - early (1ns after)

        $display("TEST 9: Asynchronous transition - early");

        @(negedge clk);
        #1;

        press_key(2);
        expect_key(4'h3);

        release_key(2);
        wait_scans(5);

        $display("TEST 9 PASSED");
        $display("");

        // TEST 10: Asynchronous transition - middle (3ns)

        $display("TEST 10: Asynchronous transition - middle");

        @(negedge clk);
        #3;

        press_key(6);
        expect_key(4'h6);

        release_key(6);
        wait_scans(5);

        $display("TEST 10 PASSED");
        $display("");

        // TEST 11: Asynchronous transition - near rising edge

        $display("TEST 11: Asynchronous transition - near rising edge");

        @(negedge clk);
        #4;

        press_key(8);
        expect_key(4'h7);

        release_key(8);
        wait_scans(5);

        $display("TEST 11 PASSED");
        $display("");

        // TEST 12: Transition exactly on a clock edge (1ns before)

        $display("TEST 12: Transition exactly on clock edge");

        // Move to a falling edge, then wait one half-period.
        // The next event is the rising edge at the same timestamp
        // at which the key transition is scheduled.
        @(negedge clk);

        fork
            begin
                #5;
                press_key(10);
            end

            begin
                #5;
                // Nothing here; this branch ensures the transition
                // is intentionally scheduled at the rising edge time.
            end
        join

        expect_key(4'h9);

        release_key(10);
        wait_scans(5);

        $display("TEST 12 PASSED");
        $display("");

        $display(" LAB 3 KEYPAD CONTROLLER TESTS PASSED");
        $display("");

        $finish;
    end

endmodule
