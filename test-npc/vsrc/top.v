// module top(
//     input clk,
//     input rst,
//     output Zero,
//     output Overflow,
//     output CF,
//     output [31:0]cpu_pc,
//     output [31:0]cpu_inst,
//     output reg check,
//     output [31:0] a0
// );

// //暂存寄存器
// //AR
// reg [31:0] lsu_araddr_reg;
// reg        lsu_arvalid_reg;
// wire [31:0] lsu_araddr;
// wire        lsu_arvalid;
// //R
// reg [31:0] rdata_from_dm_reg;
// reg        lsu_rready_reg;
// wire [31:0] rdata_from_dm;
// wire        lsu_rready;
// //AW
// reg [31:0] lsu_awaddr_reg;
// reg        lsu_awvalid_reg;
// wire [31:0] lsu_awaddr;
// wire        lsu_awvalid;
// //W
// reg [31:0] lsu_wdata_reg;
// reg [1:0]  lsu_wstrb_reg;
// reg        lsu_wvalid_reg;
// wire [31:0] lsu_wdata;
// wire [1:0]  lsu_wstrb;
// wire        lsu_wvalid;
// //B
// reg        lsu_bready_reg;
// wire       lsu_bready;
// //AR_INST
// reg [31:0] inst_araddr_reg;
// reg        inst_arvalid_reg;
// wire [31:0] inst_araddr;
// wire        inst_arvalid;
// //R_INST
// reg [31:0] inst_reg;
// reg        inst_rready_reg;
// wire [31:0] inst;
// wire        inst_rready;

// //立即作为赋值的线信号
// wire [31:0] lsu_rdata;
// wire [1:0]  lsu_rresp;
// wire        lsu_rvalid;
// wire [1:0]  lsu_bresp;
// wire        lsu_bvalid;

// wire [31:0] inst_rdata;
// wire [1:0]  inst_rresp;
// wire        inst_rvalid;

// /* verilator lint_off UNUSEDSIGNAL */
// wire        lsu_arready;
// wire        inst_arready;
// wire        lsu_awready;
// wire        lsu_wready;
// wire [1:0]  inst_bresp;

// reg [1:0]  lsu_rresp_reg;
// reg [1:0]  inst_rresp_reg;
// reg [1:0]  bresp_reg;
// reg [1:0]  lsu_bresp_reg;

// wire [31:0] uart_araddr;
// wire        uart_arvalid;
// wire        uart_arready;
// wire [31:0] uart_rdata;
// wire [1:0]  uart_rresp;
// wire        uart_rvalid;
// wire        uart_rready;

// wire [31:0] clint_awaddr;
// wire        clint_awvalid;
// wire        clint_awready;
// wire [31:0] clint_wdata;
// wire        clint_wvalid;
// wire [1:0]  clint_wstrb;
// wire        clint_wready;
// wire [1:0]  clint_bresp;
// wire        clint_bvalid;
// wire        clint_bready;
// /* verilator lint_on UNUSEDSIGNAL */

// assign rdata_from_dm = rdata_from_dm_reg;
// assign lsu_araddr = lsu_araddr_reg;
// assign lsu_arvalid = lsu_arvalid_reg;
// assign lsu_awaddr = lsu_awaddr_reg;
// assign lsu_awvalid = lsu_awvalid_reg;
// assign lsu_wdata = lsu_wdata_reg;
// assign lsu_wstrb = lsu_wstrb_reg;
// assign lsu_wvalid = lsu_wvalid_reg;
// assign lsu_rready = lsu_rready_reg;
// assign lsu_bready = lsu_bready_reg;
// assign inst_araddr = inst_araddr_reg;
// assign inst_arvalid = inst_arvalid_reg;
// assign inst_rready = inst_rready_reg;
// assign inst = inst_reg;

// assign cpu_pc=pc;
// assign cpu_inst=inst;

// //cpu的连线
// wire        DM_r_en, DM_w_en;
// wire [31:0] w_r_addr;
// wire [31:0] wdata_from_reg;
// wire [1:0]  mem_mask;
// wire [31:0] next_pc_for_inst,pc;
// wire        stall;
// wire        load,store;//提前根据指令计算是否stall

// //Xbar信号
// wire [31:0] arb_araddr; 
// wire        arb_arvalid; 
// wire        arb_rready;  
// wire [31:0] arb_awaddr;

// wire        arb_awvalid;
// wire [31:0] arb_wdata;
// wire [1:0]  arb_wstrb;
// wire        arb_wvalid;
// wire        arb_bready;

// // Xbar信号
// wire        xbar_arready;
// wire [31:0] xbar_rdata;
// wire [1:0]  xbar_rresp;
// wire        xbar_rvalid;

// wire        xbar_awready;
// wire        xbar_wready;
// wire [1:0]  xbar_bresp;
// wire        xbar_bvalid;

// // SRAM信号
// wire [31:0] sram_araddr;
// wire        sram_arvalid;
// wire        sram_arready;
// wire [31:0] sram_rdata;
// wire [1:0]  sram_rresp;
// wire        sram_rvalid;
// wire        sram_rready;

// wire [31:0] sram_awaddr;
// wire        sram_awvalid;
// wire        sram_awready;
// wire [31:0] sram_wdata;
// wire        sram_wvalid;
// wire [1:0]  sram_wstrb;
// wire        sram_wready;
// wire [1:0]  sram_bresp;
// wire        sram_bvalid;
// wire        sram_bready;

// // UART信号
// wire [31:0] uart_awaddr;
// wire        uart_awvalid;
// wire        uart_awready;
// wire [31:0] uart_wdata;
// wire        uart_wvalid;
// wire [1:0]  uart_wstrb;
// wire        uart_wready;
// wire [1:0]  uart_bresp;
// wire        uart_bvalid;
// wire        uart_bready;

// //CLINT信号
// wire [31:0] clint_araddr;
// wire        clint_arvalid;
// wire        clint_arready;
// wire [31:0] clint_rdata;
// wire [1:0]  clint_rresp;
// wire        clint_rvalid;
// wire        clint_rready;


// reg r_stall, w_stall, inst_stall ,will_stall;
// reg [1:0] r_state, w_state, inst_state;

// localparam R_IDLE = 2'b00;
// localparam R_WAIT = 2'b01;
// localparam W_IDLE = 2'b00;
// localparam W_WRITE = 2'b01;
// localparam W_BRESP = 2'b10;
// localparam INST_RESET = 2'b00;
// localparam INST_IDLE  = 2'b01;
// localparam INST_WAIT  = 2'b10;

// // CPU
// ysyx_25080204_0_CPU CPU(
//     .clk(clk),
//     .rst(rst),
//     .inst(inst),              
//     .rdata(rdata_from_dm),
//     .stall(stall),    
//     .Zero(Zero),
//     .Overflow(Overflow),
//     .CF(CF),
//     .DM_r_en(DM_r_en),
//     .DM_w_en(DM_w_en),
//     .w_r_addr(w_r_addr),
//     .wdata(wdata_from_reg),
//     .mem_mask(mem_mask),
//     .a0(a0),
//     .next_pc_for_inst(next_pc_for_inst),
//     .pc(pc)
// );

// //仲裁器
// ysyx_25080204_Arbiter arbiter (
//     .clk(clk),
//     .rst(rst),
    
//     .ifu_araddr(inst_araddr),
//     .ifu_arvalid(inst_arvalid),
//     .ifu_arready(inst_arready),
//     .ifu_rvalid(inst_rvalid),
//     .ifu_rdata(inst_rdata),
//     .ifu_rresp(inst_rresp),
//     .ifu_rready(inst_rready),
    
//     .lsu_araddr(lsu_araddr),
//     .lsu_arvalid(lsu_arvalid),
//     .lsu_arready(lsu_arready),
//     .lsu_rvalid(lsu_rvalid),
//     .lsu_rdata(lsu_rdata),
//     .lsu_rresp(lsu_rresp),
//     .lsu_rready(lsu_rready),
    
//     .arb_araddr(arb_araddr),
//     .arb_arvalid(arb_arvalid),
//     .xbar_arready(xbar_arready),

//     .xbar_rdata(xbar_rdata),
//     .xbar_rresp(xbar_rresp),
//     .arb_wvalid(arb_wvalid),

//     .xbar_rvalid(xbar_rvalid),
//     .arb_rready(arb_rready),

//     .lsu_awaddr(lsu_awaddr),
//     .lsu_awvalid(lsu_awvalid),
//     .lsu_awready(lsu_awready),

//     .lsu_wdata(lsu_wdata),
//     .lsu_wstrb(lsu_wstrb),
//     .lsu_wvalid(lsu_wvalid),
//     .lsu_wready(lsu_wready),

//     .lsu_bresp(lsu_bresp),
//     .lsu_bvalid(lsu_bvalid),
//     .lsu_bready(lsu_bready),

//     .arb_awaddr(arb_awaddr),
//     .arb_awvalid(arb_awvalid),
//     .xbar_awready(xbar_awready),

//     .arb_wdata(arb_wdata),
//     .arb_wstrb(arb_wstrb),
//     .xbar_wready(xbar_wready),

//     .xbar_bresp(xbar_bresp),
//     .xbar_bvalid(xbar_bvalid),
//     .arb_bready(arb_bready)
// );

// //Xbar
// ysyx_25080204_Xbar xbar_inst (
//     .arb_araddr(arb_araddr),
//     .arb_arvalid(arb_arvalid),
//     .xbar_arready(xbar_arready),
//     .xbar_rdata(xbar_rdata),
//     .xbar_rresp(xbar_rresp),
//     .xbar_rvalid(xbar_rvalid),
//     .arb_rready(arb_rready),
    
//     .arb_awaddr(arb_awaddr),
//     .arb_awvalid(arb_awvalid),
//     .xbar_awready(xbar_awready),
//     .arb_wdata(arb_wdata),
//     .arb_wvalid(arb_wvalid),
//     .arb_wstrb(arb_wstrb),
//     .xbar_wready(xbar_wready),
//     .xbar_bresp(xbar_bresp),
//     .xbar_bvalid(xbar_bvalid),
//     .arb_bready(arb_bready),
    
//     .sram_araddr(sram_araddr),
//     .sram_arvalid(sram_arvalid),
//     .sram_arready(sram_arready),
//     .sram_rdata(sram_rdata),
//     .sram_rresp(sram_rresp),
//     .sram_rvalid(sram_rvalid),
//     .sram_rready(sram_rready),
    
//     .sram_awaddr(sram_awaddr),
//     .sram_awvalid(sram_awvalid),
//     .sram_awready(sram_awready),
//     .sram_wdata(sram_wdata),
//     .sram_wvalid(sram_wvalid),
//     .sram_wstrb(sram_wstrb),
//     .sram_wready(sram_wready),
//     .sram_bresp(sram_bresp),
//     .sram_bvalid(sram_bvalid),
//     .sram_bready(sram_bready),
    

//     .uart_araddr(uart_araddr),
//     .uart_arvalid(uart_arvalid),
//     .uart_arready(uart_arready),
//     .uart_rdata(uart_rdata),
//     .uart_rresp(uart_rresp),
//     .uart_rvalid(uart_rvalid),
//     .uart_rready(uart_rready),
    
//     .uart_awaddr(uart_awaddr),
//     .uart_awvalid(uart_awvalid),
//     .uart_awready(uart_awready),
//     .uart_wdata(uart_wdata),
//     .uart_wvalid(uart_wvalid),
//     .uart_wstrb(uart_wstrb),
//     .uart_wready(uart_wready),
//     .uart_bresp(uart_bresp),
//     .uart_bvalid(uart_bvalid),
//     .uart_bready (uart_bready),

//     .clint_araddr(clint_araddr),
//     .clint_arvalid(clint_arvalid),
//     .clint_arready(clint_arready),
//     .clint_rdata(clint_rdata),
//     .clint_rresp(clint_rresp),
//     .clint_rvalid(clint_rvalid),
//     .clint_rready(clint_rready),
        
//     .clint_awaddr(clint_awaddr),
//     .clint_awvalid(clint_awvalid),
//     .clint_awready(clint_awready),
//     .clint_wdata(clint_wdata),
//     .clint_wvalid(clint_wvalid),
//     .clint_wstrb(clint_wstrb),
//     .clint_wready(clint_wready),
//     .clint_bresp(clint_bresp),
//     .clint_bvalid(clint_bvalid),
//     .clint_bready (clint_bready)
// );

// // 存储器
// ysyx_25080204_DataMemory SRAM (
//     .clk(clk),
//     .rst(rst),

//     .araddr(sram_araddr),      
//     .arvalid(sram_arvalid),   
//     .arready(sram_arready),
    
//     .rdata(sram_rdata),
//     .rresp(sram_rresp),
//     .rvalid(sram_rvalid),
//     .rready(sram_rready),    
    
//     .awaddr(sram_awaddr),    
//     .awvalid(sram_awvalid),   
//     .awready(sram_awready),
    
//     .wdata(sram_wdata),     
//     .wstrb(sram_wstrb),      
//     .wvalid(sram_wvalid),    
//     .wready(sram_wready),
    
//     .bresp(sram_bresp),
//     .bvalid(sram_bvalid),
//     .bready(sram_bready)     
// );

// //外设1：UART
// ysyx_25080204_UART UART (
//     .clk(clk),
//     .rst(rst),

//     .araddr(uart_araddr),      
//     .arvalid(uart_arvalid),   
//     .arready(uart_arready),
    
//     .rdata(uart_rdata),
//     .rresp(uart_rresp),
//     .rvalid(uart_rvalid),
//     .rready(uart_rready),    
    
//     .awaddr(uart_awaddr),    
//     .awvalid(uart_awvalid),   
//     .awready(uart_awready),
    
//     .wdata(uart_wdata),     
//     .wstrb(uart_wstrb),      
//     .wvalid(uart_wvalid),    
//     .wready(uart_wready),
    
//     .bresp(uart_bresp),
//     .bvalid(uart_bvalid),
//     .bready(uart_bready)     
// );

// //外设2：CLINT
// ysyx_25080204_CLINT CLINT (
//     .clk(clk),
//     .rst(rst),

//     .araddr(clint_araddr),      
//     .arvalid(clint_arvalid),   
//     .arready(clint_arready),
        
//     .rdata(clint_rdata),
//     .rresp(clint_rresp),
//     .rvalid(clint_rvalid),
//     .rready(clint_rready),    
        
//     .awaddr(clint_awaddr),    
//     .awvalid(clint_awvalid),   
//     .awready(clint_awready),
        
//     .wdata(clint_wdata),     
//     .wstrb(clint_wstrb),      
//     .wvalid(clint_wvalid),    
//     .wready(clint_wready),
        
//     .bresp(clint_bresp),
//     .bvalid(clint_bvalid),
//     .bready(clint_bready) 
// );

// wire r_idle_to_r_wait=DM_r_en&&will_stall;
// wire r_wait_to_r_idle=lsu_rvalid && lsu_rready;


// // 数据存储器读请求
// always @(posedge clk or posedge rst) begin
//     if(rst) begin
//         lsu_arvalid_reg <= 1'b0;
//         lsu_araddr_reg <= 32'b0;
//         lsu_rready_reg <= 1'b0;
//         rdata_from_dm_reg <= 32'b0;
//         r_stall <= 1'b0;
//         r_state <= R_IDLE;
//     end else begin
//         case(r_state)
//             R_IDLE: begin
//                 if(r_idle_to_r_wait) begin
//                     lsu_arvalid_reg <= 1'b1;
//                     lsu_araddr_reg <= w_r_addr;
//                     lsu_rready_reg <= 1'b1;
//                     r_stall <= 1'b1;
//                     r_state <= R_WAIT;
//                 end
//             end
//             R_WAIT: begin
//                 if(r_wait_to_r_idle) begin
//                     rdata_from_dm_reg <= lsu_rdata;
//                     lsu_rresp_reg<=lsu_rresp;
//                     lsu_arvalid_reg <= 1'b0;
//                     lsu_rready_reg <= 1'b0;
//                     r_stall <= 1'b0;
//                     r_state <= R_IDLE;
//         //$display("[CLK %0t]LSU handshake with SRAM! READ the data=0x%08x ", $time,lsu_rdata);
//                 end
//             end
//             default:begin end
//         endcase
//     end 
// end

// // 数据存储器写请求
// always @(posedge clk or posedge rst) begin
//     if(rst) begin
//         lsu_awvalid_reg <= 1'b0;
//         lsu_awaddr_reg <= 32'b0;
//         lsu_wvalid_reg <= 1'b0;
//         lsu_wdata_reg <= 32'b0;
//         lsu_wstrb_reg <= 2'b0;
//         lsu_bready_reg <= 1'b0;
//         w_stall <= 1'b0;
//         w_state <= W_IDLE;
//     end else begin
//         case(w_state)
//             W_IDLE: begin
//                 if(DM_w_en&&will_stall) begin//忘记设计stall状态的处理，导致多次写数据
//                     lsu_awvalid_reg <= 1'b1;
//                     lsu_awaddr_reg <= w_r_addr;
//                     lsu_wvalid_reg <= 1'b1;
//                     lsu_wdata_reg <= wdata_from_reg;
//                     lsu_wstrb_reg <= mem_mask;
//                     w_stall <= 1'b1;
//                     w_state <= W_WRITE;
//                 end
//             end
//             W_WRITE: begin
//               if(lsu_wready&&lsu_wvalid)begin
//                 lsu_bready_reg <= 1'b1;
//                 lsu_awvalid_reg <= 1'b0;
//                 lsu_wvalid_reg <= 1'b0;
//                 w_state <= W_BRESP;
//               end
//             end
//             W_BRESP: begin
//                 if(lsu_bvalid && lsu_bready) begin
//                     lsu_bresp_reg<=lsu_bresp;
//                     lsu_bready_reg <= 1'b0;
//                     w_stall <= 1'b0;
//                     w_state <= W_IDLE;
//                 end 
//             end
//             default:begin end
//         endcase
//     end 
// end

// // 指令存储器读请求
// always @(posedge clk or posedge rst) begin
//     if(rst) begin
//         inst_arvalid_reg <= 1'b0;
//         inst_araddr_reg <= 32'b0;
//         inst_rready_reg <= 1'b0;
//         inst_reg <= 32'h00000013; 
//         inst_stall <= 1'b0;
//         inst_state <= INST_RESET;
//     end else begin
//         case(inst_state)
//             INST_RESET: begin
//                 inst_arvalid_reg <= 1'b1;
//                 inst_araddr_reg <= pc;
//                 inst_rready_reg <= 1'b1;
//                 inst_stall <= 1'b1;
//                 inst_state <= INST_WAIT;
//             end
//             INST_IDLE: begin
//                 if(!stall) begin
//                     inst_arvalid_reg <= 1'b1;
//                     inst_araddr_reg <= next_pc_for_inst;
//                     inst_rready_reg <= 1'b1;
//                     inst_stall <= 1'b1;
//                     inst_state <= INST_WAIT;
//                 end 
//             end
//             INST_WAIT: begin
//             // $display("[CLK %0t]CPU STATE:R_WAIT ", $time);
//                 if(inst_rvalid && inst_rready) begin
//                 //$display("[CLK %0t]IFU handshake with IM! GET inst=0x%08x", $time,inst_rdata);
//                     inst_reg <= inst_rdata;
//                     inst_rresp_reg<=inst_rresp;
//                     inst_arvalid_reg <= 1'b0;
//                     inst_rready_reg <= 1'b0;
//                     inst_stall <= 1'b0;
//                     inst_state <= INST_IDLE;
//                 end 
//             end
//             default:begin end
//         endcase
//     end 
// end

// assign load = (inst_rdata[6:0]==7'b0000011)&&inst_rvalid;//和rvalid进行与，这样在读完指令后不会一直保持有效
// assign store = (inst_rdata[6:0]==7'b0100011)&&inst_rvalid;
// always @(posedge clk or posedge rst) begin
//     if(rst)will_stall<=1'b0;
//     else if(will_stall)will_stall<=1'b0;//保证只持续一周期
//     else will_stall<=load||store;
// end
// // stall信号组合逻辑
// always @(posedge clk or posedge rst) begin
//     check<=~stall;
// end
// assign stall = r_stall || w_stall || inst_stall || will_stall;

// // ebreak处理
// import "DPI-C" function void npc_ebreak_finish();
// always @(*) begin
//     if(inst == 32'h100073) begin  // ebreak指令
//         npc_ebreak_finish();
//         $display("[CLK %0t] ebreak", $time);
//     end
// end

// endmodule
