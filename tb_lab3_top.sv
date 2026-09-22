`timescale 1ns/1ps
module tb_lab3_top;

    logic reset;

    logic [3:0] keypad_col;
    logic [3:0] keypad_row;

    logic [6:0] seg;
    logic anode_left;
    logic anode_right;

    lab3_top dut (
        .reset(reset),
        .keypad_col(keypad_col),
        .keypad_row(keypad_row),
        .seg(seg),
        .anode_left(anode_left),
        .anode_right(anode_right)
    );

    // KEYPAD MODEL

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

    task automatic press_key(
        input integer key_number
    );
        begin
            pressed_keys[key_number] = 1'b1;
        end
    endtask


    task automatic release_key(
        input integer key_number
    );
        begin
            pressed_keys[key_number] = 1'b0;
        end
    endtask


    task automatic wait_for_key(
        input logic [3:0] expected_key
    );

        begin

            @(posedge dut.i_keypad_controller.key_valid);
            #1;

            if (dut.i_keypad_controller.key !== expected_key)
                $fatal(
                    "Top-level controller produced wrong key. Expected %h, got %h",
                    expected_key,
                    dut.i_keypad_controller.key
                );

        end

    endtask


    task automatic wait_scans(
        input integer n
    );

        integer i;

        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge dut.i_keypad_controller.i_scanner.scan_complete);
        end

    endtask

    // TEST

    initial begin

        pressed_keys = 16'b0;

        reset = 1'b0;

        #100;

        reset = 1'b1;

        // Press key 1

        press_key(0);

        wait_for_key(4'h1);

        release_key(0);

        wait_scans(4);

        // Press key 2

        press_key(1);

        wait_for_key(4'h2);

        release_key(1);

        wait_scans(4);

        // Verify key history

        if (dut.i_key_history.hex_left !== 4'h1)
            $fatal(
                "Top-level hex_left incorrect. Expected 1, got %h",
                dut.i_key_history.hex_left
            );

        if (dut.i_key_history.hex_right !== 4'h2)
            $fatal(
                "Top-level hex_right incorrect. Expected 2, got %h",
                dut.i_key_history.hex_right
            );


        // Verify seven-segment decoder


        if (!dut.digit_select) begin

            if (seg !== 7'b1111001)
                $fatal(
                    "Seven-segment output for 1 incorrect: %b",
                    seg
                );

        end

        // Verify anodes are complementary

        if (anode_left === anode_right)
            $fatal("Seven-segment anodes are not complementary");


        // Verify display continues multiplexing

        repeat (10000) @(posedge dut.int_osc);

        if (anode_left === anode_right)
            $fatal("Multiplexing failed: anodes equal");


        $display("PASS: tb_lab3_top");

        $finish;

    end

endmodule
