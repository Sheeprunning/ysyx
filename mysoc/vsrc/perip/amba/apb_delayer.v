/* verilator lint_off UNUSEDSIGNAL */
`define delay 
module apb_delayer(
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

  output [31:0] out_paddr,
  output        out_psel,
  output        out_penable,
  output [2:0]  out_pprot,
  output        out_pwrite,
  output [31:0] out_pwdata,
  output [3:0]  out_pstrb,
  input         out_pready,
  input  [31:0] out_prdata,
  input         out_pslverr
);
`ifdef delay
  // parameter r = 4.09;//表示主设备1个周期，从设备5.22个周期，为了计算方便,我们可以理解为主设备运行1周期，我们就要多等4.22个周期
  // parameter s = 32;//（r-1）*s=98.88;
  parameter t = 32'd99;
  wire  apb_begin = in_psel && !in_penable;
  wire  apb_finish_t = in_psel && in_penable && out_pready;//存储当前周期的apb ready
  reg   apb_finish_r;//存储上个周期的apb ready
  wire  apb_finish = !apb_finish_r&&apb_finish_t;//上升沿
  wire  wait_finish = (wait_cnt==1)&&wait_time;
  
  reg apb_time,wait_time;//表示正在apb时间
  reg [31:0]counter;
  reg [26:0]wait_cnt;
  reg out_pready_t,out_pslverr_t;
  reg [31:0] out_prdata_t;

  always @(posedge clock) begin
    apb_finish_r<=apb_finish_t;
  end


  //在从设备准备好数据之后先保存，等到延迟时间到了再发送相应数据
  always @(posedge clock or posedge reset)begin
    if(reset)begin
      out_pready_t<=1'b0;
      out_pslverr_t<=1'b0;
      out_prdata_t<=32'b0;
    end
    else if(apb_finish)begin
      out_pslverr_t<=out_pslverr;
      out_prdata_t<=out_prdata;
    end
    else if(wait_finish)
      out_pready_t<=1'b1;
    else
      out_pready_t<=1'b0;
  end

  //apb正常响应时间
  always @(posedge clock or posedge reset) begin
    if(reset)begin
      apb_time<=1'b0;
      counter<=32'b0;
    end
    else begin
      if(apb_begin)begin
        counter<=t;
        apb_time<=1'b1;
      end
      else if(apb_finish)begin
        counter <=32'b0;
        apb_time<=1'b0;
      end
      else if(apb_time)begin
        counter <= counter + t;
      end
    end
  end

  //等待时间
  always @(posedge clock or posedge reset)begin
    if(reset) begin
      wait_cnt<=27'b0;
      wait_time<=0;
    end
    else if(apb_finish)begin
      wait_cnt<=counter[31:5];
      wait_time<=1'b1;
    end
    else if(wait_cnt==0)
      wait_time<=1'b0;
    else if(wait_time)
      wait_cnt<= wait_cnt-27'b1;
  end

  assign out_paddr   = in_paddr;
  assign out_psel    = wait_time?0:in_psel;//延迟等待时间拉低
  assign out_penable = wait_time?0:in_penable;
  assign out_pprot   = in_pprot;
  assign out_pwrite  = in_pwrite;
  assign out_pwdata  = in_pwdata;
  assign out_pstrb   = in_pstrb;
  assign in_pready   = out_pready_t;
  assign in_prdata   = out_prdata_t;
  assign in_pslverr  = out_pslverr_t;

`else
  assign out_paddr   = in_paddr;
  assign out_psel    = in_psel;
  assign out_penable = in_penable;
  assign out_pprot   = in_pprot;
  assign out_pwrite  = in_pwrite;
  assign out_pwdata  = in_pwdata;
  assign out_pstrb   = in_pstrb;
  assign in_pready   = out_pready;
  assign in_prdata   = out_prdata;
  assign in_pslverr  = out_pslverr;
`endif 
endmodule
/* verilator lint_on UNUSEDSIGNAL */
