module ysyx_25080204_DataMemory(
    input clk,
    input rst,
    
    input [31:0]araddr,//读的地址
    input arvalid,//读地址有效
    output reg arready,//准备就绪读
 
    output reg [31:0]rdata,
    output reg [1:0]rresp,//读数据是正确
    output reg rvalid,//已经读出数据
    input rready,//准备就绪接收

    input [31:0]awaddr,
    input awvalid,//写地址有效
    output reg awready,//准备就绪获取写地址

    input [31:0]wdata,
    input [1:0]wstrb,//掩码
    input wvalid,//写数据有效
    output reg wready,//准备就系获取写数据

    output reg [1:0]bresp,//是否写成功
    output reg bvalid,//已经写完
    input bready//准备就绪获取是否成功写入
    
);

localparam R_READY= 2'b00;
localparam R_BUSY = 2'b01;

localparam W_READY= 2'b00;
localparam W_ADDR = 2'b01;
localparam W_DATA = 2'b10;
localparam W_BRESP = 2'b11;


import "DPI-C" function int pmem_read_v(input int raddr);
import "DPI-C" function void pmem_write_v(
  input int awaddr_t, input int len , input int wdata );

reg [31:0] awaddr_t,wdata_t;
reg [31:0] len_t;
reg [1:0]wstrb_t;
reg [1:0]r_state,w_state;

reg write_ready;

//读通道

always @(posedge clk or posedge rst)begin
  if(rst)begin
    arready<=1;
    rdata<=0;
    rresp<=2'b0;
    rvalid<=0;

    r_state<=R_READY;
  end
  else begin
    case(r_state)
        R_READY:begin
        // $display("[CLK %0t]MEMERY STATE:R_READY ", $time);
            if(arready&&arvalid)begin//读地址握手成功
                arready<=1'b0;//取消读就绪
                rresp<={1'b0,~(araddr>32'h80000000 && araddr<32'h88000000)};
                rdata<=pmem_read_v(araddr);
                rvalid<=1'b1;
                r_state<=R_BUSY;
            end
        end
        R_BUSY:begin
            // $display("[CLK %0t]MEMERY STATE:R_BUSY ", $time);
            if(rvalid&&rready)begin
                arready<=1'b1;
                rvalid<=1'b0;
                rresp<=2'b0;
                r_state<=R_READY;
            end
        end
        default:begin end
    endcase
  end

end

//写通道

always @(posedge clk or posedge rst)begin
  if(rst)begin
    write_ready<=0;

    awready<=1; 
    wready<=1'b0;
    bresp<=0;
    bvalid<=0;

    w_state<=W_READY;
  end
  else begin
    case(w_state)
        W_READY:begin
            if(awready&&awvalid)begin//读入写地址握手成功
                //$display("[CLK %0t]MEMERY awaddr=0x%08x handshake with CPU !", $time ,awaddr);
                awready<=1'b0;//取消就绪
                wready<=1'b1;
                awaddr_t<=awaddr;
                w_state<=W_ADDR;
            end
        end
        W_ADDR:begin//也可以尝试直接写入数据
            if(wready&&wvalid)begin//读数据握手成功
                //$display("[CLK %0t]MEMERY wdata=0x%08x handshake with CPU !", $time,wdata);
                wready<=1'b0;//取消就绪
                wstrb_t<=wstrb;
                wdata_t<=wdata;
                w_state<=W_DATA;
            end
        end
        W_DATA:begin
            write_ready<=1'b1;
            bresp<={1'b0,~(awaddr_t>32'h80000000 && awaddr_t<32'h88000000)};
            bvalid<=1'b1;
            w_state<=W_BRESP;
        end
              
        W_BRESP:begin
            if(bvalid&&bready)begin
                //$display("[CLK %0t]MEMERY bresp handshake with CPU !", $time);
                write_ready<=1'b0;
                awready<=1'b1;
                wready<=1'b0;
                bvalid<=1'b0;
                bresp<=0;
                w_state<=W_READY;
            end
        end
    endcase
  end

end

// always @(posedge clk or posedge rst) begin
//     if (rst) begin
//         write_ready <= 0;
//         awaddr_t <= 0;
//         wdata_t <= 0;
//         len_t <= 0;
//     end else begin
//         write_ready <= DM_w_en;
//         if (DM_w_en) begin
//             awaddr_t <= waddr;
//             wdata_t <= wdata;
//             len_t <= len;
//         end
        
//     end
// end

always @(*)begin
  case (wstrb_t)
    2'b00:len_t=1;
    2'b01:len_t=2;
    2'b10:len_t=4;
    default:len_t=0;
  endcase
end

always@(*)begin
  if(write_ready)begin
            //$display("[CLK %0t] Write: DM[%0x] = 0x%08x ", $time, awaddr_t, wdata_t);
            pmem_write_v(awaddr_t, len_t, wdata_t);
        end
end
endmodule

