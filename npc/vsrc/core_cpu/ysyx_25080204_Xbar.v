module ysyx_25080204_Xbar(
    //Arbiter读接口
    input [31:0]arb_araddr,
    input [2:0] arb_arsize,
    input arb_arvalid,
    output xbar_arready,

    output [31:0]xbar_rdata,
    output [1:0]xbar_rresp,
    output xbar_rvalid,
    input  arb_rready,

    //IO_MASTER读接口
    output [31:0]io_master_araddr,
    output [2:0] io_master_arsize,
    output io_master_arvalid,
    input io_master_arready,

    input [31:0]io_master_rdata,
    input [1:0]io_master_rresp,
    input io_master_rvalid,
    output io_master_rready,


    //CLINT读接口
    output [31:0]clint_araddr,
    output [2:0] clint_arsize,
    output clint_arvalid,
    input clint_arready,

    input [31:0]clint_rdata,
    input [1:0]clint_rresp,
    input clint_rvalid,
    output clint_rready,

    //Arbiter写接口
    input [31:0]arb_awaddr,
    input [2:0]arb_awsize,
    input arb_awvalid,
    output xbar_awready,

    input [31:0]arb_wdata,
    input arb_wvalid,
    input [3:0]arb_wstrb,
    output xbar_wready,

    output [1:0]xbar_bresp,
    output xbar_bvalid,
    input  arb_bready,

    //IO_MASTER写接口
    output [31:0]io_master_awaddr,
    output [2:0] io_master_awsize,
    output io_master_awvalid,
    input  io_master_awready,

    output [31:0]io_master_wdata,
    output io_master_wvalid,
    output [3:0]io_master_wstrb,
    input  io_master_wready,

    input  [1:0]io_master_bresp,
    input  io_master_bvalid,
    output io_master_bready,


    //CLINT写接口
    output [31:0]clint_awaddr,
    output [2:0] clint_awsize,
    output clint_awvalid,
    input  clint_awready,

    output [31:0]clint_wdata,
    output clint_wvalid,
    output [3:0]clint_wstrb,
    input  clint_wready,

    input  [1:0]clint_bresp,
    input  clint_bvalid,
    output clint_bready
);
//读分配
wire read_clint_valid=(arb_araddr[31:16]==16'h0200);
wire read_io_master_valid=!read_clint_valid;

assign  io_master_araddr=read_io_master_valid?arb_araddr:0;
assign  io_master_arsize=read_io_master_valid?arb_arsize:0;
assign  io_master_arvalid=read_io_master_valid?arb_arvalid:0;
assign  io_master_rready=read_io_master_valid?arb_rready:0;


assign  clint_araddr=read_clint_valid?arb_araddr:0;
assign  clint_arsize=read_clint_valid?arb_arsize:0;
assign  clint_arvalid=read_clint_valid?arb_arvalid:0;
assign  clint_rready=read_clint_valid?arb_rready:0;

assign  xbar_arready = read_io_master_valid?io_master_arready:
                        read_clint_valid?clint_arready:0;
assign  xbar_rdata=read_io_master_valid?io_master_rdata:
                    read_clint_valid?clint_rdata:0;
assign  xbar_rresp=read_io_master_valid?io_master_rresp:
                    read_clint_valid?clint_rresp:2'b11;//不在所有接口地址内，rresp设置为11
assign  xbar_rvalid=read_io_master_valid?io_master_rvalid:
                    read_clint_valid?clint_rvalid:0;
//写分配
wire write_clint_valid=(arb_awaddr[31:16]==16'h0200);
wire write_io_master_valid=!write_clint_valid;

assign io_master_awaddr=write_io_master_valid?arb_awaddr:0;
assign io_master_awsize=write_io_master_valid?arb_awsize:0;
assign io_master_awvalid=write_io_master_valid?arb_awvalid:0;
assign io_master_wdata=write_io_master_valid?arb_wdata:0;
assign io_master_wvalid=write_io_master_valid?arb_wvalid:0;
assign io_master_wstrb=write_io_master_valid?arb_wstrb:0;
assign io_master_bready=write_io_master_valid?arb_bready:0;


assign clint_awaddr=write_clint_valid?arb_awaddr:0;
assign clint_awsize=write_clint_valid?arb_awsize:0;
assign clint_awvalid=write_clint_valid?arb_awvalid:0;
assign clint_wdata=write_clint_valid?arb_wdata:0;
assign clint_wvalid=write_clint_valid?arb_wvalid:0;
assign clint_wstrb=write_clint_valid?arb_wstrb:0;
assign clint_bready=write_clint_valid?arb_bready:0;

assign xbar_awready=write_io_master_valid?io_master_awready:
                    write_clint_valid?clint_awready:0;
assign xbar_wready=write_io_master_valid?io_master_wready:
                    write_clint_valid?clint_wready:0;
assign xbar_bresp=write_io_master_valid?io_master_bresp:
                    write_clint_valid?clint_bresp:2'b11;
assign xbar_bvalid=write_io_master_valid?io_master_bvalid:
                    write_clint_valid?clint_bvalid:1'b0;

// always @(*) begin
//     if(read_clint_valid)$display("error!write to rtc!");
// end
endmodule
