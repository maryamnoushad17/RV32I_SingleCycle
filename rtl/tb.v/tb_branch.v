`timescale 1ns/1ps
module tb_branch;
    reg  [31:0] rs1_val, rs2_val;
    reg  [2:0]  funct3;
    reg         branch;
    wire        branch_taken;
    integer errors = 0;

    branch_logic dut (.rs1_val(rs1_val), .rs2_val(rs2_val),
                      .funct3(funct3), .branch(branch),
                      .branch_taken(branch_taken));

    task check(input expected, input [63:0] name);
        begin
            #1;
            if (branch_taken !== expected) begin
                $display("FAIL: %0s got=%b expected=%b", name, branch_taken, expected);
                errors = errors + 1;
            end else
                $display("PASS: %0s", name);
        end
    endtask

    initial begin
        branch = 1;

        rs1_val = 5; rs2_val = 5; funct3 = 3'b000; check(1, "BEQ eq");
        rs1_val = 5; rs2_val = 6; funct3 = 3'b000; check(0, "BEQ ne");
        rs1_val = 5; rs2_val = 6; funct3 = 3'b001; check(1, "BNE");
        rs1_val = 5; rs2_val = 5; funct3 = 3'b001; check(0, "BNE eq");

        // -1 vs 1: signed -1 < 1, but unsigned 0xFFFFFFFF > 1
        rs1_val = 32'hFFFFFFFF; rs2_val = 1;
        funct3 = 3'b100; check(1, "BLT");
        funct3 = 3'b101; check(0, "BGE");
        funct3 = 3'b110; check(0, "BLTU");
        funct3 = 3'b111; check(1, "BGEU");

        // branch = 0 means never taken
        branch = 0; rs1_val = 5; rs2_val = 5; funct3 = 3'b000;
        check(0, "NOT BRANCH");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule