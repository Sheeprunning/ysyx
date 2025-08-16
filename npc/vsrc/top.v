module top(
    input clk,
    input rst,
    input [31:0]inst,
    output [31:0]result,
    output [31:0]pc
);
ysyx_25080204_CPU CPU(
    .clk(clk),
    .rst(rst),
    .inst(inst),
    .result(result),
    .pc(pc)
);


endmodule

