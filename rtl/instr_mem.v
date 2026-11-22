// Instruction Memory: ROM, 256 words (1 KB)
module instr_mem (
    input  [31:0] addr,     // byte address from PC
    output [31:0] instr
);
    reg [31:0] mem [0:255];
    integer i;

    initial begin
        // fill with NOP (addi x0,x0,0) so unused locations are safe
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'h00000013;
        // load program from hex file
        $readmemh("program.hex", mem);
    end

    // PC counts in bytes (0,4,8..), memory is word-addressed, so drop 2 LSBs
    assign instr = mem[addr[9:2]];
endmodule