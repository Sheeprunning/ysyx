module top(
    input clk,
    input rstn,
    input ps2_clk,ps2_data,
    output [6:0] seg3,seg2,seg1,seg0,//seg7,seg6,seg5,seg4,
    output [7:0]data,
    output ready,overflow
);
wire nextdata_n = ~ready;
ps2_keyboard ps2(
    .clk(clk),
    .clrn(rstn),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .data(data),
    .ready(ready),
    .nextdata_n(nextdata_n),
    .overflow(overflow)
    );

reg [7:0]fifo[0:3];//存扫描码
reg pre;
always @(posedge clk)begin
    if(rstn==0)begin
        fifo[0] <= 8'h00;
        fifo[1] <= 8'h00;
        fifo[2] <= 8'h00;
        fifo[3] <= 8'h00;
        pre <= 1'b0;

    end
    else begin
        pre<=ready;
        if(ready&&!pre)begin//上升沿保存数据
            fifo[3] <= fifo[2];
            fifo[2] <= fifo[1];
            fifo[1] <= fifo[0];
            fifo[0] <= data;
        end
    end
end
wire [6:0]h[0:7];
generate
    genvar i;
    for(i=0;i<2;i++)begin:SEG
        bcd7seg bcd7seg1(
            .b(fifo[i][3:0]),
            .h(h[2*i])
        );
        bcd7seg bcd7seg2(
            .b(fifo[i][7:4]),
            .h(h[2*i+1])
        );
    
    end
endgenerate

assign seg0=h[0];
assign seg1=h[1];
assign seg2=h[2];
assign seg3=h[3];
// assign seg4=h[4];
// assign seg5=h[5];
// assign seg6=h[6];
// assign seg7=h[7];


endmodule
