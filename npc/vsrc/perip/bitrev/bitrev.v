module bitrev (
  input  sck,
  input  ss,
  input  mosi,
  output miso
);

  parameter [1:0] DATA_I_T = 2'b00, DATA_O_T = 2'b01;
  reg [1:0] state;
  reg [7:0] data_i;
  reg [7:0] data_o;
  reg [7:0] reversed_data;  // 存储反转后的数据
  reg [2:0] counter;
  wire rst = ss;
  
  // miso输出：片选时高阻，输出状态时输出data_o的最高位
  assign miso = ss ? 1'b1 : (state == DATA_O_T ? data_o[7] : 1'b1);

  // 计数器逻辑
  always @(negedge sck or posedge rst) begin
    if (rst) begin
      counter <= 3'd0;
    end else begin
      case (state)
        DATA_I_T: counter <= (counter == 3'd7) ? 3'd0 : counter + 3'd1;
        DATA_O_T: counter <= (counter == 3'd7) ? 3'd0 : counter + 3'd1;
        default: counter <= 3'd0;
      endcase
    end
  end

  // 状态机逻辑
  always @(negedge sck or posedge rst) begin
    if (rst) begin
      state <= DATA_I_T;
    end else begin
      case (state)
        DATA_I_T: begin
          if (counter == 3'd7) begin
            state <= DATA_O_T;
          end
        end
        DATA_O_T: begin
          if (counter == 3'd7) begin
            state <= DATA_I_T;
          end
        end
        default: state <= DATA_I_T;
      endcase
    end
  end

  // 输入数据采集
  always @(negedge sck or posedge rst) begin
    if (rst) begin
      data_i <= 8'b0;
    end else if (state == DATA_I_T) begin
      data_i <= {mosi, data_i[7:1]};
    end
  end

  // 位反转逻辑
  always @(negedge sck) begin
    if (state == DATA_I_T && counter == 3'd7) begin
      // 当接收完8位数据时，进行位反转
      reversed_data[0] <= data_i[7];
      reversed_data[1] <= data_i[6];
      reversed_data[2] <= data_i[5];
      reversed_data[3] <= data_i[4];
      reversed_data[4] <= data_i[3];
      reversed_data[5] <= data_i[2];
      reversed_data[6] <= data_i[1];
      reversed_data[7] <= data_i[0];
    end
  end

  // 输出数据移位
  always @(negedge sck or posedge rst) begin
    if (rst) begin
      data_o <= 8'b0;
    end else begin
      if (state == DATA_I_T && counter == 3'd7) begin
        // 输入完成时加载反转后的数据
        data_o <= reversed_data;
      end else if (state == DATA_O_T) begin
        // 输出时左移
        data_o <= {data_o[6:0], 1'b0};
      end
    end
  end

endmodule