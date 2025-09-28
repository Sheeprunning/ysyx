module ysyx_25080204_1_IFU(
    input clk,
    input rst,
    input stall,
    input bj_en,
    input csr_jen,
    input [31:0]bj_addr,
    input [31:0]csr_j_addr,
    output [31:0]pc,
    output [31:0]next_pc
);
ysyx_25080204_pc PC(
    .next_pc(next_pc),
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .pc(pc)
);

ysyx_25080204_next_pc dnpc(
    .rst(rst),
    .pc(pc),
    .bj_en(bj_en),
    .csr_jen(csr_jen),
    .bj_addr(bj_addr),
    .csr_j_addr(csr_j_addr),
    .next_pc(next_pc)
);

endmodule
