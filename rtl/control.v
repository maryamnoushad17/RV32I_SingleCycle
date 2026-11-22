// Control Unit: generates control signals from opcode/funct3/funct7
module control (
    input      [6:0] opcode,
    input      [2:0] funct3,
    input      [6:0] funct7,
    output reg       reg_write,
    output reg [1:0] alu_src_a,   // 00 rs1, 01 PC, 10 zero
    output reg       alu_src_b,   // 0 rs2, 1 imm
    output reg       mem_write,
    output reg       mem_read,
    output reg [1:0] wb_sel,      // 00 ALU, 01 MEM, 10 PC+4
    output reg       branch,
    output reg       jump,
    output reg       jalr,
    output reg [3:0] alu_ctrl
);
    always @(*) begin
        // ---- defaults (prevent latches) ----
        reg_write = 1'b0;
        alu_src_a = 2'b00;
        alu_src_b = 1'b0;
        mem_write = 1'b0;
        mem_read  = 1'b0;
        wb_sel    = 2'b00;
        branch    = 1'b0;
        jump      = 1'b0;
        jalr      = 1'b0;
        alu_ctrl  = 4'b0000;

        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl = funct7[5] ? 4'b0001 : 4'b0000; // SUB / ADD
                    3'b001: alu_ctrl = 4'b0101; // SLL
                    3'b010: alu_ctrl = 4'b1000; // SLT
                    3'b011: alu_ctrl = 4'b1001; // SLTU
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    3'b101: alu_ctrl = funct7[5] ? 4'b0111 : 4'b0110; // SRA / SRL
                    3'b110: alu_ctrl = 4'b0011; // OR
                    3'b111: alu_ctrl = 4'b0010; // AND
                endcase
            end

            7'b0010011: begin // I-type ALU
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000; // ADDI
                    3'b001: alu_ctrl = 4'b0101; // SLLI
                    3'b010: alu_ctrl = 4'b1000; // SLTI
                    3'b011: alu_ctrl = 4'b1001; // SLTIU
                    3'b100: alu_ctrl = 4'b0100; // XORI
                    3'b101: alu_ctrl = funct7[5] ? 4'b0111 : 4'b0110; // SRAI / SRLI
                    3'b110: alu_ctrl = 4'b0011; // ORI
                    3'b111: alu_ctrl = 4'b0010; // ANDI
                endcase
            end

            7'b0000011: begin // Load
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                mem_read  = 1'b1;
                wb_sel    = 2'b01;
                alu_ctrl  = 4'b0000; // address = rs1 + imm
            end

            7'b0100011: begin // Store
                alu_src_b = 1'b1;
                mem_write = 1'b1;
                alu_ctrl  = 4'b0000; // address = rs1 + imm
            end

            7'b1100011: begin // Branch
                branch   = 1'b1;
                alu_ctrl = 4'b0001; // SUB (decision made in branch_logic)
            end

            7'b1101111: begin // JAL
                reg_write = 1'b1;
                alu_src_a = 2'b01; // PC
                alu_src_b = 1'b1;  // imm
                wb_sel    = 2'b10; // PC+4
                jump      = 1'b1;
                alu_ctrl  = 4'b0000; // target = PC + imm
            end

            7'b1100111: begin // JALR
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                wb_sel    = 2'b10; // PC+4
                jalr      = 1'b1;
                alu_ctrl  = 4'b0000; // target = rs1 + imm
            end

            7'b0110111: begin // LUI
                reg_write = 1'b1;
                alu_src_a = 2'b10; // zero
                alu_src_b = 1'b1;
                alu_ctrl  = 4'b0000; // 0 + imm
            end

            7'b0010111: begin // AUIPC
                reg_write = 1'b1;
                alu_src_a = 2'b01; // PC
                alu_src_b = 1'b1;
                alu_ctrl  = 4'b0000; // PC + imm
            end

            default: ; // keep defaults
        endcase
    end
endmodule