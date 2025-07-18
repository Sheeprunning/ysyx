module bcd7seg(
  input  [3:0] b,
  output reg [6:0] h
);
localparam [6:0] SEG_TABLE [0:9]={
    7'b0011_1111, // 0
    7'b0000_0110, // 1
    7'b0101_1011, // 2
    7'b0100_1111, // 3
    7'b0110_0110, // 4
    7'b0110_1101, // 5
    7'b0111_1101, // 6
    7'b0000_0111, // 7
    7'b0111_1111, // 8
    7'b0110_1111  // 9  
};//数字对应的数码管

always @(*)begin
  h=SEG_TABLE[b];
end
    

endmodule
