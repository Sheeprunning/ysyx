module top(
    input clk,
    input rst,
    input [31:0]inst,
    output Zero,
    output Overflow,
    output CF,
    output [31:0]a0,
    output [31:0]pc
);

wire [31:0]rdata;
wire DM_r_en,DM_w_en;
wire [31:0]w_r_addr;
wire [31:0]wdata;
wire [1:0]mem_mask;

ysyx_25080204_CPU CPU(
    .clk(clk),
    .rst(rst),
    .inst(inst),
    .rdata(rdata),
    .Zero(Zero),
    .Overflow(Overflow),
    .CF(CF),
    .DM_r_en(DM_r_en),
    .DM_w_en(DM_w_en),
    .w_r_addr(w_r_addr),
    .wdata(wdata),
    .mem_mask(mem_mask),
    .a0(a0),
    .pc(pc)
);

ysyx_25080204_DataMemory DRAM(
    .clk(clk),
    .rst(rst),
    .DM_r_en(DM_r_en),
    .DM_w_en(DM_w_en),
    .raddr(w_r_addr),
    .waddr(w_r_addr),
    .wdata(wdata),
    .mask(mem_mask),
    .rdata(rdata)
);

import "DPI-C" function void npc_ebreak_finish();
always @(*)begin
    if(inst==32'h100073)begin
        npc_ebreak_finish();
        $display("[CLK %0t]ebreak",$time);
    end
end



endmodule

