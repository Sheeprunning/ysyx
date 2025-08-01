module top(
  input  [7:0] x,
  input  en,
  output f,
  output reg [2:0]y,
  output [6:0]seg
);
pri_encode83 PE(
  .x(x),
  .en(en),
  .f(f),
  .y(y)
  );

// wire [6:0]h[0:7];
// generate
//     genvar i;
//     for(i=0;i<8;i++)begin:SEG
//         bcd7seg bcd7seg1(
//             .b({3'b0,dout[i]}),
//             .h(h[i])
//         );
//     end
// endgenerate

// assign seg0=h[0];
// assign seg1=h[1];
// assign seg2=h[2];
// assign seg3=h[3];
// assign seg4=h[4];
// assign seg5=h[5];
// assign seg6=h[6];
// assign seg7=h[7];
bcd7seg bcd7seg1(
    .b({1'b0,y}),
    .h(seg)
);
endmodule

