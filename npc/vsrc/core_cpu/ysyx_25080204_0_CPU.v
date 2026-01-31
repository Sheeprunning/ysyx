
module ysyx_25080204_0_CPU(
    input clk,
    input rst,

    output  [31:0]      pc,
    output  [31:0]      inst,
    
    // IFU AXI接口
    // AR通道
    output  [31:0]      inst_araddr,
    output  [2:0]       inst_arsize,
    output              inst_arvalid,
    input               inst_arready,
    
    // R通道
    input   [31:0]      inst_rdata,
    input   [1:0]       inst_rresp,
    input               inst_rvalid,
    output              inst_rready,
    
    // LSU AXI接口
    // AR通道
    output  [31:0]      lsu_araddr,
    output  [2:0]       lsu_arsize,
    output              lsu_arvalid,
    input               lsu_arready,
    
    // R通道
    input   [31:0]      lsu_rdata,
    input   [1:0]       lsu_rresp,
    input               lsu_rvalid,
    output              lsu_rready,
    
    // AW通道
    output  [31:0]      lsu_awaddr,
    output  [2:0]       lsu_awsize,
    output              lsu_awvalid,
    input               lsu_awready,
    
    // W通道
    output  [31:0]      lsu_wdata,
    output  [3:0]       lsu_wstrb,
    output              lsu_wvalid,
    input               lsu_wready,
    
    // B通道
    input               lsu_bvalid,
    input   [1:0]       lsu_bresp,
    output              lsu_bready
);

wire [31:0]next_pc;

wire [1:0]current_privilege=2'b11;

wire [4:0]rd;
wire [4:0]rs1;
wire [4:0]rs2;
wire [2:0]func3;
/* verilator lint_off UNUSEDSIGNAL */
wire [6:0]opcode;
/* verilator lint_on UNUSEDSIGNAL */
wire [31:0]imm_num;


reg [31:0]RF_w_data;
wire [31:0]src1;
wire [31:0]src2;

wire [3:0]alu_op;
wire ALU_A_sel;
wire ALU_B_sel;
wire DM_r_en,DM_w_en;
wire [2:0]size;
wire rf_w;
wire [2:0]RF_data_sel;
wire bj_en;
wire sext_en;
wire CSR_wen;

wire [31:0]A;
wire [31:0]B;
wire [31:0]result;
// wire Zero;
// wire Overflow;
// wire CF;


wire [31:0]sext_out_data;

wire en_ecall;
wire en_mret;
wire csr_jen;
wire [31:0]csr_rdata;

wire [31:0]rdata_from_dm;
wire [3:0]mem_mask;

wire inst_stall;
wire will_stall;
wire r_stall;
wire w_stall;
wire stall = r_stall || w_stall || inst_stall || will_stall;;


ysyx_25080204_1_IFU IFU(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .pc(pc),
    .next_pc(next_pc),

    .inst_stall(inst_stall),
    .will_stall(will_stall),

    .inst(inst),

    .inst_arready(inst_arready),
    .inst_araddr(inst_araddr),
    .inst_arsize(inst_arsize),
    .inst_arvalid(inst_arvalid),

    .inst_rvalid(inst_rvalid),
    .inst_rdata(inst_rdata),
    .inst_rresp(inst_rresp),
    .inst_rready(inst_rready)
);



ysyx_25080204_2_IDU IDU(
    .inst(inst),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .func3(func3),
    .opcode(opcode),
    .imm_num(imm_num), 

    .alu_op(alu_op),
    .ALU_A_sel(ALU_A_sel),
    .ALU_B_sel(ALU_B_sel),
    .rf_w(rf_w),
    .RF_data_sel(RF_data_sel),
    .DM_r_en(DM_r_en),
    .DM_w_en(DM_w_en),
    .sext_en(sext_en),
    .CSR_wen(CSR_wen),
    .size(size),

    .src1(src1),
    .src2(src2),
    .bj_en(bj_en),

    .en_ecall(en_ecall),
    .en_mret(en_mret),
    .csr_jen(csr_jen)  
);

ysyx_25080204_RegisterFile RF (
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .wdata(RF_w_data),
    .waddr(rd),
    .rs1(rs1),
    .rs2(rs2),
    .wen(rf_w),
    .src1(src1),
    .src2(src2)
);


assign A=ALU_A_sel?src1:pc;
assign B=ALU_B_sel?src2:imm_num;
// assign a0=RF.rf[10];

ysyx_25080204_3_EXE EXE(
    .clk(clk),
    .rst(rst),
    .stall(stall),

    .alu_op(alu_op),
    .A(A),
    .B(B),
    .result(result),

    .CSR_wen(CSR_wen),
    .en_ecall(en_ecall),
    .en_mret(en_mret),
    .csr_op(func3),
    .pc(pc),
    .cur_pri(current_privilege),//当前特权级
    .CSR_raddr(imm_num),
    .CSR_waddr(imm_num),
    .CSR_wdata(src1),
    .CSR_rdata(csr_rdata),

    .bj_en(bj_en),
    .csr_jen(csr_jen),
    .bj_addr(result),
    .next_pc(next_pc)
);


ysyx_25080204_4_LSU LSU (
    .clk            (clk),
    .rst            (rst),
    
    .lsu_en         (will_stall),
    .DM_r_en        (DM_r_en),
    .DM_w_en        (DM_w_en),
    
    .w_r_addr       (result),
    .size           (size),
    .wdata_from_reg (src2),
    
    .mem_mask       (mem_mask),
    .rdata_from_dm  (rdata_from_dm),
    .r_stall        (r_stall),
    .w_stall        (w_stall),
    
    .lsu_araddr     (lsu_araddr),
    .lsu_arsize     (lsu_arsize),
    .lsu_arvalid    (lsu_arvalid),
    .lsu_arready    (lsu_arready),
    
    .lsu_rdata      (lsu_rdata),
    .lsu_rresp      (lsu_rresp),
    .lsu_rvalid     (lsu_rvalid),
    .lsu_rready     (lsu_rready),
    
    .lsu_awaddr     (lsu_awaddr),
    .lsu_awsize     (lsu_awsize),
    .lsu_awvalid    (lsu_awvalid),
    .lsu_awready    (lsu_awready),
    
    .lsu_wdata      (lsu_wdata),
    .lsu_wstrb      (lsu_wstrb),
    .lsu_wvalid     (lsu_wvalid),
    .lsu_wready     (lsu_wready),
    
    .lsu_bvalid     (lsu_bvalid),
    .lsu_bresp      (lsu_bresp),
    .lsu_bready     (lsu_bready)
);


ysyx_25080204_sext SEXT(
    .sext_en(sext_en),
    .mask(mem_mask),
    .sext_data(rdata_from_dm),
    .sext_out_data(sext_out_data)
);


always @(*) begin
  unique case (RF_data_sel)
    3'b000: RF_w_data = result;
    3'b001: RF_w_data = sext_out_data;
    3'b010: RF_w_data = pc + 4;
    3'b011: RF_w_data = imm_num;
    3'b100: RF_w_data = csr_rdata;
    default: RF_w_data = 32'hdeaddddd;
  endcase
end
/* synthesis translate_off */
`ifdef sim
always@(posedge clk)begin
    if(opcode==7'b1101111)begin//jal
      jal_ftrace({27'b0,rd},pc,result);
    end
    if(opcode==7'b1100111)begin//jalr
      jalr_ftrace(inst,{27'b0,rd},imm_num,pc,result);
    end
end

//performance counter


always @(posedge clk ) begin
  if(!stall&&alu_op!=4'b1111)
    performance_counter(32'd3);
end

always @(posedge clk) begin
  if(!stall)begin
    case(opcode)
        7'b0110011,7'b0010011,7'b0010111,7'b0110111://R,I,auipc,lui
            performance_counter(32'd4);
        // 7'b0000011://load
        //     performance_counter(32'd4);
        // 7'b0100011://store
        //     performance_counter(32'd5);
        7'b1100111,7'b1100011,7'b1101111://jalr & B-type & jal
            performance_counter(32'd5);
        7'b1110011://csr
            performance_counter(32'd6);
        default:begin   end
    endcase
  end
end
`endif
/* synthesis translate_on */
endmodule
