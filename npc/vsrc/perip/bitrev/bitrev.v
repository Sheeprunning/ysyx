module bitrev (
  input  sck,
  input  ss,
  input  mosi,
  output miso
);

  reg [7:0] input_shift;
  reg [7:0] output_shift;
  reg [7:0] reversed_data;
  reg [3:0] bit_cnt;
  reg data_ready;
  
  wire rst = ss;
  
  // miso输出：直接输出output_shift的最高位
  assign miso = data_ready?output_shift[7]:1'b1;

  always @(posedge sck or posedge rst) begin
    if (rst) begin
      input_shift <= 8'b0;
      output_shift <= 8'b0;
      reversed_data <= 8'b0;
      bit_cnt <= 4'b0;
      data_ready <= 1'b0;
    end else begin
      // 输入采样
      input_shift <= {input_shift[6:0], mosi};
      bit_cnt <= bit_cnt + 4'b1;
      
      if (bit_cnt == 4'd7) begin
        // 接收完8位，立即进行位反转
        reversed_data <= {input_shift[0], input_shift[1], input_shift[2], input_shift[3],
                         input_shift[4], input_shift[5], input_shift[6], mosi};
        data_ready <= 1'b1;
      end else if (bit_cnt == 4'd15) begin
        // 16位传输结束，重置
        bit_cnt <= 4'b0;
        data_ready <= 1'b0;
      end
    end
  end

  always @(negedge sck or posedge rst) begin
    if (rst) begin
      output_shift <= 8'b0;
    end else begin
      if (data_ready) begin
        // 有数据时输出反转后的数据
        if (bit_cnt == 4'd7) begin
          // 第一次输出时加载完整反转数据
          output_shift <= reversed_data;
        end else begin
          // 后续输出移位
          output_shift <= {output_shift[6:0], 1'b0};
        end
      end else begin
        // 无数据时输出0或其他默认值
        output_shift <= 8'b1;
      end
    end
  end

endmodule