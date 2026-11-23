module pc (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc_out,
    output wire [31:0] pc_plus4
);
    assign pc_plus4 = pc_out + 32'd4;

    always @(posedge clk) begin
        if (rst) pc_out <= 32'd0;
        else     pc_out <= pc_next;
    end
endmodule