module ysyx_25080204_pc (
    input [31:0] next_pc,
    input clk,
    input rst,
    input stall,
    output reg [31:0]pc
);
    
    always @(posedge clk or posedge rst) begin
        if (rst)begin
            pc<=32'h20000000; 
        end
        else if(!stall)begin
            //$display("[CLK %0t]EXCUTE:pc:0x%08x next_pc:0x%08x", $time,pc,next_pc);
                pc<=next_pc;   
            end
                       
    end
endmodule
