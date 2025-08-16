module ysyx_25080204_pc (
    input [31:0] next_pc,
    input clk,
    input rst,
    output reg [31:0]pc,
);
    
    
    always @(posedge clk or posedge rst) begin
        if (rst)begin
            pc<=32'h80000000;       
        end
        else begin
            pc<=next_pc;     
        end            
    end
endmodule