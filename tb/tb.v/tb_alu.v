`timescale 1ns/1ps
module tb_alu;
    reg  [31:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;
    integer errors = 0;

    alu dut (.a(a), .b(b), .alu_ctrl(alu_ctrl), .result(result), .zero(zero));

    task check(input [31:0] expected, input [127:0] name);
        begin
            #1;
            if (result !== expected) begin
                $display("FAIL: %0s got=%h expected=%h", name, result, expected);
                errors = errors + 1;
            end else
                $display("PASS: %0s result=%h", name, result);
        end
    endtask

    initial begin
        a = 32'd10; b = 32'd5;
        alu_ctrl = 4'b0000; check(32'd15,  "ADD");
        alu_ctrl = 4'b0001; check(32'd5,   "SUB");
        alu_ctrl = 4'b0010; check(32'd0,   "AND");
        alu_ctrl = 4'b0011; check(32'd15,  "OR");
        alu_ctrl = 4'b0100; check(32'd15,  "XOR");
        alu_ctrl = 4'b0101; check(32'd320, "SLL");
        alu_ctrl = 4'b0110; check(32'd0,   "SRL");

        a = 32'hFFFFFFF0; b = 32'd4;
        alu_ctrl = 4'b0111; check(32'hFFFFFFFF, "SRA");

        a = 32'hFFFFFFFF; b = 32'd1;
        alu_ctrl = 4'b1000; check(32'd1, "SLT");
        alu_ctrl = 4'b1001; check(32'd0, "SLTU");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule