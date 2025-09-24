module ysyx_25080204_DataMemory(
    input clk,
    input rst,
    
    input [31:0]araddr,//读的地址
    input arvalid,//读地址有效
    output arready,//准备就绪读
 
    output reg [31:0]rdata,
    output [1:0]rresp,//读数据是正确
    output rvalid,//已经读出数据
    input rready,//准备就绪接收

    input [31:0]awaddr,
    input awvalid,//写地址有效
    output awready//准备就绪获取写地址

    input [31:0]wdata,
    input [1:0]wstrb,//掩码
    input wvalid,//写数据有效
    output wready,//准备就系获取写数据

    output [1:0]bresp,//是否写成功
    output bvalid,//已经写完
    input bready//准备就绪获取是否成功写入
    
);

localparam R_READY=2'b00;
localparam R_BUSY = 2'b01;

localparam W_READY=2'b00;
localparam W_BUSY = 2'b01;


import "DPI-C" function int pmem_read_v(input int raddr);
import "DPI-C" function void pmem_write_v(
  input int waddr_t, input int len , input int wdata );

reg [31:0] waddr_t,wdata_t;
reg [31:0] len,len_t;
reg write_ready;
reg [1:0]r_state,w_state;


always @(*)begin
    case(wstrb)
        2'b00:len=1;
        2'b01:len=2;
        2'b10:len=4;
        default:len=0;
    endcase
end

always @(*) begin
    if (DM_r_en&&raddr>32'h80000000 && raddr<32'h88000000) begin // 有读请求时
         //$display("[CLK %0t] READ: DM[%0x]", $time, raddr);
        rdata = pmem_read_v(raddr);
    end
    else begin
        rdata = 32'hdeaddddd;
    end
end

always @(posedge clk or posedge rst)begin
  if(rst)begin
    arready<=1;
    rdata<=0;
    rresp<=2'b0;
    rvalid<=0;

    awready<=1;
    bresp<=0;
    bvalid<=0;

    state<=READY;
  end
  else begin
    case(state)
      READY:begin
        if()
      end
    endcase
  end

end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        write_ready <= 0;
        waddr_t <= 0;
        wdata_t <= 0;
        len_t <= 0;
    end else begin
        write_ready <= DM_w_en;
        if (DM_w_en) begin
            waddr_t <= waddr;
            wdata_t <= wdata;
            len_t <= len;
        end
        
    end
end
always@(*)begin
  if(write_ready)begin
            pmem_write_v(waddr_t, len_t, wdata_t);
            //$display("[CLK %0t] Write: DM[%0x] = 0x%08x ", $time, waddr_t, wdata_t);
        end
end
endmodule

