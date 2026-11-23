`timescale 1ns/1ps
module tb_core;
    reg clk, rst;
    integer errors = 0;

    core_top dut (.clk(clk), .rst(rst));

    initial clk = 0;
    always #5 clk = ~clk;

    task check(input [31:0] actual, input [31:0] expected, input [127:0] name);
        begin
            if (actual !== expected) begin
                $display("FAIL: %0s got=%0d expected=%0d", name, actual, expected);
                errors = errors + 1;
            end else
                $display("PASS: %0s = %0d", name, actual);
        end
    endtask

    initial begin
        rst = 1;
        #1;
        dut.u_imem.mem[0] = 32'h00500093; // addi x1,x0,5
        dut.u_imem.mem[1] = 32'h00300113; // addi x2,x0,3
        dut.u_imem.mem[2] = 32'h002081B3; // add  x3,x1,x2
        dut.u_imem.mem[3] = 32'h00302023; // sw   x3,0(x0)
        dut.u_imem.mem[4] = 32'h00002203; // lw   x4,0(x0)
        dut.u_imem.mem[5] = 32'h00418463; // beq  x3,x4,+8
        dut.u_imem.mem[6] = 32'h06300293; // addi x5,x0,99 (skipped)
        dut.u_imem.mem[7] = 32'h00100313; // addi x6,x0,1
        dut.u_imem.mem[8] = 32'h0000006F; // jal  x0,0 (loop)

        #11 rst = 0;
        #200;

        check(dut.u_rf.regs[1], 5, "x1");
        check(dut.u_rf.regs[2], 3, "x2");
        check(dut.u_rf.regs[3], 8, "x3 add");
        check(dut.u_dmem.mem[0], 8, "mem0 sw");
        check(dut.u_rf.regs[4], 8, "x4 lw");
        check(dut.u_rf.regs[5], 0, "x5 skipped");
        check(dut.u_rf.regs[6], 1, "x6");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule