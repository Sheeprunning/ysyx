module ysyx_25080204_1_IFU(
    input clk,
    input rst,
    input stall,
    input [31:0]next_pc,
    output [31:0]pc
    
);
ysyx_25080204_pc PC(
    .next_pc(next_pc),
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .pc(pc)
);



endmodule
