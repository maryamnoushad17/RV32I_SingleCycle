`timescale 1ns/1ps
module tb_reg_file;
    reg         clk, we;
    reg  [4:0]  rs1, rs2, rd;
    reg  [31:0] wd;
    wire [31:0] rd1, rd2;
    integer errors = 0;

    reg_file dut (.clk(clk), .we(we), .rs1(rs1), .rs2(rs2),
                  .rd(rd), .wd(wd), .rd1(rd1), .rd2(rd2));

    // Clock: toggles every 5ns
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        we = 0; rs1 = 0; rs2 = 0; rd = 0; wd = 0;
        #12;

        // Test 1: write 100 to x5, read back
        we = 1; rd = 5'd5; wd = 32'd100;
        @(posedge clk); #1;
        we = 0; rs1 = 5'd5;
        #1;
        if (rd1 !== 32'd100) begin
            $display("FAIL: x5 expected 100, got %0d", rd1);
            errors = errors + 1;
        end else $display("PASS: x5 = 100");

        // Test 2: write 200 to x10, read both x5 and x10
        we = 1; rd = 5'd10; wd = 32'd200;
        @(posedge clk); #1;
        we = 0; rs1 = 5'd5; rs2 = 5'd10;
        #1;
        if (rd1 !== 32'd100 || rd2 !== 32'd200) begin
            $display("FAIL: two-port read");
            errors = errors + 1;
        end else $display("PASS: two-port read");

        // Test 3: try to write to x0, must stay 0
        we = 1; rd = 5'd0; wd = 32'd999;
        @(posedge clk); #1;
        we = 0; rs1 = 5'd0;
        #1;
        if (rd1 !== 32'd0) begin
            $display("FAIL: x0 changed to %0d", rd1);
            errors = errors + 1;
        end else $display("PASS: x0 stays 0");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule