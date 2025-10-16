module ysyx_25080204_Arbiter(
    input clk,
    input rst,
    //IFU读接口
    input [31:0]ifu_araddr,
    input [2:0] ifu_arsize,
    input ifu_arvalid,
    output reg   ifu_arready,

    output reg   ifu_rvalid,
    output [31:0] ifu_rdata,
    output reg [1:0] ifu_rresp,
    input ifu_rready,
    //LSU读接口
    input [31:0] lsu_araddr,
    input [2:0]  lsu_arsize,
    input lsu_arvalid,
    output reg   lsu_arready,

    output reg   lsu_rvalid,
    output [31:0] lsu_rdata,
    output reg [1:0] lsu_rresp,
    input lsu_rready,

    //Xbar读接口
    output [31:0]arb_araddr,
    output [2:0] arb_arsize,
    output arb_arvalid,
    input xbar_arready,

    input [31:0]xbar_rdata,
    input [1:0]xbar_rresp,
    input xbar_rvalid,
    output reg arb_rready,

    //LSU写接口
    input [31:0]lsu_awaddr,
    input [2:0] lsu_awsize,
    input lsu_awvalid,
    output reg lsu_awready,

    input [31:0]lsu_wdata,
    input [3:0]lsu_wstrb,
    input lsu_wvalid,
    output reg lsu_wready,

    output reg [1:0]lsu_bresp,
    output reg lsu_bvalid,
    input lsu_bready,

    //Xbar写接口
    output reg [31:0]arb_awaddr,
    output reg [2:0]arb_awsize,
    output reg arb_awvalid,
    input xbar_awready,

    output reg [31:0]arb_wdata,
    output reg [3:0]arb_wstrb,
    output reg arb_wvalid,
    input  xbar_wready,

    input [1:0]xbar_bresp,
    input xbar_bvalid,
    output reg arb_bready
   
);

localparam R_IDLE= 1;
localparam R_IFU = 2;
localparam R_LSU = 3;

reg [1:0]r_state,r_next_state;

assign ifu_rdata=xbar_rdata;
assign ifu_rresp=xbar_rresp;
assign lsu_rdata=xbar_rdata;
assign lsu_rresp=xbar_rresp;
//读仲裁
always@(*)begin
  case(r_state)
    R_IDLE:begin
      r_next_state=ifu_arvalid?R_IFU:lsu_arvalid?R_LSU:R_IDLE;
    end
    R_IFU:begin
      if(ifu_rready&&ifu_rvalid)r_next_state=R_IDLE;
    end
    R_LSU:begin
      if(lsu_rready&&lsu_rvalid)r_next_state=R_IDLE;
    end
  endcase
end

always@(posedge clk or posedge rst)begin
  if(rst)r_state<=R_IDLE;
  else r_state<=r_next_state;
end

always@(*)begin
  case(r_state)
    R_IDLE:begin
      ifu_arready=0;
      ifu_rvalid=0;
      lsu_arready=0;
      lsu_rvalid=0;
      arb_araddr=0;
      arb_arvalid=0;
      arb_rready=0;
    end
    R_IFU:begin
    // $display("[CLK %0t]master IFU connect with SRAM! ", $time);
      arb_araddr=ifu_araddr;
      arb_arvalid=ifu_arvalid;
      ifu_arready=xbar_arready;
      arb_arsize=ifu_arsize;
      ifu_rvalid=xbar_rvalid;
      arb_rready=ifu_rready;
    end
    R_LSU:begin
    // $display("[CLK %0t]master LSU connect with SRAM! ", $time);
      arb_araddr=lsu_araddr;
      arb_arvalid=lsu_arvalid;
      lsu_arready=xbar_arready;
      arb_arsize=lsu_arsize;
      lsu_rvalid=xbar_rvalid;
      arb_rready=lsu_rready;
    end
  endcase
end

//写仲裁
//现在似乎只有lsu会发出写信号，暂不实现写仲裁，直接相连
always@(*)begin
    arb_awaddr=lsu_awaddr;
    arb_awvalid=lsu_awvalid;
    arb_awsize=lsu_awsize;
    lsu_awready=xbar_awready;

    arb_wdata=lsu_wdata;
    arb_wstrb=lsu_wstrb;
    arb_wvalid=lsu_wvalid;
    lsu_wready=xbar_wready;

    lsu_bresp=xbar_bresp;
    lsu_bvalid=xbar_bvalid;
    arb_bready=lsu_bready;
end

endmodule
