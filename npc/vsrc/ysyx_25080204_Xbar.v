module ysyx_25080204_Xbar(
    //Arbiter读接口
    input [31:0]arb_araddr,
    input arb_arvalid,
    output xbar_arready,

    output [31:0]xbar_rdata,
    output [1:0]xbar_rresp,
    output xbar_rvalid,
    input  arb_rready,

    //SRAM读接口
    output [31:0]sram_araddr,
    output sram_arvalid,
    input sram_arready,

    input [31:0]sram_rdata,
    input [1:0]sram_rresp,
    input sram_rvalid,
    output sram_rready,

    //UART读接口
    output [31:0]uart_araddr,
    output uart_arvalid,
    input uart_arready,

    input [31:0]uart_rdata,
    input [1:0]uart_rresp,
    input uart_rvalid,
    output uart_rready,

    //Arbiter写接口
    input [31:0]arb_awaddr,
    input arb_awvalid,
    output xbar_awready,

    input [31:0]arb_wdata,
    input arb_wvalid,
    input [1:0]arb_wstrb,
    output xbar_wready,

    output [1:0]xbar_bresp,
    output xbar_bvalid,
    input  arb_bready,

    //SRAM写接口
    output [31:0]sram_awaddr,
    output sram_awvalid,
    input  sram_awready,

    output [31:0]sram_wdata,
    output sram_wvalid,
    output [1:0]sram_wstrb,
    input  sram_wready,

    input  [1:0]sram_bresp,
    input  sram_bvalid,
    output sram_bready,

    //UART写接口
    output [31:0]uart_awaddr,
    output uart_awvalid,
    input  uart_awready,

    output [31:0]uart_wdata,
    output uart_wvalid,
    output [1:0]uart_wstrb,
    input  uart_wready,

    input  [1:0]uart_bresp,
    input  uart_bvalid,
    output uart_bready
);
//读分配
wire read_sram_valid=(arb_araddr>=32'h80000000&&arb_araddr<32'h80ffffff);
wire read_uart_valid=(arb_araddr==32'ha00003f8);

assign  sram_araddr=read_sram_valid?arb_araddr:0;
assign  sram_arvalid=read_sram_valid?arb_arvalid:0;
assign  sram_rready=read_sram_valid?arb_rready:0;

assign uart_araddr  = read_uart_valid ? arb_araddr : 0;
assign uart_arvalid = read_uart_valid ? arb_arvalid : 0;
assign uart_rready  = read_uart_valid ? arb_rready : 0;

assign  xbar_arready=read_sram_valid?sram_arready:read_uart_valid?uart_arready:0;
assign  xbar_rdata=read_sram_valid?sram_rdata:read_uart_valid?uart_rdata:0;
assign  xbar_rresp=read_sram_valid?sram_rresp:read_uart_valid?uart_rresp:2'b11;//不能读uart
assign  xbar_rvalid=read_sram_valid?sram_rvalid:read_uart_valid?uart_rvalid:0;
//写分配
wire write_sram_valid=(arb_awaddr>=32'h80000000&&arb_awaddr<32'h80ffffff);
wire write_uart_valid=(arb_awaddr==32'ha00003f8);

assign sram_awaddr=write_sram_valid?arb_awaddr:0;
assign sram_awvalid=write_sram_valid?arb_awvalid:0;
assign sram_wdata=write_sram_valid?arb_wdata:0;
assign sram_wvalid=write_sram_valid?arb_wvalid:0;
assign sram_wstrb=write_sram_valid?arb_wstrb:0;
assign sram_bready=write_sram_valid?arb_bready:0;

assign uart_awaddr=write_uart_valid?arb_awaddr:0;
assign uart_awvalid=write_uart_valid?arb_awvalid:0;
assign uart_wdata=write_uart_valid?arb_wdata:0;
assign uart_wvalid=write_uart_valid?arb_wvalid:0;
assign uart_wstrb=write_uart_valid?arb_wstrb:0;
assign uart_bready=write_uart_valid?arb_bready:0;

assign xbar_awready=write_sram_valid?sram_awready:write_uart_valid?uart_awready:0;
assign xbar_wready=write_sram_valid?sram_wready:write_uart_valid?uart_wready:0;
assign xbar_bresp=write_sram_valid?sram_bresp:write_uart_valid?uart_bresp:2'b11;
assign xbar_bvalid=write_sram_valid?sram_bvalid:write_uart_valid?uart_bvalid:1'b0;

endmodule
