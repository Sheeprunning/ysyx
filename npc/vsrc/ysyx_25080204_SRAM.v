module ysyx_25080204_SRAM(
    input clk,
    input rst,
    input [31:0]pc,
    output reg [31:0]inst
);

import "DPI-C" function int pmem_read_v(input int raddr);

always @(posedge clk or posedge rst) begin
    if(rst)begin
        inst <= 32'h00000013;
    end
    else begin
        inst <= pmem_read_v(pc);
    end
end

import "DPI-C" function void npc_ebreak_finish();
always @(*)begin
    if(inst==32'h100073)begin
        npc_ebreak_finish();
        $display("[CLK %0t]ebreak",$time);
    end
end

endmodule
