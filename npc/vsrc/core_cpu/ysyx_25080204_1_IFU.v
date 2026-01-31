module ysyx_25080204_1_IFU(
    input clk,
    input rst,
    input stall,
    input [31:0]next_pc,
    output [31:0]pc,

    output reg inst_stall,
    output reg will_stall,//表示要lsu取数据

    output [31:0]inst,

    //AR
    input inst_arready,
    output [31:0] inst_araddr,
    output [2:0]  inst_arsize,
    output inst_arvalid,

    //R
    input inst_rvalid,
    input [31:0]inst_rdata,
    input [1:0]inst_rresp,
    output inst_rready
    
);

localparam INST_RESET = 2'b00;
localparam INST_IDLE  = 2'b01;
localparam INST_CACHE = 2'b10;
localparam INST_WAIT  = 2'b11;


//AR_INST
reg [31:0]  inst_araddr_reg;
reg [2:0]   inst_arsize_reg;
reg         inst_arvalid_reg;

//R_INST
reg [31:0] inst_reg;
/* verilator lint_off UNUSEDSIGNAL */
reg [1:0]  inst_rresp_reg;
/* verilator lint_on UNUSEDSIGNAL */
reg        inst_rready_reg;

reg [1:0]inst_state;

wire inst_ar_handshake  =   inst_arready    &&  inst_arvalid;
wire inst_r_handshake   =   inst_rvalid     &&  inst_rready;
wire inst_in_sram = next_pc[31:24]==8'h0f;

assign inst_arvalid = inst_arvalid_reg;
assign inst_arsize = inst_arsize_reg;
assign inst_rready = inst_rready_reg;
assign inst = inst_reg;
assign inst_araddr = inst_araddr_reg;

//icache 信号
wire [31:0]i_data;
wire i_rvalid;

ysyx_25080204_pc PC(
    .next_pc(next_pc),
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .pc(pc)
);

ysyx_25080204_icache icache (
    .clk(clk),
    .rst(rst),
    .inst_r_handshake(inst_r_handshake),//表示ifu和外存握手取指成功
    .inst_araddr(inst_araddr),
    .inst_rdata(inst_rdata),
    .i_addr(next_pc),
    .i_data(i_data),
    .i_rvalid(i_rvalid)
);

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
                    if(inst_in_sram)begin
                        inst_arvalid_reg <= 1'b1;
                        inst_araddr_reg <= next_pc;
                        inst_rready_reg <= 1'b1;
                        inst_stall <= 1'b1;
                        inst_state <= INST_WAIT;
                    end
                    else begin
                        inst_stall <= 1'b1;
                        inst_araddr_reg <= next_pc;
                        inst_state <= INST_CACHE;
                    end
                    
                end 
            end
            INST_CACHE: begin
                if(i_rvalid)begin//命中，直接给数据
                    inst_reg <= i_data;
                    inst_stall <= 1'b0;
                    inst_state <= INST_IDLE;
                end
                else begin//未命中，交给总线
                    inst_arvalid_reg <= 1'b1;
                    inst_rready_reg <= 1'b1;
                    inst_stall <= 1'b1;
                    inst_state <= INST_WAIT;
                end
            end
            INST_WAIT: begin
            // $display("[CLK %0t]CPU STATE:R_WAIT ", $time);
                if(inst_ar_handshake)
                    inst_arvalid_reg<=1'b0;
                if(inst_r_handshake) begin
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

wire load = (inst_rdata[6:0]==7'b0000011);
wire store = (inst_rdata[6:0]==7'b0100011);
wire inst_is_mem = load|store;
wire i_load = (i_data[6:0]==7'b0000011);
wire i_store = (i_data[6:0]==7'b0100011);
wire i_is_mem  = (inst_state==INST_CACHE) ? i_load|i_store:0;

wire is_mem_inst =
    inst_rvalid ? inst_is_mem :
    i_rvalid    ? i_is_mem    :
                  1'b0;

always @(posedge clk or posedge rst) begin
    if(rst)will_stall<=1'b0;
    else if(will_stall)will_stall<=1'b0;//保证只持续一周期
    else will_stall<=is_mem_inst;
end

endmodule
