// Single-cycle RV32I core: connects all modules
module core_top (
    input clk,
    input rst
);
    wire [31:0] pc, pc_next, pc_plus4, pc_target;
    wire [31:0] instr, imm;
    wire [31:0] rd1, rd2;
    wire [31:0] alu_a, alu_b, alu_result;
    wire [31:0] mem_rd, wb_data;
    wire        zero, branch_taken;

    wire        reg_write, alu_src_b, mem_write, mem_read;
    wire        branch, jump, jalr;
    wire [1:0]  alu_src_a, wb_sel;
    wire [3:0]  alu_ctrl;

    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    // FETCH
    pc u_pc (.clk(clk), .rst(rst), .pc_next(pc_next), .pc(pc));
    instr_mem u_imem (.addr(pc), .instr(instr));
    assign pc_plus4 = pc + 32'd4;

    // DECODE
    control u_ctrl (
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .reg_write(reg_write), .alu_src_a(alu_src_a), .alu_src_b(alu_src_b),
        .mem_write(mem_write), .mem_read(mem_read), .wb_sel(wb_sel),
        .branch(branch), .jump(jump), .jalr(jalr), .alu_ctrl(alu_ctrl));

    imm_gen u_imm (.instr(instr), .imm(imm));

    reg_file u_rf (
        .clk(clk), .we(reg_write), .rs1(rs1), .rs2(rs2),
        .rd(rd), .wd(wb_data), .rd1(rd1), .rd2(rd2));

    // EXECUTE
    mux3 #(32) u_mux_a (.a(rd1), .b(pc), .c(32'b0), .sel(alu_src_a), .y(alu_a));
    mux2 #(32) u_mux_b (.a(rd2), .b(imm), .sel(alu_src_b), .y(alu_b));
    alu u_alu (.a(alu_a), .b(alu_b), .alu_ctrl(alu_ctrl),
               .result(alu_result), .zero(zero));

    branch_logic u_br (.rs1_val(rd1), .rs2_val(rd2), .funct3(funct3),
                       .branch(branch), .branch_taken(branch_taken));

    // MEMORY
    data_mem u_dmem (.clk(clk), .we(mem_write), .funct3(funct3),
                     .addr(alu_result), .wd(rd2), .rd(mem_rd));

    // WRITE-BACK
    mux3 #(32) u_mux_wb (.a(alu_result), .b(mem_rd), .c(pc_plus4),
                         .sel(wb_sel), .y(wb_data));

    // NEXT PC
    assign pc_target = pc + imm;
    assign pc_next = jalr ? {alu_result[31:1], 1'b0} :
                     (jump | branch_taken) ? pc_target :
                     pc_plus4;
endmodule