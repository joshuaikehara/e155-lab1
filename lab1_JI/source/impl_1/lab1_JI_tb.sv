`timescale 1ns/1ns

module lab1_JI_tb;

    logic [3:0] s;
    logic [2:0] led;
    logic [6:0] seg;

    // Use a small counter for simulation so LED 2
    // changes after only a few oscillator cycles.
    lab1_JI #(
        .COUNTER_WIDTH(2),
        .COUNTER_MAX(2'd3)
    ) dut (
        .s(s),
        .led(led),
        .seg(seg)
    );

    initial begin

        s = 4'b0000;


        // HSOSC test

        @(posedge dut.int_osc);
        @(negedge dut.int_osc);

        $display("HSOSC produced rising and falling edges.");

        // Top-level assign logic test
        // Test every switch combination

        for (int i = 0; i < 16; i++) begin

            s = i;
            #1;

            assert(led[0] == (s[1] ^ s[0]))
                else $error(
                    "led[0] failed for s = %b",
                    s
                );

            assert(led[1] == (s[3] & s[2]))
                else $error(
                    "led[1] failed for s = %b",
                    s
                );

        end

        // Seven-segment submodule connection already tested all 16 values on submodule so just testing for connection


        s = 4'h5;
        #1;

        assert(seg == 7'b0010010)
            else $error(
                "Seven-segment submodule connection failed."
            );

        // Counter to led[2] connection test

        assert(led[2] == dut.blink)
            else $error(
                "blink is not connected to led[2]."
            );

        // With MAX_COUNT = 3, LED 2 should change quickly
		// Observe several counter cycles
		repeat (7) begin
			@(posedge dut.int_osc);
		end

		assert(led[2] == dut.blink)
			else 
				$error("led[2] does not follow blink.");

		$display("Top-level testbench PASSED.");
		$finish;

    end

endmodule
