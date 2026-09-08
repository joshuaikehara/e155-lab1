`timescale 1ns/1ns

module lab1_counter_tb;

    logic clk;
    logic reset;
    logic enable;
    logic blink;

    lab1_counter #(
        .WIDTH(2),
        .MAX_COUNT(2'd3)
    ) dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .blink(blink)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin

        clk = 1'b0;
        reset = 1'b1;
        enable = 1'b0;

        // Reset test
        @(posedge clk);
        #1;

        assert(dut.count == 2'd0)
            else $error("Reset did not set count to zero.");

        assert(blink == 1'b0)
            else $error("Reset did not clear blink.");

        // Enable = 0 test
        reset = 1'b0;
        enable = 1'b0;

        repeat (3)
            @(posedge clk);

        #1;

        assert(dut.count == 2'd0)
            else $error("Counter changed while disabled.");

        // Enable = 1 / counting test
        enable = 1'b1;

        @(posedge clk);
        #1;

        assert(dut.count == 2'd1)
            else $error("Counter did not count to 1.");

        @(posedge clk);
        #1;

        assert(dut.count == 2'd2)
            else $error("Counter did not count to 2.");

        @(posedge clk);
        #1;

        assert(dut.count == 2'd3)
            else $error("Counter did not reach MAX_COUNT.");

        // MAX_COUNT wrap test
        @(posedge clk);
        #1;

        assert(dut.count == 2'd0)
            else $error("Counter did not wrap to zero.");

        assert(blink == 1'b1)
            else $error("Blink did not toggle at MAX_COUNT.");


        // Disable while counter has a nonzero value
        @(posedge clk);
        #1;

        assert(dut.count == 2'd1)
            else $error("Counter did not resume counting.");

        enable = 1'b0;

        repeat (3)
            @(posedge clk);

        #1;

        assert(dut.count == 2'd1)
            else $error("Counter changed while disabled.");

        $display("Counter testbench PASSED.");
        $finish;

    end

endmodule
