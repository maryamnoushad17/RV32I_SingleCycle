`timescale 1ns/1ps
module core_top_tb;
    reg clk = 0, rst = 1;
    wire [31:0] debug_out;

    core_top dut (.clk(clk), .rst(rst), .debug_out(debug_out));

    always #5 clk = ~clk;

    initial begin
        #22 rst = 0;
        repeat (40) @(posedge clk);
        $stop;
    end

    always @(posedge clk)
        $display("t=%0t pc=%h instr=%h alu=%h wb=%h we=%b",
                 $time, dut.pc, dut.instr, dut.alu_result, dut.wb_data, dut.reg_write);
endmodule