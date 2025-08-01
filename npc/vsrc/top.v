module top(
    input clk,
    input set,dir,
    input [7:0]din,
    output [6:0] seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0,//
    output f
);
wire [7:0]dout;
shift_register8 SR(
    .clk(clk),
    .din(din),
    .set(set),
    .direction(dir),//1是右，0是左
    .dout(dout),
    .f(f)//标志是否全零
);

wire [6:0]h[0:7];
generate
    genvar i;
    for(i=0;i<8;i++)begin:SEG
        bcd7seg bcd7seg1(
            .b({3'b0,dout[i]}),
            .h(h[i])
        );
    end
endgenerate

assign seg0=h[0];
assign seg1=h[1];
assign seg2=h[2];
assign seg3=h[3];
assign seg4=h[4];
assign seg5=h[5];
assign seg6=h[6];
assign seg7=h[7];


endmodule

