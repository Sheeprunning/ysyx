
module ysyx_25080204(
    input clock,
    input reset,
    
    
    // AXI4 Master Write Address Channel
    input        io_master_awready,
    output       io_master_awvalid,
    output [31:0] io_master_awaddr,
    output [2:0]  io_master_awsize,

    
    
    // AXI4 Master Write Data Channel
    input        io_master_wready,
    output       io_master_wvalid,
    output [31:0] io_master_wdata,
    output [3:0]  io_master_wstrb,
    
    
    // AXI4 Master Write Response Channel
    output       io_master_bready,
    input        io_master_bvalid,
    input  [1:0]  io_master_bresp,
    
    
    // AXI4 Master Read Address Channel
    input        io_master_arready,
    output       io_master_arvalid,
    output [31:0] io_master_araddr,
    output [2:0]  io_master_arsize,
    
    
    // AXI4 Master Read Data Channel
    output       io_master_rready,
    input        io_master_rvalid,
    input  [1:0]  io_master_rresp,
    input  [31:0] io_master_rdata,
    
    
    /* verilator lint_off UNUSEDSIGNAL */
    input io_interrupt,
    output [7:0]  io_master_awlen,
    output [1:0]  io_master_awburst,

    output        io_master_wlast,     
    
    output [3:0]  io_master_awid,

    input  [3:0]  io_master_bid,

    output [7:0]  io_master_arlen,
    output [1:0]  io_master_arburst,
    
    output [3:0]  io_master_arid,

    input         io_master_rlast,
    input  [3:0]  io_master_rid,

    // AXI4 Slave Interface 
    output       io_slave_awready,  // 悬空
    input        io_slave_awvalid,  // 固定输入0
    input  [31:0] io_slave_awaddr,  // 固定输入0
    input  [3:0]  io_slave_awid,    // 固定输入0
    input  [7:0]  io_slave_awlen,   // 固定输入0
    input  [2:0]  io_slave_awsize,  // 固定输入0
    input  [1:0]  io_slave_awburst, // 固定输入0
    
    input        io_slave_wready,   // 悬空
    input        io_slave_wvalid,   // 固定输入0
    input  [31:0] io_slave_wdata,   // 固定输入0
    input  [3:0]  io_slave_wstrb,   // 固定输入0
    input         io_slave_wlast,   // 固定输入0
    
    input        io_slave_bready,   // 固定输入0
    output       io_slave_bvalid,   // 悬空
    output [1:0]  io_slave_bresp,   // 悬空
    output [3:0]  io_slave_bid,     // 悬空
    
    input        io_slave_arready,  // 悬空
    input        io_slave_arvalid,  // 固定输入0
    input  [31:0] io_slave_araddr,  // 固定输入0
    input  [3:0]  io_slave_arid,    // 固定输入0
    input  [7:0]  io_slave_arlen,   // 固定输入0
    input  [2:0]  io_slave_arsize,  // 固定输入0
    input  [1:0]  io_slave_arburst, // 固定输入0
    
    input        io_slave_rready,   // 固定输入0
    output       io_slave_rvalid,   // 悬空
    output [1:0]  io_slave_rresp,   // 悬空
    output [31:0] io_slave_rdata,   // 悬空
    output        io_slave_rlast,   // 悬空
    output [3:0]  io_slave_rid      // 悬空
    /* verilator lint_on UNUSEDSIGNAL */
);

wire clk = clock;
wire rst = reset;

//暂存寄存器
//AR

wire [31:0] lsu_araddr;
wire [2:0]  lsu_arsize;
wire        lsu_arvalid;
//R
wire        lsu_rready;
//AW
wire [31:0] lsu_awaddr;
wire [2:0]  lsu_awsize;
wire        lsu_awvalid;
//W
wire [31:0] lsu_wdata;
wire [3:0]  lsu_wstrb;
wire        lsu_wvalid;
//B
wire       lsu_bready;


//立即作为赋值的线信号
wire [31:0] lsu_rdata;
wire [1:0]  lsu_rresp;
wire        lsu_rvalid;
wire [1:0]  lsu_bresp;
wire        lsu_bvalid;

wire [31:0] inst_araddr;
wire [2:0]  inst_arsize;
wire        inst_arvalid;
wire        inst_rready;
wire [31:0] inst_rdata;
wire [1:0]  inst_rresp;
wire        inst_rvalid;

//arb信号
wire [31:0] arb_araddr; 
wire [2:0]  arb_arsize;
wire        arb_arvalid; 
wire        arb_rready;

wire [31:0] arb_awaddr;
wire [2:0]  arb_awsize;
wire        arb_awvalid;
wire [31:0] arb_wdata;
wire [3:0]  arb_wstrb;
wire        arb_wvalid;
wire        arb_bready;

// Xbar信号
wire        xbar_arready;
wire [31:0] xbar_rdata;
wire [1:0]  xbar_rresp;
wire        xbar_rvalid;

wire        xbar_awready;
wire        xbar_wready;
wire [1:0]  xbar_bresp;
wire        xbar_bvalid;

/* verilator lint_off UNUSEDSIGNAL */
wire        lsu_arready;
wire        inst_arready;
wire        lsu_awready;
wire        lsu_wready;
wire [1:0]  inst_bresp;

reg check;

wire        Zero, Overflow, CF;
wire [31:0] a0;

wire [31:0] clint_awaddr;
wire        clint_awvalid;
wire        clint_awready;
wire [31:0] clint_wdata;
wire        clint_wvalid;
wire [3:0]  clint_wstrb;
wire        clint_wready;
wire [1:0]  clint_bresp;
wire        clint_bvalid;
wire        clint_bready;




//cpu的连线
wire [31:0] inst,pc;
/* verilator lint_on UNUSEDSIGNAL */


//CLINT信号
wire [31:0] clint_araddr;
wire        clint_arvalid;
wire        clint_arready;
wire [31:0] clint_rdata;
wire [1:0]  clint_rresp;
wire        clint_rvalid;
wire        clint_rready;




// CPU
ysyx_25080204_0_CPU CPU (
    // 时钟和复位
    .clk            (clk),
    .rst            (rst),

    .pc             (pc),
    .inst           (inst),
    
    // IFU AXI接口
    // AR通道
    .inst_araddr    (inst_araddr),
    .inst_arsize    (inst_arsize),
    .inst_arvalid   (inst_arvalid),
    .inst_arready   (inst_arready),
    
    // R通道
    .inst_rdata     (inst_rdata),
    .inst_rresp     (inst_rresp),
    .inst_rvalid    (inst_rvalid),
    .inst_rready    (inst_rready),
    
    // LSU AXI接口
    // AR通道
    .lsu_araddr     (lsu_araddr),
    .lsu_arsize     (lsu_arsize),
    .lsu_arvalid    (lsu_arvalid),
    .lsu_arready    (lsu_arready),
    
    // R通道
    .lsu_rdata      (lsu_rdata),
    .lsu_rresp      (lsu_rresp),
    .lsu_rvalid     (lsu_rvalid),
    .lsu_rready     (lsu_rready),
    
    // AW通道
    .lsu_awaddr     (lsu_awaddr),
    .lsu_awsize     (lsu_awsize),
    .lsu_awvalid    (lsu_awvalid),
    .lsu_awready    (lsu_awready),
    
    // W通道
    .lsu_wdata      (lsu_wdata),
    .lsu_wstrb      (lsu_wstrb),
    .lsu_wvalid     (lsu_wvalid),
    .lsu_wready     (lsu_wready),
    
    // B通道
    .lsu_bvalid     (lsu_bvalid),
    .lsu_bresp      (lsu_bresp),
    .lsu_bready     (lsu_bready)
);

//仲裁器
ysyx_25080204_Arbiter arbiter (
    .clk(clk),
    .rst(rst),
    
    .ifu_araddr(inst_araddr),
    .ifu_arsize(inst_arsize),
    .ifu_arvalid(inst_arvalid),
    .ifu_arready(inst_arready),
    .ifu_rvalid(inst_rvalid),
    .ifu_rdata(inst_rdata),
    .ifu_rresp(inst_rresp),
    .ifu_rready(inst_rready),
    
    .lsu_araddr(lsu_araddr),
    .lsu_arsize(lsu_arsize),
    .lsu_arvalid(lsu_arvalid),
    .lsu_arready(lsu_arready),
    .lsu_rvalid(lsu_rvalid),
    .lsu_rdata(lsu_rdata),
    .lsu_rresp(lsu_rresp),
    .lsu_rready(lsu_rready),

    .arb_araddr(arb_araddr),
    .arb_arsize(arb_arsize),
    .arb_arvalid(arb_arvalid),
    .xbar_arready(xbar_arready),

    .xbar_rdata(xbar_rdata),
    .xbar_rresp(xbar_rresp),

    .xbar_rvalid(xbar_rvalid),
    .arb_rready(arb_rready),

    .lsu_awaddr(lsu_awaddr),
    .lsu_awsize(lsu_awsize),
    .lsu_awvalid(lsu_awvalid),
    .lsu_awready(lsu_awready),

    .lsu_wdata(lsu_wdata),
    .lsu_wstrb(lsu_wstrb),
    .lsu_wvalid(lsu_wvalid),
    .lsu_wready(lsu_wready),

    .lsu_bresp(lsu_bresp),
    .lsu_bvalid(lsu_bvalid),
    .lsu_bready(lsu_bready),

    .arb_awaddr(arb_awaddr),
    .arb_awsize(arb_awsize),
    .arb_awvalid(arb_awvalid),
    .xbar_awready(xbar_awready),

    .arb_wdata(arb_wdata),
    .arb_wvalid(arb_wvalid),
    .arb_wstrb(arb_wstrb),
    .xbar_wready(xbar_wready),

    .xbar_bresp(xbar_bresp),
    .xbar_bvalid(xbar_bvalid),
    .arb_bready(arb_bready)
);

//Xbar
/* verilator lint_off PINCONNECTEMPTY */
ysyx_25080204_Xbar xbar (
    .arb_araddr(arb_araddr),
    .arb_arsize(arb_arsize),
    .arb_arvalid(arb_arvalid),
    .xbar_arready(xbar_arready),
    .xbar_rdata(xbar_rdata),
    .xbar_rresp(xbar_rresp),
    .xbar_rvalid(xbar_rvalid),
    .arb_rready(arb_rready),
    
    .arb_awaddr(arb_awaddr),
    .arb_awsize(arb_awsize),
    .arb_awvalid(arb_awvalid),
    .xbar_awready(xbar_awready),
    .arb_wdata(arb_wdata),
    .arb_wvalid(arb_wvalid),
    .arb_wstrb(arb_wstrb),
    .xbar_wready(xbar_wready),
    .xbar_bresp(xbar_bresp),
    .xbar_bvalid(xbar_bvalid),
    .arb_bready(arb_bready),
    
    .io_master_araddr(io_master_araddr),
    .io_master_arsize(io_master_arsize),
    .io_master_arvalid(io_master_arvalid),
    .io_master_arready(io_master_arready),
    .io_master_rdata(io_master_rdata),
    .io_master_rresp(io_master_rresp),
    .io_master_rvalid(io_master_rvalid),
    .io_master_rready(io_master_rready),
    
    .io_master_awaddr(io_master_awaddr),
    .io_master_awsize(io_master_awsize),
    .io_master_awvalid(io_master_awvalid),
    .io_master_awready(io_master_awready),
    .io_master_wdata(io_master_wdata),
    .io_master_wvalid(io_master_wvalid),
    .io_master_wstrb(io_master_wstrb),
    .io_master_wready(io_master_wready),
    .io_master_bresp(io_master_bresp),
    .io_master_bvalid(io_master_bvalid),
    .io_master_bready(io_master_bready),

    .clint_araddr(clint_araddr),
    .clint_arsize(),
    .clint_arvalid(clint_arvalid),
    .clint_arready(clint_arready),
    .clint_rdata(clint_rdata),
    .clint_rresp(clint_rresp),
    .clint_rvalid(clint_rvalid),
    .clint_rready(clint_rready),
        
    .clint_awaddr(clint_awaddr),
    .clint_awsize(),
    .clint_awvalid(clint_awvalid),
    .clint_awready(clint_awready),
    .clint_wdata(clint_wdata),
    .clint_wvalid(clint_wvalid),
    .clint_wstrb(clint_wstrb),
    .clint_wready(clint_wready),
    .clint_bresp(clint_bresp),
    .clint_bvalid(clint_bvalid),
    .clint_bready (clint_bready)
);
/* verilator lint_on PINCONNECTEMPTY */
// CLINT
ysyx_25080204_CLINT CLINT (
    .clk(clk),
    .rst(rst),

    .araddr(clint_araddr),      
    .arvalid(clint_arvalid),   
    .arready(clint_arready),
        
    .rdata(clint_rdata),
    .rresp(clint_rresp),
    .rvalid(clint_rvalid),
    .rready(clint_rready),    
        
    .awaddr(clint_awaddr),    
    .awvalid(clint_awvalid),   
    .awready(clint_awready),
        
    .wdata(clint_wdata),     
    .wstrb(clint_wstrb),      
    .wvalid(clint_wvalid),    
    .wready(clint_wready),
        
    .bresp(clint_bresp),
    .bvalid(clint_bvalid),
    .bready(clint_bready) 
);

// stall信号组合逻辑
always @(posedge clk) begin
    check<=~CPU.stall;
end

assign io_master_awlen=0;
assign io_master_awburst=0;
assign io_master_wlast=1;
assign io_master_awid=0;
assign io_master_arlen=0;
assign io_master_arburst=0;
assign io_master_arid=0;

assign io_slave_awready = 1'b0;
assign io_slave_bvalid = 1'b0;
assign io_slave_bresp = 2'b0;
assign io_slave_bid = 4'b0;
assign io_slave_rvalid = 1'b0;
assign io_slave_rresp = 2'b0;
assign io_slave_rdata = 32'b0;
assign io_slave_rlast = 1'b0;
assign io_slave_rid = 4'b0;

`ifdef sim
/* synthesis translate_off */
//performance counter
always @(posedge clk or posedge rst) begin
    if(!rst) begin
        if(inst_r_handshake)    performance_counter(32'd0);
        if(lsu_r_handshake)     performance_counter(32'd1);
        if(lsu_b_handshake)     performance_counter(32'd2);
    end
end


reg inst_time;//表示进入了取指时间
reg [31:0]inst_cycle;//记录取指周期
always @(posedge clk or posedge rst) begin
    if(rst)begin
        inst_time   <=  1'b0;
        inst_cycle  <=  32'b0;
    end 
    else begin
        if(!stall)begin
            inst_time   <=  1'b1;
            inst_cycle  <=  32'b1;
        end
        else if(inst_r_handshake)begin
            performance_cycle(32'd0,inst_cycle);
            inst_time   <=  1'b0;
            inst_cycle  <=  32'b0;
        end
        else if(inst_time)
            inst_cycle  <=  inst_cycle+1; 
    end
end

reg lsu_read_time;//表示进入了取数时间
reg [31:0]lsu_read_cycle;//记录取数周期
always @(posedge clk or posedge rst) begin
    if(rst)begin
        lsu_read_time   <=  1'b0;
        lsu_read_cycle  <=  32'b0;
    end 
    else begin
        if(lsu_read_begin)begin
            lsu_read_time   <=  1'b1;
            lsu_read_cycle  <=  32'b1;
        end
        else if(lsu_r_handshake)begin
            performance_cycle(32'd1 , lsu_read_cycle);
            lsu_read_time   <=  1'b0;
            lsu_read_cycle  <=  32'b0;
        end
        else if(lsu_read_time)
            lsu_read_cycle  <=  lsu_read_cycle+1; 
    end
end

reg lsu_write_time;//表示进入了写数时间
reg [31:0]lsu_write_cycle;//记录写数周期
always @(posedge clk or posedge rst) begin
    if(rst)begin
        lsu_write_time   <=  1'b0;
        lsu_write_cycle  <=  32'b0;
    end 
    else begin
        if(lsu_write_begin)begin
            lsu_write_time   <=  1'b1;
            lsu_write_cycle  <=  32'b1;
        end
        else if(lsu_b_handshake)begin
            performance_cycle(32'd2 , lsu_write_cycle);
            lsu_write_time   <=  1'b0;
            lsu_write_cycle  <=  32'b0;
        end
        else if(lsu_write_time)
            lsu_write_cycle  <=  lsu_write_cycle+1; 
    end
end

// resp处理
always @(*) begin
    if(io_master_rresp!=2'b00) begin  
        $display("[CLK %0t]ysyx_25080204.v: Access Fault!araddr=0x%08x", $time,io_master_araddr);
        npc_ebreak_finish();
    end
    if(io_master_bresp!=2'b00)begin
      $display("[CLK %0t]ysyx_25080204.v: Access Fault!awaddr=0x%08x", $time,io_master_awaddr);
      npc_ebreak_finish();
    end
end

// ebreak处理
always @(*) begin
    if(inst == 32'h100073) begin  // ebreak指令
        npc_ebreak_finish();
        $display("[CLK %0t] ebreak", $time);
    end
end
/* synthesis translate_on */
`endif
endmodule
