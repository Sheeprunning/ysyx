module ysyx_25080204_pc (
    input [31:0] next_pc,
    input clk,
    input rst,
    input stall,
    output reg [31:0]pc
);
    
    reg pc_stall;
    always @(posedge clk or posedge rst) begin
        if (rst)begin
            pc<=32'h20000000; 
            pc_stall<=1'b1;     //每个周期取指肯定有延迟，pc变成next默认先保持一周期 
        end
        else if(!stall)begin
            if(pc_stall)pc_stall<=1'b0;//第一个周期暂停pc，等待
            else begin
            $display("[CLK %0t]EXCUTE:pc:0x%08x next_pc:0x%08x", $time,pc,next_pc);
                pc<=next_pc;   
                //pc_stall<=1'b1; 
            end
            
        end            
    end
endmodule
