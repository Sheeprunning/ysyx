module ysyx_25080204_3_EXE(
    input clk,
    input rst,
    input stall,
    //ALU's signal
    input  [3:0]alu_op,
    input  [31:0]A,B,
    output [31:0]result,
    // output  Zero,
    // output  Overflow,
    // output  CF,
    //CSR's signal
    input CSR_wen,
    input en_ecall,
    input en_mret,
    input [2:0]csr_op,
    input [31:0]pc,
    input [1:0]cur_pri,//当前特权级
    input [31:0]CSR_raddr,
    input [31:0]CSR_waddr,
    input [31:0]CSR_wdata,
    output [31:0]CSR_rdata,
    //next_pc
    input bj_en,
    input csr_jen,
    input [31:0]bj_addr,
    output [31:0]next_pc
);

wire [31:0]snpc=pc+4;
ysyx_25080204_ALU ALU(
    .opcode(alu_op),
    .A(A),
    .B(B),
    .result(result)
);
wire [31:0]csr_j_addr;
ysyx_25080204_CSR CSR(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .wen(CSR_wen),
    .en_ecall(en_ecall),
    .en_mret(en_mret),
    .csr_op(csr_op),
    .pc(pc),
    .cur_pri(cur_pri),//当前特权级
    .raddr(CSR_raddr),
    .waddr(CSR_waddr),
    .wdata(CSR_wdata),
    .rdata(CSR_rdata),
    .next_pc(csr_j_addr)
);

ysyx_25080204_next_pc dnpc(
    .rst(rst),
    .snpc(snpc),
    .bj_en(bj_en),
    .csr_jen(csr_jen),
    .bj_addr(bj_addr),
    .csr_j_addr(csr_j_addr),
    .next_pc(next_pc)
);
endmodule
