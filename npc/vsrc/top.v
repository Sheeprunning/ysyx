module top(
    input clk,
    input rst,
    input [31:0]inst,
    output [31:0]result,
    output Zero,
    output Overflow,
    output CF,
    output [31:0]a0,
    output [31:0]pc
);

import "DPI-C" function void npc_ebreak_finish();

ysyx_25080204_CPU CPU(
    .clk(clk),
    .rst(rst),
    .inst(inst),
    .result(result),
    .Zero(Zero),
    .Overflow(Overflow),
    .CF(CF),
    .a0(a0),
    .pc(pc)
);

always @(*)begin
    if(inst==32'h100073)npc_ebreak_finish();
end
endmodule

