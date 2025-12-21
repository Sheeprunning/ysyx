module ysyx_25080204_CLINT(
    input clk,
    input rst,

    input [31:0]araddr,
    input arvalid,
    output reg arready,
 
    output reg [31:0]rdata,
    output reg [1:0]rresp,
    output reg rvalid,
    input rready,
/* verilator lint_off UNUSEDSIGNAL */
    input [31:0]awaddr,
    input awvalid,
    output reg awready,

    input [31:0]wdata,
    input [3:0]wstrb,
    input wvalid,
    output reg wready,

    output reg [1:0]bresp,
    output reg bvalid,
    input bready
    /* verilator lint_on UNUSEDSIGNAL */
);

localparam C_READY= 2'b00;
localparam C_BUSY = 2'b01;

//内置的计数器
reg [31:0]mtime_low,mtime_high;
wire [31:0]mtime_low_next=mtime_low+1;
wire [31:0]mtime_high_next=(mtime_low_next==0)?mtime_high+1:mtime_high;
always @(posedge clk or posedge rst)begin
  if(rst)begin
    mtime_low<=0;
    mtime_high<=0;
  end
  else begin
    mtime_low<=mtime_low_next;
    mtime_high<=mtime_high_next;
  end
end

//读通道
reg [1:0]c_state;
wire r_low= (araddr==32'h02000000);
wire r_high=(araddr==32'h02000004);
wire [31:0]mtime=r_low?mtime_low:r_high?mtime_high:0;
always @(posedge clk or posedge rst)begin
  if(rst)begin
    arready<=1;
    rdata<=0;
    rresp<=2'b0;
    rvalid<=0;
    c_state<=C_READY;
  end
  else begin
    case(c_state)
        C_READY:begin
            if(arready&&arvalid)begin//读地址握手成功
                arready<=1'b0;//取消读就绪
                rresp<=2'b00;
                rdata<=mtime;
                rvalid<=1'b1;
                c_state<=C_BUSY;
            end
        end
        C_BUSY:begin
            if(rvalid&&rready)begin
                arready<=1'b1;
                rvalid<=1'b0;
                rresp<=2'b0;
                c_state<=C_READY;
            end
        end
        default:begin end
    endcase
  end
end

//写通道（但是不支持写）
localparam W_READY= 2'b00;
localparam W_ADDR = 2'b01;
localparam W_DATA = 2'b10;
localparam W_BRESP = 2'b11;

reg [1:0]w_state;
always @(posedge clk or posedge rst)begin
  if(rst)begin
    awready<=1; 
    wready<=1'b0;
    bresp<=0;
    bvalid<=0;
    w_state<=W_READY;
  end
  else begin
    case(w_state)
        W_READY:begin
            if(awready&&awvalid)begin
                awready<=1'b0;
                wready<=1'b1;
                w_state<=W_ADDR;
            end
        end
        W_ADDR:begin
            if(wready&&wvalid)begin
                wready<=1'b0;
                w_state<=W_DATA;
            end
        end
        W_DATA:begin
            bresp<=2'b10;//不支持写，直接返回错误码
            bvalid<=1'b1;
            w_state<=W_BRESP;
        end
        W_BRESP:begin
            if(bvalid&&bready)begin
                //pmem_write_v(awaddr_t, len_t, wdata_t);不进行写
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
endmodule
