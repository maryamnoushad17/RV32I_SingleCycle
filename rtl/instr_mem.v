module instr_mem (
    input  wire [31:0] addr,     // PC se aata hai (byte address)
    output wire [31:0] instr     // 32-bit instruction
);
    reg [31:0] mem [0:255];      // 256 words = 1 KB
    integer i;

    initial begin
        // pehle sab jagah NOP (addi x0,x0,0)
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'h00000013;

        // program
        mem[0] = 32'h00500093;   // addi x1, x0, 5
        mem[1] = 32'h00A00113;   // addi x2, x0, 10
        mem[2] = 32'h002081B3;   // add  x3, x1, x2
        mem[3] = 32'h00302023;   // sw   x3, 0(x0)
        mem[4] = 32'h00002203;   // lw   x4, 0(x0)
        mem[5] = 32'h00000063;   // beq  x0, x0, 0 (yahin ruk jao)
    end

    // PC byte address hai, memory word hai, isliye addr[1:0] chhod do
    assign instr = mem[addr[9:2]];
endmodule