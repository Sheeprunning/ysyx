module pri_encode83(
  input  [7:0] x,
  input  en,
  output f,
  output reg [2:0]y
  );
  integer i;
  assign f=(x==8'b0)?1:0;//输入指示位
  always @(*) begin
    if (en) begin
      y = 0;
      for( i = 0; i <= 7; i = i+1)
          if(x[i] == 1)  y = i[2:0];
    end
    else  y = 0;
  end

endmodule
