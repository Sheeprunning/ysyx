module ysyx_25080204_Arbiter(
    input clk,
    input rst,
    //IFU接口
    input [31:0]ifu_araddr,
    input ifu_arvalid,
    output reg   ifu_arready,

    output reg   ifu_rvalid,
    output [31:0] ifu_rdata,
    output reg [1:0] ifu_rresp,
    input ifu_rready,
    //LSU接口
    input [31:0] lsu_araddr,
    input lsu_arvalid,
    output reg   lsu_arready,

    output reg   lsu_rvalid,
    output [31:0] lsu_rdata,
    output reg [1:0] lsu_rresp,
    input lsu_rready,

    //MEM接口
    output [31:0]arb_araddr,
    output arb_arvalid,
    input mem_arready,

    input [31:0]mem_rdata,
    input [1:0]mem_rresp,
    input mem_rvalid,
    output reg arb_rready
   
);

localparam R_IDLE= 1;
localparam R_IFU = 2;
localparam R_LSU = 3;

reg [1:0]r_state,r_next_state;

assign ifu_rdata=mem_rdata;
assign ifu_rresp=mem_rresp;
assign lsu_rdata=mem_rdata;
assign lsu_rresp=mem_rresp;
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
      arb_araddr=ifu_araddr;
      arb_arvalid=ifu_arvalid;
      ifu_arready=mem_arready;
      
      ifu_rvalid=mem_rvalid;
      arb_rready=ifu_rready;
    end
    R_LSU:begin
      arb_araddr=lsu_araddr;
      arb_arvalid=lsu_arvalid;
      lsu_arready=mem_arready;
      
      lsu_rvalid=mem_rvalid;
      arb_rready=lsu_rready;
    end
  endcase
end
endmodule
