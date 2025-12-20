module mux21(
  input   a,
  input b,
  input s,        
  output  y           
);
  assign  y = (~s&a)|(s&b);  // 可以由卡诺图推出

endmodule
