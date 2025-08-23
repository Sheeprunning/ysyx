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



ysyx_25080204_CPU CPU(
    .clk(clk),
    .rst(rst),
    .inst(inst),
    .Zero(Zero),
    .Overflow(Overflow),
    .CF(CF),
    .a0(a0),
    .pc(pc)
);
import "DPI-C" function void npc_ebreak_finish();
always @(*)begin
    if(inst==32'h100073)npc_ebreak_finish();
end



endmodule

