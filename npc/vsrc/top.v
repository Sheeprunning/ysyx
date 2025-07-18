module top(
    input [7:0] in,
    input en,
    output f,
    output [2:0]y,
    output [6:0]seg
);

pri_encode83 e83(
  .x(in),
  .en(en),
  .f(f),
  .y(y)
  );
wire [3:0]b={1'b0,y};
  bcd7seg s(
    .b(b),
    .h(seg)
  );
endmodule
