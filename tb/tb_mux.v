`timescale 1ns/1ps

module tb_mux;

    reg [31:0] a, b, c;
    reg sel;
    reg [1:0] sel3;

    wire [31:0] y2;
    wire [31:0] y3;

    integer errors;

    // 2-to-1 MUX
    mux2 uut1 (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y2)
    );

    // 3-to-1 MUX
    mux3 uut2 (
        .a(a),
        .b(b),
        .c(c),
        .sel(sel3),
        .y(y3)
    );

    initial begin

        errors = 0;

        a = 32'd10;
        b = 32'd20;
        c = 32'd30;

        // Test 2-to-1 MUX
        sel = 0;
        #10;
        if (y2 == a)
            $display("PASS: MUX2 sel=0");
        else begin
            $display("FAIL: MUX2 sel=0");
            errors = errors + 1;
        end

        sel = 1;
        #10;
        if (y2 == b)
            $display("PASS: MUX2 sel=1");
        else begin
            $display("FAIL: MUX2 sel=1");
            errors = errors + 1;
        end

        // Test 3-to-1 MUX
        sel3 = 2'b00;
        #10;
        if (y3 == a)
            $display("PASS: MUX3 sel=00");
        else begin
            $display("FAIL: MUX3 sel=00");
            errors = errors + 1;
        end

        sel3 = 2'b01;
        #10;
        if (y3 == b)
            $display("PASS: MUX3 sel=01");
        else begin
            $display("FAIL: MUX3 sel=01");
            errors = errors + 1;
        end

        sel3 = 2'b10;
        #10;
        if (y3 == c)
            $display("PASS: MUX3 sel=10");
        else begin
            $display("FAIL: MUX3 sel=10");
            errors = errors + 1;
        end

        sel3 = 2'b11;
        #10;
        if (y3 == a)
            $display("PASS: MUX3 sel=11 (Default)");
        else begin
            $display("FAIL: MUX3 sel=11");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("TOTAL ERRORS = %d", errors);

        $finish;
    end

endmodule