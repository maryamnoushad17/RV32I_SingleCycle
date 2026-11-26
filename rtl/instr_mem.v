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

        $readmeh("program.hex", mem);
		  
    end

    // PC byte address hai, memory word hai, isliye addr[1:0] chhod do
    assign instr = mem[addr[9:2]];
endmodule