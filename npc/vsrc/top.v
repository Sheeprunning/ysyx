module top(
    input clk,
    input rstn,
    input ps2_clk,ps2_data,
    output [6:0] seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0,//
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
reg [7:0]key_char;
always@(*)begin
  case (data)
        8'h1C: key_char = "A";  // 8'h41 (ASCII 'A')
        8'h32: key_char = "B";  // 8'h42
        8'h21: key_char = "C";  // 8'h43
        8'h23: key_char = "D";  // 8'h44
        8'h24: key_char = "E";  // 8'h45
        8'h2B: key_char = "F";  // 8'h46
        8'h34: key_char = "G";  // 8'h47
        8'h33: key_char = "H";  // 8'h48
        8'h43: key_char = "I";  // 8'h49
        8'h3B: key_char = "J";  // 8'h4A
        8'h42: key_char = "K";  // 8'h4B
        8'h4B: key_char = "L";  // 8'h4C
        8'h3A: key_char = "M";  // 8'h4D
        8'h31: key_char = "N";  // 8'h4E
        8'h44: key_char = "O";  // 8'h4F
        8'h4D: key_char = "P";  // 8'h50
        8'h15: key_char = "Q";  // 8'h51
        8'h2D: key_char = "R";  // 8'h52
        8'h1B: key_char = "S";  // 8'h53
        8'h2C: key_char = "T";  // 8'h54
        8'h3C: key_char = "U";  // 8'h55
        8'h2A: key_char = "V";  // 8'h56
        8'h1D: key_char = "W";  // 8'h57
        8'h22: key_char = "X";  // 8'h58
        8'h35: key_char = "Y";  // 8'h59
        8'h1A: key_char = "Z";  // 8'h5A
        8'h45: key_char = "0";  // 8'h30
        8'h16: key_char = "1";  // 8'h31
        8'h1E: key_char = "2";  // 8'h32
        8'h26: key_char = "3";  // 8'h33
        8'h25: key_char = "4";  // 8'h34
        8'h2E: key_char = "5";  // 8'h35
        8'h36: key_char = "6";  // 8'h36
        8'h3D: key_char = "7";  // 8'h37
        8'h3E: key_char = "8";  // 8'h38
        8'h46: key_char = "9";  // 8'h39
        8'h29: key_char = " ";  // 空格 (8'h20)
        8'h5A: key_char = 8'h0D;  // 回车 (ASCII CR)
        8'h76: key_char = 8'h1B;  // ESC (ASCII ESC)
        8'h66: key_char = 8'h08;  // Backspace (ASCII BS)
        8'h0D: key_char = 8'h09;  // Tab (ASCII HT)
        // 8'h75: key_char = "Up";   // 非 ASCII，需自定义编码
        // 8'h72: key_char = "Down"; // 非 ASCII，需自定义编码
        // 8'h6B: key_char = "Left"; // 非 ASCII，需自定义编码
        // 8'h74: key_char = "Right";// 非 ASCII，需自定义编码
        // 8'h71: key_char = "Del";  // 非 ASCII，需自定义编码
        8'hF0: key_char = 8'hF0;  // Break 码 (F0)
        default: key_char = 8'h00; // 未知键码
    endcase
end
reg [7:0]count;
always @(posedge clk)begin
    if(rstn==0)begin
        fifo[0] <= 8'h00;
        fifo[1] <= 8'h00;
        fifo[2] <= 8'h00;
        fifo[3] <= 8'h00;
        pre <= 1'b0;
        count<=0;
    end
    else begin
        pre<=ready;
        if(ready&&!pre)begin//上升沿保存数据
            fifo[3] <= fifo[2];
            fifo[2] <= fifo[1];
            fifo[1] <= fifo[0];
            fifo[0] <= data;
        end
        if (data==8'hF0&&ready==1)count<=count+1;
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
bcd7seg bcd7seg4(
    .b(key_char[3:0]),
    .h(seg4)
);
bcd7seg bcd7seg5(
    .b(key_char[7:4]),
    .h(seg5)
);
bcd7seg bcd7seg6(
    .b(count[3:0]),
    .h(seg6)
);
bcd7seg bcd7seg7(
    .b(count[7:4]),
    .h(seg7)
);
assign seg0=h[0];
assign seg1=h[1];
assign seg2=h[2];
assign seg3=h[3];
// assign seg4=h[4];
// assign seg5=h[5];
// assign seg6=h[6];
// assign seg7=h[7];


endmodule
