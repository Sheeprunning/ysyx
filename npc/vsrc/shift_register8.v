module shift_register8(
    input clk,
    input [7:0]din,
    input set,
    input direction,//1是右，0是左
    output reg[7:0]dout,
    output f//标志是否全零
);
reg t;
reg [7:0]cin=0;
always @(posedge clk)begin
    cin<=set?din:dout;
    t<=cin[4]^cin[3]^cin[2]^cin[0];
    dout<=direction?{t,cin[7:1]}:{cin[6:0],t};
    f<=(dout==0)?0:1;
end
endmodule
