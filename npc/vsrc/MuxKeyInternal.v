module MuxKeyInternal #(NR_KEY = 2, KEY_LEN = 1, DATA_LEN = 1, HAS_DEFAULT = 0) (
  output reg [DATA_LEN-1:0] out,
  input [KEY_LEN-1:0] key,
  input [DATA_LEN-1:0] default_out,//默认输出
  input [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut//类似于字典，存储键值对
);

  localparam PAIR_LEN = KEY_LEN + DATA_LEN;//一个键值对的长度
  wire [PAIR_LEN-1:0] pair_list [NR_KEY-1:0];//键值对列表
  wire [KEY_LEN-1:0] key_list [NR_KEY-1:0];//键列表
  wire [DATA_LEN-1:0] data_list [NR_KEY-1:0];//数据列表

  generate
    for (genvar n = 0; n < NR_KEY; n = n + 1) begin
      assign pair_list[n] = lut[PAIR_LEN*(n+1)-1 : PAIR_LEN*n];
      assign data_list[n] = pair_list[n][DATA_LEN-1:0];
      assign key_list[n]  = pair_list[n][PAIR_LEN-1:DATA_LEN];
    end
  endgenerate

  reg [DATA_LEN-1 : 0] lut_out;
  reg hit;
  integer i;
  always @(*) begin
    lut_out = 0;
    hit = 0;
    for (i = 0; i < NR_KEY; i = i + 1) begin
      lut_out = lut_out | ({DATA_LEN{key == key_list[i]}} & data_list[i]);
      hit = hit | (key == key_list[i]);
    end
    if (!HAS_DEFAULT) out = lut_out;
    else out = (hit ? lut_out : default_out);
  end

endmodule




