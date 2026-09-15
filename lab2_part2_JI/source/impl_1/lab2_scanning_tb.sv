`timescale 1ns/1ps

module lab2_scanning_tb;

    localparam int WIDTH = 4;
    localparam logic [WIDTH-1:0] MAX_COUNT = 4'd11;

    logic clk;
    logic reset;
    logic enable;
    logic [3:0] row;

lab2_scanning #(
    .WIDTH(4),
    .MAX_COUNT(4'd11),
    .ROW1_END(4'd2),
    .ROW2_END(4'd5),
    .ROW3_END(4'd8)
) dut (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .row(row)
);


    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 0;
        enable = 1;

        // Test reset
        #12;
        reset = 1;

        // Test row 1000
		if (row !== 4'b1000)
            $error("ERROR: Expected row = 1000, got %b", row);
        else
            $display("PASS: Row 1000");


        repeat (3) @(posedge clk);
        #1;
        // Test row 0100
		if (row !== 4'b0100)
            $error("ERROR: Expected row = 0100, got %b", row);
        else
            $display("PASS: Row 0100");
        

        // Test row 0010
        repeat (3) @(posedge clk);
        #1;
		if (row !== 4'b0010)
            $error("ERROR: Expected row = 0010, got %b", row);
        else
            $display("PASS: Row 0010");

       

        // Test row 0001
        repeat (3) @(posedge clk);
        #1;
        if (row !== 4'b0001)
            $error("ERROR: Expected row = 0001, got %b", row);
        else
            $display("PASS: Row 0001");
        
        // Test counter wraparound
        repeat (3) @(posedge clk);
        #1;
        @(posedge clk);
        #1;

        if (row !== 4'b1000)
            $error("ERROR: Expected row = 1000 after wraparound, got %b", row);
        else
            $display("PASS: Counter wraparound");

        // Test enable = 0
        enable = 0;

        repeat (5) @(posedge clk);
        #1;

        if (row !== 4'b1000)
            $error("ERROR: Row changed while enable = 0");
        else
            $display("PASS: Enable holds row");

        // Test enable = 1
        enable = 1;

        repeat (3) @(posedge clk);
        #1;

        if (row !== 4'b0100)
            $error("ERROR: Expected row = 0100 after enable, got %b", row);
        else
            $display("PASS: Enable resumes scanning");

        // Test reset again
        reset = 0;

        @(posedge clk);
        #1;

        if (row !== 4'b1000)
            $error("ERROR: Reset failed. Expected row = 1000, got %b", row);
        else
            $display("PASS: Reset returns to row 1000");

        reset = 1;

        $display("Scanning module testbench complete.");

        $finish;
    end

endmodule
