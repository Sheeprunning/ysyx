module top(
    input clk,
    input rst,
    output Zero,
    output Overflow,
    output CF,
    output [31:0]cpu_pc,
    output [31:0]cpu_inst,
    output reg check,
    output [31:0] a0
);

//暂存寄存器
//AR
reg [31:0] lsu_araddr_reg;
reg        lsu_arvalid_reg;
wire [31:0] lsu_araddr;
wire        lsu_arvalid;
//R
reg [31:0] rdata_from_dm_reg;
reg        lsu_rready_reg;
wire [31:0] rdata_from_dm;
wire        lsu_rready;
//AW
reg [31:0] awaddr_reg;
reg        awvalid_reg;
wire [31:0] awaddr;
wire        awvalid;
//W
reg [31:0] wdata_reg;
reg [1:0]  wstrb_reg;
reg        wvalid_reg;
wire [31:0] wdata;
wire [1:0]  wstrb;
wire        wvalid;
//B
reg        bready_reg;
wire        bready;
//AR_INST
reg [31:0] inst_araddr_reg;
reg        inst_arvalid_reg;
wire [31:0] inst_araddr;
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
wire [1:0]  bresp;
wire        bvalid;

wire [31:0] inst_rdata;
wire [1:0]  inst_rresp;
wire        inst_rvalid;

/* verilator lint_off UNUSEDSIGNAL */
wire        lsu_arready;
wire        inst_arready;
wire        awready;
wire        wready;
wire [1:0]  inst_bresp;

reg [1:0]  lsu_rresp_reg;
reg [1:0]  inst_rresp_reg;
reg [1:0]  bresp_reg;
/* verilator lint_on UNUSEDSIGNAL */

assign rdata_from_dm = rdata_from_dm_reg;
assign lsu_araddr = lsu_araddr_reg;
assign lsu_arvalid = lsu_arvalid_reg;
assign awaddr = awaddr_reg;
assign awvalid = awvalid_reg;
assign wdata = wdata_reg;
assign wstrb = wstrb_reg;
assign wvalid = wvalid_reg;
assign lsu_rready = lsu_rready_reg;
assign bready = bready_reg;
assign inst_araddr = inst_araddr_reg;
assign inst_arvalid = inst_arvalid_reg;
assign inst_rready = inst_rready_reg;
assign inst = inst_reg;

assign cpu_pc=pc;
assign cpu_inst=inst;

//cpu的连线
wire        DM_r_en, DM_w_en;
wire [31:0] w_r_addr;
wire [31:0] wdata_from_reg;
wire [1:0]  mem_mask;
wire [31:0] next_pc_for_inst,pc;
wire        stall;
wire        load,store;//提前根据指令计算是否stall

//仲裁器连线
wire [31:0] arb_araddr; 
wire        arb_arvalid; 
wire        arb_rready;  

wire        mem_arready; 
wire [31:0] mem_rdata;   
wire [1:0]  mem_rresp;   
wire        mem_rvalid; 

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
    .a0(a0),
    .next_pc_for_inst(next_pc_for_inst),
    .pc(pc)
);

//仲裁器
ysyx_25080204_Arbiter arbiter_inst (
    .clk(clk),
    .rst(rst),
    
    .ifu_araddr(inst_araddr),
    .ifu_arvalid(inst_arvalid),
    .ifu_arready(inst_arready),
    .ifu_rvalid(inst_rvalid),
    .ifu_rdata(inst_rdata),
    .ifu_rresp(inst_rresp),
    .ifu_rready(inst_rready),
    
    .lsu_araddr(lsu_araddr),
    .lsu_arvalid(lsu_arvalid),
    .lsu_arready(lsu_arready),
    .lsu_rvalid(lsu_rvalid),
    .lsu_rdata(lsu_rdata),
    .lsu_rresp(lsu_rresp),
    .lsu_rready(lsu_rready),
    
    .arb_araddr(arb_araddr),
    .arb_arvalid(arb_arvalid),
    .mem_arready(mem_arready),
    .mem_rdata(mem_rdata),
    .mem_rresp(mem_rresp),
    .mem_rvalid(mem_rvalid),
    .arb_rready(arb_rready)
);

// 存储器
ysyx_25080204_DataMemory SRAM (
    .clk(clk),
    .rst(rst),

    .araddr(arb_araddr),      
    .arvalid(arb_arvalid),   
    .arready(mem_arready),
    
    .rdata(mem_rdata),
    .rresp(mem_rresp),
    .rvalid(mem_rvalid),
    .rready(arb_rready),    
    
    .awaddr(awaddr),    
    .awvalid(awvalid),   
    .awready(awready),
    
    .wdata(wdata),     
    .wstrb(wstrb),      
    .wvalid(wvalid),    
    .wready(wready),
    
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready)     
);

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
                if(DM_r_en) begin
                    lsu_arvalid_reg <= 1'b1;
                    lsu_araddr_reg <= w_r_addr;
                    lsu_rready_reg <= 1'b1;
                    r_stall <= 1'b1;
                    r_state <= R_WAIT;//arready握手之后仍保持arvalid
                end
            end
            R_WAIT: begin
                if(lsu_rvalid && lsu_rready) begin
                    rdata_from_dm_reg <= lsu_rdata;
                    lsu_rresp_reg<=lsu_rresp;
                    lsu_arvalid_reg <= 1'b0;
                    lsu_rready_reg <= 1'b0;
                    r_stall <= 1'b0;
                    r_state <= R_IDLE;
        $display("[CLK %0t]LSU handshake with SRAM! READ the data=0x%08x ", $time,lsu_rdata);
                end
            end
            default:begin end
        endcase
    end 
end

// 数据存储器写请求
always @(posedge clk or posedge rst) begin
    if(rst) begin
        awvalid_reg <= 1'b0;
        awaddr_reg <= 32'b0;
        wvalid_reg <= 1'b0;
        wdata_reg <= 32'b0;
        wstrb_reg <= 2'b0;
        bready_reg <= 1'b0;
        w_stall <= 1'b0;
        w_state <= W_IDLE;
    end else begin
        case(w_state)
            W_IDLE: begin
                if(DM_w_en&&will_stall) begin//忘记设计stall状态的处理，导致多次写数据
                    awvalid_reg <= 1'b1;
                    awaddr_reg <= w_r_addr;
                    wvalid_reg <= 1'b1;
                    wdata_reg <= wdata_from_reg;
                    wstrb_reg <= mem_mask;
                    w_stall <= 1'b1;
                    w_state <= W_WRITE;
                end
            end
            W_WRITE: begin
              if(wready&&wvalid)begin
                bready_reg <= 1'b1;
                awvalid_reg <= 1'b0;
                wvalid_reg <= 1'b0;
                w_state <= W_BRESP;
              end
            end
            W_BRESP: begin
                if(bvalid && bready) begin
                    bresp_reg<=bresp;
                    bready_reg <= 1'b0;
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
        inst_stall <= 1'b0;
        inst_state <= INST_RESET;
    end else begin
        case(inst_state)
            INST_RESET: begin
                inst_arvalid_reg <= 1'b1;
                inst_araddr_reg <= pc;
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
                if(inst_rvalid && inst_rready) begin
                $display("[CLK %0t]IFU handshake with IM! GET inst=0x%08x", $time,inst_rdata);
                    inst_reg <= inst_rdata;
                    inst_rresp_reg<=inst_rresp;
                    inst_arvalid_reg <= 1'b0;
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
always @(posedge clk or posedge rst) begin
    check<=~stall;
end
assign stall = r_stall || w_stall || inst_stall || will_stall;

// ebreak处理
import "DPI-C" function void npc_ebreak_finish();
always @(*) begin
    if(inst == 32'h100073) begin  // ebreak指令
        npc_ebreak_finish();
        $display("[CLK %0t] ebreak", $time);
    end
end

endmodule
