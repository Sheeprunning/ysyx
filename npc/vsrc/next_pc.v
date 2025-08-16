module ysyx_25080204_next_pc (
    input clk,
    input rst,
    input [31:0]pc,
    output reg [31:0]next_pc
);
    always @(*) begin
        if (rst)begin
            next_pc=32'h80000000;           
        end
        else begin
            next_pc=pc+4;
        end
    end
endmodule