module ysyx_25080204_next_pc (
    input rst,
    input [31:0]pc,
    input bj_en,
    input csr_jen,
    input [31:0]bj_addr,
    input [31:0]csr_npc,
    output reg [31:0]next_pc
);
always @(*) begin
    if (rst)begin
        next_pc=32'h80000000;           
    end
    else begin
        next_pc=bj_en?bj_addr:csr_jen?csr_npc:pc+4;
    end
end
endmodule
