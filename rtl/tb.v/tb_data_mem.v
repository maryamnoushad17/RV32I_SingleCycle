`timescale 1ns/1ps
module tb_data_mem;
    reg         clk, we;
    reg  [2:0]  funct3;
    reg  [31:0] addr, wd;
    wire [31:0] rd;
    integer errors = 0;

    data_mem dut (.clk(clk), .we(we), .funct3(funct3),
                  .addr(addr), .wd(wd), .rd(rd));

    initial clk = 0;
    always #5 clk = ~clk;

    // store: set inputs, wait one clock edge, then disable write
    task store(input [2:0] f3, input [31:0] a, input [31:0] d);
        begin
            we = 1; funct3 = f3; addr = a; wd = d;
            @(posedge clk); #1;
            we = 0;
        end
    endtask

    // load: set address/funct3, wait, compare
    task load_check(input [2:0] f3, input [31:0] a,
                    input [31:0] expected, input [127:0] name);
        begin
            we = 0; funct3 = f3; addr = a;
            #1;
            if (rd !== expected) begin
                $display("FAIL: %0s got=%h expected=%h", name, rd, expected);
                errors = errors + 1;
            end else
                $display("PASS: %0s rd=%h", name, rd);
        end
    endtask

    initial begin
        we = 0; funct3 = 0; addr = 0; wd = 0;
        #12;

        // SW then LW
        store(3'b010, 32'd0, 32'hAABBCCDD);
        load_check(3'b010, 32'd0, 32'hAABBCCDD, "SW/LW");

        // LB (sign-extend): byte 0 = DD -> FFFFFFDD
        load_check(3'b000, 32'd0, 32'hFFFFFFDD, "LB byte0");
        // LBU (zero-extend): byte 0 = DD -> 000000DD
        load_check(3'b100, 32'd0, 32'h000000DD, "LBU byte0");
        // LB byte 3 = AA
        load_check(3'b000, 32'd3, 32'hFFFFFFAA, "LB byte3");
        // LH lower half = CCDD, upper half = AABB
        load_check(3'b001, 32'd0, 32'hFFFFCCDD, "LH low");
        load_check(3'b001, 32'd2, 32'hFFFFAABB, "LH high");
        // LHU
        load_check(3'b101, 32'd0, 32'h0000CCDD, "LHU low");

        // SB into word 1, byte 2
        store(3'b010, 32'd4, 32'h00000000);
        store(3'b000, 32'd6, 32'h00000055);
        load_check(3'b010, 32'd4, 32'h00550000, "SB");

        // SH into word 2, upper half
        store(3'b010, 32'd8, 32'h00000000);
        store(3'b001, 32'd10, 32'h00001234);
        load_check(3'b010, 32'd8, 32'h12340000, "SH");

        // write disabled: nothing should change
        we = 0; funct3 = 3'b010; addr = 32'd0; wd = 32'hDEADBEEF;
        @(posedge clk); #1;
        load_check(3'b010, 32'd0, 32'hAABBCCDD, "WE=0 hold");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TESTS FAILED", errors);
        $finish;
    end
endmodule