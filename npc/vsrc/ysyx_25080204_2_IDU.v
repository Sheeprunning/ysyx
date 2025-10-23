module ysyx_25080204_2_IDU(
    //decoder's signal
    input [31:0]inst,
    output [4:0]rd,
    output [4:0]rs1,
    output [4:0]rs2,
    output [2:0]func3,
    output [6:0]opcode,
    output [31:0]imm_num,
    //CU's signal
    output [3:0]alu_op,
    output ALU_A_sel,
    output ALU_B_sel,
    output rf_w,
    output [2:0]RF_data_sel,
    output sext_en,
    output CSR_wen,
    output [2:0]size,
    output DM_r_en,
    output DM_w_en,
    //judge the bj_en
    input [31:0]src1,
    input [31:0]src2,
    output bj_en,
    //CSR
    output en_ecall,
    output en_mret,
    output csr_jen
);

wire [6:0]func7;

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
    .size(size)
);
wire beq_taken=(src1==src2);
wire bne_taken=!beq_taken;
wire blt_taken=($signed(src1)<$signed(src2));
wire bge_taken=!blt_taken;
wire bltu_taken=(src1<src2);
wire bgeu_taken=!bltu_taken;
reg  bj_en_reg;
//bj_en
always @(*) begin
    case(opcode)
        7'b1100011:begin
            case(func3)
                3'b000: bj_en_reg = beq_taken;  // beq
                3'b001: bj_en_reg = bne_taken;  // bne
                3'b100: bj_en_reg = blt_taken;  // blt
                3'b101: bj_en_reg = bge_taken;  // bge
                3'b110: bj_en_reg = bltu_taken; // bltu
                3'b111: bj_en_reg = bgeu_taken; // bgeu
                default: bj_en_reg = 1'b0;      // 默认情况
            endcase
        end
        7'b1100111,7'b1101111: //jalr & jal
            bj_en_reg=1;
        default:
            bj_en_reg=0;
                    
    endcase
    
end
assign bj_en=bj_en_reg;
//CSR
assign en_ecall=(inst==32'h00000073);
assign en_mret=(inst==32'h30200073);
assign csr_jen=en_ecall|en_mret;

endmodule
