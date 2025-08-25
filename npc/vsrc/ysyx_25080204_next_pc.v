module ysyx_25080204_next_pc (
    input clk,
    input rst,
    input [31:0]pc,
    input bj_en,
    input [31:0]bj_addr,
    output reg [31:0]next_pc
);
    always @(posedge clk or posedge rst) begin
        if (rst)begin
            next_pc<=32'h80000000;           
        end
        else begin
            next_pc<=bj_en?bj_addr:pc+4;
        end
    end
endmodule
