module SimReg #(
    parameter WIDTH = 4,
    parameter INIT_VALUE = 0
) (
    input clk,
    input reset,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout,
    input wen
);
 
always @(posedge clk) begin
    if (reset) begin
        dout <= INIT_VALUE;  
    end else if (wen) begin
        dout <= din;         
    end
end
 
endmodule
