module lab1_seven_segment_tb;

    logic [3:0] s;
    logic [6:0] seg;

    lab1_seven_segment dut (
        .s(s),
        .seg(seg)
    );

    initial begin

        // Test 0
        s = 4'h0;
        #1;
        assert(seg == 7'b1000000)
            else $error("0 failed: seg = %b", seg);

        // Test 1
        s = 4'h1;
        #1;
        assert(seg == 7'b1111001)
            else $error("1 failed: seg = %b", seg);

        // Test 2
        s = 4'h2;
        #1;
        assert(seg == 7'b0100100)
            else $error("2 failed: seg = %b", seg);

        // Test 3
        s = 4'h3;
        #1;
        assert(seg == 7'b0110000)
            else $error("3 failed: seg = %b", seg);

        // Test 4
        s = 4'h4;
        #1;
        assert(seg == 7'b0011001)
            else $error("4 failed: seg = %b", seg);

        // Test 5
        s = 4'h5;
        #1;
        assert(seg == 7'b0010010)
            else $error("5 failed: seg = %b", seg);

        // Test 6
        s = 4'h6;
        #1;
        assert(seg == 7'b0000010)
            else $error("6 failed: seg = %b", seg);

        // Test 7
        s = 4'h7;
        #1;
        assert(seg == 7'b1111000)
            else $error("7 failed: seg = %b", seg);

        // Test 8
        s = 4'h8;
        #1;
        assert(seg == 7'b0000000)
            else $error("8 failed: seg = %b", seg);

        // Test 9
        s = 4'h9;
        #1;
        assert(seg == 7'b0010000)
            else $error("9 failed: seg = %b", seg);

        // Test A
        s = 4'hA;
        #1;
        assert(seg == 7'b0001000)
            else $error("A failed: seg = %b", seg);

        // Test B
        s = 4'hB;
        #1;
        assert(seg == 7'b0000011)
            else $error("B failed: seg = %b", seg);

        // Test C
        s = 4'hC;
        #1;
        assert(seg == 7'b1000110)
            else $error("C failed: seg = %b", seg);

        // Test D
        s = 4'hD;
        #1;
        assert(seg == 7'b0100001)
            else $error("D failed: seg = %b", seg);

        // Test E
        s = 4'hE;
        #1;
        assert(seg == 7'b0000110)
            else $error("E failed: seg = %b", seg);

        // Test F
        s = 4'hF;
        #1;
        assert(seg == 7'b0001110)
            else $error("F failed: seg = %b", seg);

        $display("Seven-segment testbench PASSED.");

        $finish;

    end

endmodule
