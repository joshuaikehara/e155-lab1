`timescale 1ns/1ps

module tb_lab3_synchronizer;

    logic clk;
    logic reset;
    logic [3:0] async_signal;
    logic [3:0] sync_signal;

    lab3_synchronizer dut (
        .clk(clk),
        .reset(reset),
        .async_signal(async_signal),
        .sync_signal(sync_signal)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        reset = 1'b0;
        async_signal = 4'b1111;

        // Reset
        repeat (2) @(posedge clk);

        if (sync_signal !== 4'b1111)
            $fatal("Synchronizer reset failed");

        reset = 1'b1;

        // Change input asynchronously, halfway between clocks
        #2;
        async_signal = 4'b0111;

        // Output should not change immediately
        #1;

        if (sync_signal !== 4'b1111)
            $fatal("Synchronizer output changed too early");

        // First clock: first synchronizer stage captures input
        @(posedge clk);
        #1;

        if (sync_signal !== 4'b1111)
            $fatal("Synchronizer output changed after only one stage");

        // Second clock: output should now follow
        @(posedge clk);
        #1;

        if (sync_signal !== 4'b0111)
            $fatal("Synchronizer failed to propagate input");

        // Change input exactly near a clock edge
        #4;
        async_signal = 4'b1011;

        @(posedge clk);
        #1;

        // Still old value after first synchronization stage
        if (sync_signal !== 4'b0111)
            $fatal("Synchronizer failed near clock edge");

        @(posedge clk);
        #1;

        if (sync_signal !== 4'b1011)
            $fatal("Synchronizer failed to propagate second input");

        $display("PASS: tb_lab3_synchronizer");

        $finish;
    end

endmodule

