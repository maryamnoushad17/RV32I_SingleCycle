`timescale 1ns/1ps
module tb_instr_mem;
    reg  [31:0] addr;
    wire [31:0] instr;
    integer errors = 0;

    instr_mem dut (.addr(addr), .instr(instr));

    task check(input [31:0] a, input [31:0] expected, input [127:0] name);
        begin
            addr = a;
            #1;
            if (instr !== expected) begin
                $display("FAIL: %0s got=%h expected=%h", name, instr, expected);
                errors = errors + 1;
            end else
                $display("PASS: %0s instr=%h", name, instr);
        end
    endtask

    initial begin
        // put known test instructions into the ROM (hierarchical access)
        #1;
        dut.mem[0] = 32'h00500093; // addi x1, x0, 5
        dut.mem[1] = 32'h00300113; // addi x2, x0, 3
        dut.mem[2] = 32'h002081B3; // add  x3, x1, x2
        dut.mem[3] = 32'hDEADBEEF; // marker word

        check(32'd0,  32'h00500093, "addr 0");
        check(32'd4,  32'h00300113, "addr 4");
        check(32'd8,  32'h002081B3, "addr 8");
        check(32'd12, 32'hDEADBEEF, "addr 12");
        // unused location must still be NOP
        check(32'd100, 32'h00000013, "unused = NOP");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule