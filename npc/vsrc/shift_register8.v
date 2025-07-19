module shift_register8(
    input clk,
    input [7:0]din,
    input set,
    input direction,//1是右，0是左
    output reg[7:0]dout,
    output f//标志是否全零
);
reg t;

always @(posedge clk)begin
    if(set)begin
      dout<=din;
      t<=din[4]^din[3]^din[2]^din[0];
    end
    else begin
        t<=dout[4]^dout[3]^dout[2]^dout[0];
        dout<=direction?{t,dout[7:1]}:{dout[6:0],t};
        
    end
end

assign f=(dout==0)?0:1;
endmodule
