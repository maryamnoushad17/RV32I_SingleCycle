`timescale 1ns/1ps
module tb_control;
    reg  [6:0] opcode, funct7;
    reg  [2:0] funct3;
    wire       reg_write, alu_src_b, mem_write, mem_read, branch, jump, jalr;
    wire [1:0] alu_src_a, wb_sel;
    wire [3:0] alu_ctrl;
    integer errors = 0;

    control dut (.opcode(opcode), .funct3(funct3), .funct7(funct7),
                 .reg_write(reg_write), .alu_src_a(alu_src_a),
                 .alu_src_b(alu_src_b), .mem_write(mem_write),
                 .mem_read(mem_read), .wb_sel(wb_sel), .branch(branch),
                 .jump(jump), .jalr(jalr), .alu_ctrl(alu_ctrl));

    // expected vector = {reg_write, alu_src_a[1:0], alu_src_b, mem_write,
    //                    mem_read, wb_sel[1:0], branch, jump, jalr, alu_ctrl[3:0]}
    task check(input [6:0] op, input [2:0] f3, input [6:0] f7,
               input [14:0] expected, input [127:0] name);
        reg [14:0] actual;
        begin
            opcode = op; funct3 = f3; funct7 = f7;
            #1;
            actual = {reg_write, alu_src_a, alu_src_b, mem_write, mem_read,
                      wb_sel, branch, jump, jalr, alu_ctrl};
            if (actual !== expected) begin
                $display("FAIL: %0s got=%b expected=%b", name, actual, expected);
                errors = errors + 1;
            end else
                $display("PASS: %0s", name);
        end
    endtask

    initial begin
        //                                     rw  sa  sb mw mr wb  br j  jr alu
        check(7'b0110011, 3'b000, 7'b0000000, {1'b1,2'b00,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,4'b0000}, "ADD");
        check(7'b0110011, 3'b000, 7'b0100000, {1'b1,2'b00,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,4'b0001}, "SUB");
        check(7'b0110011, 3'b111, 7'b0000000, {1'b1,2'b00,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,4'b0010}, "AND");
        check(7'b0110011, 3'b101, 7'b0100000, {1'b1,2'b00,1'b0,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,4'b0111}, "SRA");
        check(7'b0010011, 3'b000, 7'b0000000, {1'b1,2'b00,1'b1,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,4'b0000}, "ADDI");
        check(7'b0010011, 3'b101, 7'b0100000, {1'b1,2'b00,1'b1,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,4'b0111}, "SRAI");
        check(7'b0000011, 3'b010, 7'b0000000, {1'b1,2'b00,1'b1,1'b0,1'b1,2'b01,1'b0,1'b0,1'b0,4'b0000}, "LW");
        check(7'b0100011, 3'b010, 7'b0000000, {1'b0,2'b00,1'b1,1'b1,1'b0,2'b00,1'b0,1'b0,1'b0,4'b0000}, "SW");
        check(7'b1100011, 3'b000, 7'b0000000, {1'b0,2'b00,1'b0,1'b0,1'b0,2'b00,1'b1,1'b0,1'b0,4'b0001}, "BEQ");
        check(7'b1101111, 3'b000, 7'b0000000, {1'b1,2'b01,1'b1,1'b0,1'b0,2'b10,1'b0,1'b1,1'b0,4'b0000}, "JAL");
        check(7'b1100111, 3'b000, 7'b0000000, {1'b1,2'b00,1'b1,1'b0,1'b0,2'b10,1'b0,1'b0,1'b1,4'b0000}, "JALR");
        check(7'b0110111, 3'b000, 7'b0000000, {1'b1,2'b10,1'b1,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,4'b0000}, "LUI");
        check(7'b0010111, 3'b000, 7'b0000000, {1'b1,2'b01,1'b1,1'b0,1'b0,2'b00,1'b0,1'b0,1'b0,4'b0000}, "AUIPC");
        // unknown opcode: everything must stay at default (0)
        check(7'b1111111, 3'b000, 7'b0000000, 15'b0, "UNKNOWN");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule