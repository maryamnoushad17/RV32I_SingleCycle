// Branch logic: compares rs1 and rs2, decides if branch is taken
module branch_logic (
    input  [31:0] rs1_val,
    input  [31:0] rs2_val,
    input  [2:0]  funct3,
    input         branch,        // 1 if instruction is a branch
    output reg    branch_taken
);
    reg cond;

    always @(*) begin
        cond = 1'b0;  // default => no latch
        case (funct3)
            3'b000:  cond = (rs1_val == rs2_val);                    // BEQ
            3'b001:  cond = (rs1_val != rs2_val);                    // BNE
            3'b100:  cond = ($signed(rs1_val) <  $signed(rs2_val));  // BLT
            3'b101:  cond = ($signed(rs1_val) >= $signed(rs2_val));  // BGE
            3'b110:  cond = (rs1_val <  rs2_val);                    // BLTU
            3'b111:  cond = (rs1_val >= rs2_val);                    // BGEU
            default: cond = 1'b0;
        endcase
        branch_taken = branch & cond;
    end
endmodule