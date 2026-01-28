
module ysyx_25080204_0_CPU(
    input clk,
    input rst,
    input [31:0]inst,
    input [31:0]rdata,
    input stall,
    output Zero,
    output Overflow,
    output CF,
    output DM_r_en,
    output DM_w_en,
    output [31:0]w_r_addr,
    output reg[31:0]wdata,
    output [3:0]mem_mask,
    output [2:0]size,
    output [31:0]a0,
    output [31:0]next_pc_for_inst,
    output [31:0]pc
);

wire [31:0]next_pc;

wire [1:0]current_privilege=2'b11;

wire [4:0]rd;
wire [4:0]rs1;
wire [4:0]rs2;
wire [2:0]func3;
wire [6:0]opcode;
wire [31:0]imm_num;


reg [31:0]RF_w_data;
wire [31:0]src1;
wire [31:0]src2;

wire [3:0]alu_op;
wire ALU_A_sel;
wire ALU_B_sel;
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


ysyx_25080204_1_IFU IFU(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .pc(pc),
    .next_pc(next_pc)
);


assign next_pc_for_inst=next_pc;

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
assign a0=RF.rf[10];

ysyx_25080204_3_EXE EXE(
    .clk(clk),
    .rst(rst),
    .stall(stall),

    .alu_op(alu_op),
    .A(A),
    .B(B),
    .result(result),
    .Zero(Zero),
    .Overflow(Overflow),
    .CF(CF),

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

assign w_r_addr=result;
always@(*)begin
  case(mem_mask)
    4'b0010:wdata=src2<<8;
    4'b0100:wdata=src2<<16;
    4'b1000:wdata=src2<<24;
    4'b1100:wdata=src2<<16;
    default:wdata=src2;
  endcase
end


ysyx_25080204_sext SEXT(
    .sext_en(sext_en),
    .mask(mem_mask),
    .sext_data(rdata),
    .sext_out_data(sext_out_data)
);
wire [1:0] byte_offset = w_r_addr[1:0]; 
wire [3:0] b_mask=(byte_offset==2'b00)?4'b0001:
            (byte_offset==2'b01)?4'b0010:
            (byte_offset==2'b10)?4'b0100:
            (byte_offset==2'b11)?4'b1000:4'b0000;
wire [3:0] h_mask=(byte_offset==2'b00)?4'b0011:
            (byte_offset==2'b10)?4'b1100:4'b0000;
assign mem_mask=(size==3'b00)?b_mask:(size==3'b01)?h_mask:(size==3'b10)?4'b1111:4'b0000;

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

// `ifdef sim
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
// `endif
endmodule
