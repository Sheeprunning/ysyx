// module bcd7seg(
//   input  [3:0] b,
//   output reg [6:0] h
// );
// localparam [6:0] SEG_TABLE [0:15]={
//     7'b011_1111, // 0
//     7'b000_0110, // 1
//     7'b101_1011, // 2
//     7'b100_1111, // 3
//     7'b110_0110, // 4
//     7'b110_1101, // 5
//     7'b111_1101, // 6
//     7'b000_0111, // 7
//     7'b111_1111, // 8
//     7'b110_1111,  // 9  
//         // 大写字母A-Z (有些字母在7段显示中看起来相似)
//     7'b111_0111, // A
//     7'b111_1100, // b
//     7'b011_1001, // C
//     7'b101_1110, // d
//     7'b111_1001, // E
//     7'b111_0001 // F
//     // 7'b011_1101, // G
//     // 7'b111_0110, // H
//     // 7'b011_0110, // I (或7'b000_0110同1)
//     // 7'b000_1111, // J
//     // 7'b011_1000, // K (可能显示类似H)
//     // 7'b011_1000, // L (同K)
//     // 7'b011_0111, // M (可能显示类似N)
//     // 7'b101_0100, // n
//     // 7'b101_1100, // o
//     // 7'b111_0011, // P
//     // 7'b110_0111, // q
//     // 7'b101_0000, // r
//     // 7'b110_1101, // S (同5)
//     // 7'b111_1000, // t
//     // 7'b011_1110, // U
//     // 7'b011_1110, // V (同U)
//     // 7'b011_1110, // W (同U)
//     // 7'b111_0110, // X (同H)
//     // 7'b110_1110, // y
//     // 7'b101_1011  // Z (同2)
// };//数字对应的数码管

// always @(*)begin
//   h=~SEG_TABLE[b];//?nvboard的seg是低电平驱动？
// end
    

// endmodule
//上面的参数用了多位数组，在评估电路时用不了，让ai改写了一下
module bcd7seg(
  input  [3:0] b,
  output reg [6:0] h
);

// 将多维数组改为单独的localparam定义
localparam [6:0] SEG_0  = 7'b0111111; // 0
localparam [6:0] SEG_1  = 7'b0000110; // 1
localparam [6:0] SEG_2  = 7'b1011011; // 2
localparam [6:0] SEG_3  = 7'b1001111; // 3
localparam [6:0] SEG_4  = 7'b1100110; // 4
localparam [6:0] SEG_5  = 7'b1101101; // 5
localparam [6:0] SEG_6  = 7'b1111101; // 6
localparam [6:0] SEG_7  = 7'b0000111; // 7
localparam [6:0] SEG_8  = 7'b1111111; // 8
localparam [6:0] SEG_9  = 7'b1101111; // 9
localparam [6:0] SEG_A  = 7'b1110111; // A
localparam [6:0] SEG_B  = 7'b1111100; // b
localparam [6:0] SEG_C  = 7'b0111001; // C
localparam [6:0] SEG_D  = 7'b1011110; // d
localparam [6:0] SEG_E  = 7'b1111001; // E
localparam [6:0] SEG_F  = 7'b1110001; // F

always @(*) begin
  // 使用case语句代替数组索引
  case(b)
    4'h0: h = ~SEG_0;
    4'h1: h = ~SEG_1;
    4'h2: h = ~SEG_2;
    4'h3: h = ~SEG_3;
    4'h4: h = ~SEG_4;
    4'h5: h = ~SEG_5;
    4'h6: h = ~SEG_6;
    4'h7: h = ~SEG_7;
    4'h8: h = ~SEG_8;
    4'h9: h = ~SEG_9;
    4'hA: h = ~SEG_A;
    4'hB: h = ~SEG_B;
    4'hC: h = ~SEG_C;
    4'hD: h = ~SEG_D;
    4'hE: h = ~SEG_E;
    4'hF: h = ~SEG_F;
    default: h = 7'b0000000;
  endcase
end

endmodule
