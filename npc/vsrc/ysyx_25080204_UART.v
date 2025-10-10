module ysyx_25080204_UART(
    input clk,
    input rst,
/* verilator lint_off UNUSEDSIGNAL */
    input [31:0]araddr,//读的地址
    input arvalid,//读地址有效
    output reg arready,//准备就绪读
 
    output reg [31:0]rdata,
    output reg [1:0]rresp,//读数据是正确
    output reg rvalid,//已经读出数据
    input rready,//准备就绪接收
/* verilator lint_on UNUSEDSIGNAL */
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

localparam U_READY= 2'b00;
localparam U_ADDR = 2'b01;
localparam U_DATA = 2'b10;
localparam U_BRESP = 2'b11;

localparam R_READY= 2'b00;
localparam R_BUSY = 2'b01;
/* verilator lint_off UNUSEDSIGNAL */
reg [31:0] awaddr_t,wdata_t;
reg [1:0]  wstrb_t;
/* verilator lint_on UNUSEDSIGNAL */

//仅具有写功能
reg [1:0]  u_state,r_state;

always @(posedge clk or posedge rst)begin
  if(rst)begin
    awready<=1'b1; 
    wready<=1'b0;
    bresp<=0;
    bvalid<=0;

    u_state<=U_READY;
  end
  else begin
    case(u_state)
        U_READY:begin
        // $display("[CLK %0t]WRITE STATE:U_READY ", $time);
            if(awready&&awvalid)begin//读入写地址握手成功
                //$display("[CLK %0t]UART awaddr=0x%08x handshake with CPU !", $time ,awaddr);
                awready<=1'b0;//取消就绪
                wready<=1'b1;
                awaddr_t<=awaddr;
                u_state<=U_ADDR;
            end
        end
        U_ADDR:begin//也可以尝试直接写入数据
        // $display("[CLK %0t]WRITE STATE:U_ADDR ", $time);
            if(wready&&wvalid)begin//写数据握手成功
      // $display("[CLK %0t]MEMERY wdata:0x%08x to addr:0x%08x handshake with CPU !", $time,wdata,awaddr_t);
                wready<=1'b0;//取消就绪
                wstrb_t<=wstrb;
                wdata_t<=wdata;
                u_state<=U_DATA;
            end
        end
        U_DATA:begin
        // $display("[CLK %0t]WRITE STATE:U_DATA ", $time);
            bresp<=(awaddr_t == 32'ha00003f8) ? 2'b00 : 2'b01;
            bvalid<=1'b1;
            u_state<=U_BRESP;
        end
              
        U_BRESP:begin
        // $display("[CLK %0t]WRITE STATE:U_BRESP ", $time);
            if(bvalid&&bready)begin
                //$display("[CLK %0t]UART bresp handshake with CPU !", $time);
                $display("[CLK %0t] Write: UART[%0x] = 0x%08x ", $time, awaddr_t, wdata_t);
                $write("%c",wdata_t[7:0]);
                awready<=1'b1;
                wready<=1'b0;
                bvalid<=1'b0;
                bresp<=0;
                u_state<=U_READY;
            end
        end
    endcase
  end

end

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
            if(arready&&arvalid)begin//读地址握手成功
                arready<=1'b0;//取消读就绪
                rresp<={2'b10};
                rdata<=0;
                rvalid<=1'b1;
                r_state<=R_BUSY;
            end
        end
        R_BUSY:begin
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

endmodule
