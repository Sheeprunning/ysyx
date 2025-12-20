module vga_top_apb(
  input         clock,
  input         reset,
  input  [31:0] in_paddr,
  input         in_psel,
  input         in_penable,
  input  [2:0]  in_pprot,
  input         in_pwrite,
  input  [31:0] in_pwdata,
  input  [3:0]  in_pstrb,
  output        in_pready,
  output [31:0] in_prdata,
  output        in_pslverr,

  output [7:0]  vga_r,
  output [7:0]  vga_g,
  output [7:0]  vga_b,
  output        vga_hsync,
  output        vga_vsync,
  output        vga_valid
);

  import "DPI-C" function void vga_read(input int addr,output int rdata);
  import "DPI-C" function void vga_write(input int addr,input int wdata);
  //帧缓冲写
  wire req_accept = (in_psel && in_penable);
  wire is_read  = req_accept && !in_pwrite;
  wire is_write = req_accept &&  in_pwrite;

  assign in_pready=1'b1;
  assign in_pslverr = 1'b0;

  always @(posedge reset or posedge clock) begin
    if (reset != 1'b1&&is_write)
        vga_write(in_paddr,in_pwdata);
  end

//640x480分辨率下的VGA参数设置
  parameter    h_frontporch = 96;
  parameter    h_active = 144;
  parameter    h_backporch = 784;
  parameter    h_total = 800;

  parameter    v_frontporch = 2;
  parameter    v_active = 35;
  parameter    v_backporch = 515;
  parameter    v_total = 525;

  //像素计数值
  reg [9:0]    x_cnt;
  reg [9:0]    y_cnt;
  reg [31:0]   vga_rdata;
  wire         h_valid;
  wire         v_valid;
  wire [9:0]   v_addr;
  wire [9:0]   h_addr;


  always @(posedge reset or posedge clock) //行像素计数
      if (reset == 1'b1)
        x_cnt <= 1;
      else
      begin
        if (x_cnt == h_total)
            x_cnt <= 1;
        else
            x_cnt <= x_cnt + 10'd1;
      end

  always @(posedge clock)  //列像素计数
      if (reset == 1'b1)
        y_cnt <= 1;
      else
      begin
        if (y_cnt == v_total & x_cnt == h_total)
            y_cnt <= 1;
        else if (x_cnt == h_total)
            y_cnt <= y_cnt + 10'd1;
      end

  
  wire [18:0] v_times_512 = {v_addr[8:0], 9'b0};  // v_addr * 512
  wire [18:0] v_times_128 = {v_addr[8:0], 7'b0};  // v_addr * 128  
  wire [18:0] pixel_addr = h_addr + v_times_512 + v_times_128;
  always @(posedge clock) begin
    vga_read({pixel_addr,2'b0},vga_rdata);
  end

  //生成同步信号
  assign vga_hsync = (x_cnt > h_frontporch);
  assign vga_vsync = (y_cnt > v_frontporch);
  //生成消隐信号
  assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
  assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
  assign vga_valid = h_valid & v_valid;
  //计算当前有效像素坐标
  assign h_addr = h_valid ? (x_cnt - 10'd145) : {10{1'b0}};
  assign v_addr = v_valid ? (y_cnt - 10'd36) : {10{1'b0}};
  //设置输出的颜色值
  assign vga_r = vga_rdata[23:16];
  assign vga_g = vga_rdata[15:8];
  assign vga_b = vga_rdata[7:0];

endmodule
