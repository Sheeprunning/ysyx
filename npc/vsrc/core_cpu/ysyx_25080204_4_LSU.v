module ysyx_25080204_4_LSU (
    input           clk,
    input           rst,

    input           lsu_en,//will_stall
    input           DM_r_en,
    
    input   [31:0]  w_r_addr,
    output  [31:0]  rdata_from_dm,
    output  [3:0]   mem_mask,
    output  reg     r_stall,

    input           DM_w_en,
    input   [2:0]   size,
    input   [31:0]  wdata_from_reg,
    output  reg     w_stall,
    
    // AR
    output  [31:0]  lsu_araddr,
    output  [2:0]   lsu_arsize,
    output          lsu_arvalid,
    input           lsu_arready,
    
    // R
    input   [31:0]  lsu_rdata,
    input   [1:0]   lsu_rresp,
    input           lsu_rvalid,
    output          lsu_rready,
    
    // AW
    output  [31:0] lsu_awaddr,
    output  [2:0]  lsu_awsize,
    output         lsu_awvalid,
    input           lsu_awready,
    
    // W
    output  [31:0]  lsu_wdata,
    output  [3:0]   lsu_wstrb,
    output          lsu_wvalid,
    input           lsu_wready,
    
    // B
    input           lsu_bvalid,
    input   [1:0]   lsu_bresp,
    output          lsu_bready
);


//AR
reg [31:0] lsu_araddr_reg;
reg [2:0]  lsu_arsize_reg;
reg        lsu_arvalid_reg;
//R
reg [31:0] rdata_from_dm_reg;
/* verilator lint_off UNUSEDSIGNAL */
reg [1:0]  lsu_rresp_reg;
/* verilator lint_on UNUSEDSIGNAL */
reg        lsu_rready_reg;

//AW
reg [31:0] lsu_awaddr_reg;
reg [2:0]  lsu_awsize_reg;
reg        lsu_awvalid_reg;

//W
reg [31:0] lsu_wdata_reg;
reg [3:0]  lsu_wstrb_reg;
reg        lsu_wvalid_reg;

//B
reg        lsu_bready_reg;
/* verilator lint_off UNUSEDSIGNAL */
reg [1:0]  lsu_bresp_reg;
/* verilator lint_on UNUSEDSIGNAL */


reg [1:0] r_state, w_state;

localparam R_IDLE = 2'b00;
localparam R_WAIT = 2'b01;
localparam W_IDLE = 2'b00;
localparam W_WRITE = 2'b01;
localparam W_BRESP = 2'b10;

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
assign lsu_arsize = lsu_arsize_reg;

wire lsu_read_begin     =   DM_r_en     &&  lsu_en;
wire lsu_ar_handshake   =   lsu_arready &&  lsu_arvalid;
wire lsu_r_handshake    =   lsu_rvalid  &&  lsu_rready;


wire [1:0] byte_offset = w_r_addr[1:0]; 
wire [3:0] b_mask=(byte_offset==2'b00)?4'b0001:
            (byte_offset==2'b01)?4'b0010:
            (byte_offset==2'b10)?4'b0100:
            (byte_offset==2'b11)?4'b1000:4'b0000;
wire [3:0] h_mask=(byte_offset==2'b00)?4'b0011:
            (byte_offset==2'b10)?4'b1100:4'b0000;

assign mem_mask=(size==3'b000)?b_mask:
                (size==3'b001)?h_mask:
                (size==3'b010)?4'b1111:
                              4'b0000;
reg [31:0]wdata;

always @(*) begin
  case(size)
    3'b000: wdata = {4{wdata_from_reg[7:0]}};
    3'b001: wdata = {2{wdata_from_reg[15:0]}};
    3'b010: wdata = wdata_from_reg;
    default:  wdata = 32'hdeadbeef;
  endcase
end

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
                if(lsu_read_begin) begin
                    lsu_arvalid_reg <= 1'b1;
                    lsu_araddr_reg <= w_r_addr;
                    lsu_arsize_reg <= size;
                    lsu_rready_reg <= 1'b1;
                    r_stall <= 1'b1;
                    r_state <= R_WAIT;
                end
            end
            R_WAIT: begin
                if(lsu_ar_handshake)
                    lsu_arvalid_reg<=1'b0;
                if(lsu_r_handshake) begin
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


wire lsu_write_begin    =   DM_w_en     &&  lsu_en;//表示lsu开始写数据
wire lsu_aw_handshake   =   lsu_awready &&  lsu_awvalid;
wire lsu_w_handshake    =   lsu_wready  &&  lsu_wvalid;
wire lsu_b_handshake    =   lsu_bvalid  &&  lsu_bready;
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
                if(lsu_write_begin) begin
                    lsu_awvalid_reg <= 1'b1;
                    lsu_awsize_reg<= size;
                    lsu_awaddr_reg <= w_r_addr;
                    lsu_wvalid_reg <= 1'b1;
                    lsu_wdata_reg <= wdata;
                    lsu_wstrb_reg <= mem_mask;
                    w_stall <= 1'b1;
                    w_state <= W_WRITE;
                end
            end
            W_WRITE: begin
                if(lsu_aw_handshake)
                    lsu_awvalid_reg <= 1'b0;
                if(lsu_w_handshake)begin
    // $display("\033[0;32m[CLK %0t]LSU handshake write with MEM! addr=0x%08x data=0x%08x strb=%04b size=%03b\033[0m", $time,lsu_awaddr_reg,lsu_wdata_reg,lsu_wstrb_reg,lsu_awsize);
                    lsu_bready_reg <= 1'b1;
                    lsu_wvalid_reg <= 1'b0;
                    w_state <= W_BRESP;
                end
            end
            W_BRESP: begin
                if(lsu_b_handshake) begin
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
endmodule
