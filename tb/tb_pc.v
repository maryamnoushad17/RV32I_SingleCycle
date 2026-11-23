module tb_pc;
    reg clk = 0, rst = 1;
    reg  [31:0] pc_next;
    wire [31:0] pc_out, pc_plus4;
    integer errors = 0;

    pc dut (.clk(clk), .rst(rst), .pc_next(pc_next),
            .pc_out(pc_out), .pc_plus4(pc_plus4));

    always #5 clk = ~clk;

    initial begin
        pc_next = 32'd0;
        #12 rst = 0;                    // reset khatam

        // PC ko PC+4 se update karo (normal flow)
        repeat (3) begin
            pc_next = pc_plus4;
            @(posedge clk); #1;
        end
        if (pc_out !== 32'd12) begin errors = errors + 1; $display("FAIL: sequential PC"); end

        // Jump test
        pc_next = 32'h0000_0040;
        @(posedge clk); #1;
        if (pc_out !== 32'h40) begin errors = errors + 1; $display("FAIL: jump"); end

        // Reset test
        rst = 1;
        @(posedge clk); #1;
        if (pc_out !== 32'd0) begin errors = errors + 1; $display("FAIL: reset"); end

        if (errors == 0) $display("PC: ALL TESTS PASSED");
        $finish;
    end
endmodule