module ysyx_25080204(
    input clock,
    input reset,
    input io_interrupt,
    
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
reg [31:0] lsu_araddr_reg;
reg [2:0]  lsu_arsize_reg;
reg        lsu_arvalid_reg;
wire [31:0] lsu_araddr;
wire [2:0]  lsu_arsize;
wire        lsu_arvalid;
//R
reg [31:0] rdata_from_dm_reg;
reg        lsu_rready_reg;
wire [31:0] rdata_from_dm;
wire        lsu_rready;
//AW
reg [31:0] lsu_awaddr_reg;
reg [2:0]  lsu_awsize_reg;
reg        lsu_awvalid_reg;
wire [31:0] lsu_awaddr;
wire [2:0]  lsu_awsize;
wire        lsu_awvalid;
//W
reg [31:0] lsu_wdata_reg;
reg [3:0]  lsu_wstrb_reg;
reg        lsu_wvalid_reg;
wire [31:0] lsu_wdata;
wire [3:0]  lsu_wstrb;
wire        lsu_wvalid;
//B
reg        lsu_bready_reg;
wire       lsu_bready;
//AR_INST
reg [31:0]  inst_araddr_reg;
reg [2:0]   inst_arsize_reg;
reg         inst_arvalid_reg;
wire [31:0] inst_araddr;
wire [2:0]  inst_arsize;
wire        inst_arvalid;
//R_INST
reg [31:0] inst_reg;
reg        inst_rready_reg;
wire [31:0] inst;
wire        inst_rready;

//立即作为赋值的线信号
wire [31:0] lsu_rdata;
wire [1:0]  lsu_rresp;
wire        lsu_rvalid;
wire [1:0]  lsu_bresp;
wire        lsu_bvalid;

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

reg [1:0]  lsu_rresp_reg;
reg [1:0]  inst_rresp_reg;
reg [1:0]  bresp_reg;
reg [1:0]  lsu_bresp_reg;

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
/* verilator lint_on UNUSEDSIGNAL */

assign rdata_from_dm = rdata_from_dm_reg;
assign lsu_araddr = lsu_araddr_reg;
assign lsu_arvalid = lsu_arvalid_reg;
assign lsu_awaddr = lsu_awaddr_reg;
assign lsu_awsize = lsu_awsize_reg;
assign lsu_awvalid = lsu_awvalid_reg;
assign lsu_wdata = lsu_wdata_reg;
assign lsu_wstrb = lsu_wstrb_reg;
assign lsu_wvalid = lsu_wvalid_reg;
assign lsu_rready = lsu_rready_reg;
assign lsu_bready = lsu_bready_reg;
assign inst_araddr = inst_araddr_reg;
assign lsu_arsize = lsu_arsize_reg;
assign inst_arvalid = inst_arvalid_reg;
assign inst_arsize = inst_arsize_reg;
assign inst_rready = inst_rready_reg;
assign inst = inst_reg;


//cpu的连线
wire        DM_r_en, DM_w_en;
wire [31:0] w_r_addr;
wire [31:0] wdata_from_reg;
wire [3:0]  mem_mask;
wire [2:0] size;
wire [31:0] next_pc_for_inst,pc;
wire        stall;
wire        load,store;//提前根据指令计算是否stall


//CLINT信号
wire [31:0] clint_araddr;
wire        clint_arvalid;
wire        clint_arready;
wire [31:0] clint_rdata;
wire [1:0]  clint_rresp;
wire        clint_rvalid;
wire        clint_rready;


reg r_stall, w_stall, inst_stall ,will_stall;
reg [1:0] r_state, w_state, inst_state;

localparam R_IDLE = 2'b00;
localparam R_WAIT = 2'b01;
localparam W_IDLE = 2'b00;
localparam W_WRITE = 2'b01;
localparam W_BRESP = 2'b10;
localparam INST_RESET = 2'b00;
localparam INST_IDLE  = 2'b01;
localparam INST_WAIT  = 2'b10;

// CPU
ysyx_25080204_0_CPU CPU(
    .clk(clk),
    .rst(rst),
    .inst(inst),              
    .rdata(rdata_from_dm),
    .stall(stall),    
    .Zero(Zero),
    .Overflow(Overflow),
    .CF(CF),
    .DM_r_en(DM_r_en),
    .DM_w_en(DM_w_en),
    .w_r_addr(w_r_addr),
    .wdata(wdata_from_reg),
    .mem_mask(mem_mask),
    .size(size),
    .a0(a0),
    .next_pc_for_inst(next_pc_for_inst),
    .pc(pc)
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
ysyx_25080204_Xbar xbar (
    .arb_araddr(arb_araddr),
    .arb_arvalid(arb_arvalid),
    .xbar_arready(xbar_arready),
    .xbar_rdata(xbar_rdata),
    .xbar_rresp(xbar_rresp),
    .xbar_rvalid(xbar_rvalid),
    .arb_rready(arb_rready),
    
    .arb_awaddr(arb_awaddr),
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

wire r_idle_to_r_wait=DM_r_en&&will_stall;
wire r_wait_to_r_idle=lsu_rvalid && lsu_rready;


// 数据存储器读请求
always @(posedge clk or posedge rst) begin
    if(rst) begin
        lsu_arvalid_reg <= 1'b0;
        lsu_araddr_reg <= 32'b0;
        lsu_rready_reg <= 1'b0;
        rdata_from_dm_reg <= 32'b0;
        r_stall <= 1'b0;
        r_state <= R_IDLE;
    end else begin
        case(r_state)
            R_IDLE: begin
                if(r_idle_to_r_wait) begin
                    lsu_arvalid_reg <= 1'b1;
                    lsu_araddr_reg <= w_r_addr;
                    lsu_arsize_reg <= size;
                    lsu_rready_reg <= 1'b1;
                    r_stall <= 1'b1;
                    r_state <= R_WAIT;
                end
            end
            R_WAIT: begin
            if(lsu_arready&&lsu_arvalid)lsu_arvalid_reg<=1'b0;
                if(r_wait_to_r_idle) begin
                    rdata_from_dm_reg <= lsu_rdata;
                    lsu_rresp_reg<=lsu_rresp;
                    lsu_rready_reg <= 1'b0;
                    r_stall <= 1'b0;
                    r_state <= R_IDLE; 
// $display("\033[0;34m[CLK %0t]LSU handshake read with MEM! READ size=%03b addr=0x%08x data=0x%08x \033[0m", $time,lsu_arsize,lsu_araddr_reg,lsu_rdata);
                end
            end
            default:begin end
        endcase
    end 
end

// 数据存储器写请求
always @(posedge clk or posedge rst) begin
    if(rst) begin
        lsu_awvalid_reg <= 1'b0;
        lsu_awaddr_reg <= 32'b0;
        lsu_wvalid_reg <= 1'b0;
        lsu_wdata_reg <= 32'b0;
        lsu_wstrb_reg <= 4'b0;
        lsu_bready_reg <= 1'b0;
        w_stall <= 1'b0;
        w_state <= W_IDLE;
    end else begin
        case(w_state)
            W_IDLE: begin
                if(DM_w_en&&will_stall) begin
                    lsu_awvalid_reg <= 1'b1;
                    lsu_awsize_reg<= size;
                    lsu_awaddr_reg <= w_r_addr;
                    lsu_wvalid_reg <= 1'b1;
                    lsu_wdata_reg <= wdata_from_reg;
                    lsu_wstrb_reg <= mem_mask;
                    w_stall <= 1'b1;
                    w_state <= W_WRITE;
                end
            end
            W_WRITE: begin
              if(lsu_wready&&lsu_wvalid)begin
// $display("\033[0;32m[CLK %0t]LSU handshake write with MEM! addr=0x%08x data=0x%08x strb=%04b size=%03b\033[0m", $time,lsu_awaddr_reg,lsu_wdata_reg,lsu_wstrb_reg,lsu_awsize);
                lsu_bready_reg <= 1'b1;
                lsu_awvalid_reg <= 1'b0;
                lsu_wvalid_reg <= 1'b0;
                w_state <= W_BRESP;
              end
            end
            W_BRESP: begin
                if(lsu_bvalid && lsu_bready) begin
                    lsu_bresp_reg<=lsu_bresp;
                    lsu_bready_reg <= 1'b0;
                    w_stall <= 1'b0;
                    w_state <= W_IDLE;
                end 
            end
            default:begin end
        endcase
    end 
end
// 指令存储器读请求
always @(posedge clk or posedge rst) begin
    if(rst) begin
        inst_arvalid_reg <= 1'b0;
        inst_araddr_reg <= 32'b0;
        inst_rready_reg <= 1'b0;
        inst_reg <= 32'h00000013; 
        inst_stall <= 1'b1;
        inst_state <= INST_RESET;
    end else begin
        case(inst_state)
            INST_RESET: begin
                inst_arvalid_reg <= 1'b1;
                inst_araddr_reg <= pc;
                inst_arsize_reg <= 3'b010;
                inst_rready_reg <= 1'b1;
                inst_stall <= 1'b1;
                inst_state <= INST_WAIT;
            end
            INST_IDLE: begin
                if(!stall) begin
                    inst_arvalid_reg <= 1'b1;
                    inst_araddr_reg <= next_pc_for_inst;
                    inst_rready_reg <= 1'b1;
                    inst_stall <= 1'b1;
                    inst_state <= INST_WAIT;
                end 
            end
            INST_WAIT: begin
            // $display("[CLK %0t]CPU STATE:R_WAIT ", $time);
                if(inst_arready&&inst_arvalid)inst_arvalid_reg<=1'b0;
                if(inst_rvalid && inst_rready) begin
// $display("\033[1;36m[CLK %0t]IFU handshake with IM! PC:0x%08x GET inst=0x%08x\033[0m", $time,inst_araddr_reg,inst_rdata);
                    inst_reg <= inst_rdata;
                    inst_rresp_reg<=inst_rresp;
                    inst_rready_reg <= 1'b0;
                    inst_stall <= 1'b0;
                    inst_state <= INST_IDLE;
                end 
            end
            default:begin end
        endcase
    end 
end

assign load = (inst_rdata[6:0]==7'b0000011)&&inst_rvalid;//和rvalid进行与，这样在读完指令后不会一直保持有效
assign store = (inst_rdata[6:0]==7'b0100011)&&inst_rvalid;
always @(posedge clk or posedge rst) begin
    if(rst)will_stall<=1'b0;
    else if(will_stall)will_stall<=1'b0;//保证只持续一周期
    else will_stall<=load||store;
end
// stall信号组合逻辑
reg check;
always @(posedge clk or posedge rst) begin
    check<=~stall;
end
assign stall = r_stall || w_stall || inst_stall || will_stall;

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
import "DPI-C" function void npc_ebreak_finish();
always @(*) begin
    if(inst == 32'h100073) begin  // ebreak指令
        npc_ebreak_finish();
        $display("[CLK %0t] ebreak", $time);
    end
end

endmodule
