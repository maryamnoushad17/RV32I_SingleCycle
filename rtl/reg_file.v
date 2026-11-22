// Register File: 32 x 32-bit, 2 read ports, 1 write port, x0 = 0
module reg_file (
    input             clk,
    input             we,        // write enable
    input      [4:0]  rs1,       // read address 1
    input      [4:0]  rs2,       // read address 2
    input      [4:0]  rd,        // write address
    input      [31:0] wd,        // write data
    output     [31:0] rd1,       // read data 1
    output     [31:0] rd2        // read data 2
);
    reg [31:0] regs [0:31];
    integer i;

    // Initialise all registers to 0 (for simulation)
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    // Write: on clock edge, never write to x0
    always @(posedge clk) begin
        if (we && (rd != 5'b0))
            regs[rd] <= wd;
    end

    // Read: combinational, x0 always returns 0
    assign rd1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign rd2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];
endmodule