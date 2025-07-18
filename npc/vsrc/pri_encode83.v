module pri_encode83(
  input  [7:0] x,
  input  en,
  output f,
  output reg [2:0]y
  );
  assign f=(x != 8'b0) && en;//输入指示位
  always @(*) begin
    casez(x)
        8'b1???????: y = 7;
        8'b01??????: y = 6;
        8'b001?????: y = 5;
        8'b0001????: y = 4;
        8'b00001???: y = 3;
        8'b000001??: y = 2;
        8'b0000001?: y = 1;
        8'b00000001: y = 0;
        default:  y = 0;
    endcase
    
  end

endmodule
