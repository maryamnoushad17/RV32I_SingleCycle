// Data Memory: 256 words (1 KB), supports byte/half/word load and store
module data_mem (
    input             clk,
    input             we,          // store enable
    input      [2:0]  funct3,      // size/sign: 000 b, 001 h, 010 w, 100 bu, 101 hu
    input      [31:0] addr,
    input      [31:0] wd,
    output reg [31:0] rd
);
    reg [31:0] mem [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0;
    end

    wire [31:0] word = mem[addr[9:2]];

    // ---------- STORE (sync) ----------
    always @(posedge clk) begin
        if (we) begin
            case (funct3[1:0])
                2'b00: begin // SB
                    case (addr[1:0])
                        2'b00: mem[addr[9:2]][7:0]   <= wd[7:0];
                        2'b01: mem[addr[9:2]][15:8]  <= wd[7:0];
                        2'b10: mem[addr[9:2]][23:16] <= wd[7:0];
                        2'b11: mem[addr[9:2]][31:24] <= wd[7:0];
                    endcase
                end
                2'b01: begin // SH
                    if (addr[1]) mem[addr[9:2]][31:16] <= wd[15:0];
                    else         mem[addr[9:2]][15:0]  <= wd[15:0];
                end
                2'b10: mem[addr[9:2]] <= wd; // SW
                default: ;
            endcase
        end
    end

    // ---------- LOAD (combinational) ----------
    reg [7:0]  b;
    reg [15:0] h;

    always @(*) begin
        // defaults => no latch
        b  = 8'b0;
        h  = 16'b0;
        rd = 32'b0;

        case (addr[1:0])
            2'b00: b = word[7:0];
            2'b01: b = word[15:8];
            2'b10: b = word[23:16];
            2'b11: b = word[31:24];
        endcase
        h = addr[1] ? word[31:16] : word[15:0];

        case (funct3)
            3'b000:  rd = {{24{b[7]}}, b};    // LB
            3'b001:  rd = {{16{h[15]}}, h};   // LH
            3'b010:  rd = word;               // LW
            3'b100:  rd = {24'b0, b};         // LBU
            3'b101:  rd = {16'b0, h};         // LHU
            default: rd = word;
        endcase
    end
endmodule