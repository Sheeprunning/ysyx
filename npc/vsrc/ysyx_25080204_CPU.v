module ysyx_25080204_CPU(
    input clk,
    input rst,
    input [31:0]inst,
    input [31:0]rdata,
    output Zero,
    output Overflow,
    output CF,
    output DM_r_en,
    output DM_w_en,
    output [31:0]w_r_addr,
    output [31:0]wdata,
    output [1:0]mem_mask,
    output [31:0]a0,
    output [31:0]pc
);

wire [31:0]next_pc;

wire [1:0]current_privilege=2'b11;

wire [4:0]rd;
wire [4:0]rs1;
wire [4:0]rs2;
wire [6:0]opcode;
wire [31:0]imm_num;
wire [6:0]func7;
wire [2:0]func3;

wire [31:0]RF_w_data;
wire [31:0]src1;
wire [31:0]src2;

wire [3:0]alu_op;
wire ALU_A_sel;
wire ALU_B_sel;
wire rf_w;
wire [2:0]RF_data_sel;

wire sext_en;
wire CSR_wen;
wire [1:0]mask;

wire [31:0]A;
wire [31:0]B;
wire [31:0]result;
// wire Zero;
// wire Overflow;
// wire CF;


wire [31:0]sext_out_data;

wire en_ecall;
wire en_mret;
wire [31:0]csr_npc;
wire csr_jen;
wire [31:0]csr_rdata;


ysyx_25080204_next_pc dnpc(
    .rst(rst),
    .pc(pc),
    .bj_en(bj_en),
    .csr_jen(csr_jen),
    .bj_addr(result),
    .csr_npc(csr_npc),
    .next_pc(next_pc)
);



ysyx_25080204_Decoder Decoder(
    .inst(inst),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .opcode(opcode),
    .imm_num(imm_num),
    .func7(func7),
    .func3(func3)    
);

assign wdata=src2;

ysyx_25080204_RegisterFile RF (
    .clk(clk),
    .rst(rst),
    .wdata(RF_w_data),
    .waddr(rd),
    .rs1(rs1),
    .rs2(rs2),
    .wen(rf_w),
    .src1(src1),
    .src2(src2)
);

ysyx_25080204_ControlUnit CU(
    .opcode(opcode),
    .func7(func7),
    .func3(func3),
    .alu_op(alu_op),
    .ALU_A_sel(ALU_A_sel),
    .ALU_B_sel(ALU_B_sel),
    .rf_w(rf_w),
    .RF_data_sel(RF_data_sel),
    .DM_r_en(DM_r_en),
    .DM_w_en(DM_w_en),
    .sext_en(sext_en),
    .CSR_wen(CSR_wen),
    .mask(mask)
);

assign A=ALU_A_sel?src1:pc;
assign B=ALU_B_sel?src2:imm_num;
assign a0=RF.rf[10];

assign mem_mask=mask;

wire beq_taken=(src1==src2);
wire bne_taken=!beq_taken;
wire blt_taken=($signed(src1)<$signed(src2));
wire bge_taken=!blt_taken;
wire bltu_taken=(src1<src2);
wire bgeu_taken=!bltu_taken;
reg bj_en;
//bj_en
always @(*) begin
    if(rst)bj_en=0;
    else begin
        case(opcode)
            7'b1100011:begin
                case(func3)
                    3'b000: bj_en = beq_taken;  // beq
                    3'b001: bj_en = bne_taken;  // bne
                    3'b100: bj_en = blt_taken;  // blt
                    3'b101: bj_en = bge_taken;  // bge
                    3'b110: bj_en = bltu_taken; // bltu
                    3'b111: bj_en = bgeu_taken; // bgeu
                    default: bj_en = 1'b0;      // 默认情况
                endcase
            end
            7'b1100111,7'b1101111: //jalr & jal
                bj_en=1;
            default:
                bj_en=0;
                        
        endcase
    end
end

assign en_ecall=(inst==32'h00000073);
assign en_mret=(inst==32'h30200073);
assign csr_jen=en_ecall|en_mret;

ysyx_25080204_ALU ALU(
    .opcode(alu_op),
    .A(A),
    .B(B),
    .result(result),
    .Zero(Zero),
    .Overflow(Overflow),
    .CF(CF)
);

assign w_r_addr=result;

ysyx_25080204_sext SEXT(
    .sext_en(sext_en),
    .mask(mask),
    .sext_data(rdata),
    .sext_out_data(sext_out_data)
);

ysyx_25080204_CSR CSR(
    .clk(clk),
    .rst(rst),
    .wen(CSR_wen),
    .en_ecall(en_ecall),
    .en_mret(en_mret),
    .csr_op(func3),
    .pc(pc),
    .cur_pri(current_privilege),//当前特权级
    .raddr(imm_num),
    .waddr(imm_num),
    .wdata(src1),
    .rdata(csr_rdata),
    .next_pc(csr_npc)
);

assign RF_w_data=(RF_data_sel==3'b000)?result:
                (RF_data_sel==3'b001)?sext_out_data:
                (RF_data_sel==3'b010)?pc+4:
                (RF_data_sel==3'b011)?imm_num:
                (RF_data_sel==3'b100)?csr_rdata:32'hdeaddddd;

import "DPI-C" function void jal_ftrace(input int rd,input int pc,input int target);
import "DPI-C" function void jalr_ftrace(
    input int inst,input int rd,input int imm,input int pc,input int target);
always@(posedge clk)begin
    if(opcode==7'b1101111)begin//jal
      jal_ftrace({27'b0,rd},pc,result);
    end
    if(opcode==7'b1100111)begin//jalr
      jalr_ftrace(inst,{27'b0,rd},imm_num,pc,result);
    end
end
endmodule
