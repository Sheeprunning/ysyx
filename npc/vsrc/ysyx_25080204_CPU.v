module ysyx_25080204_CPU(
    input clk,
    input rst,
    input [31:0]inst,
    output Zero,
    output Overflow,
    output CF,
    output [31:0]a0,
    output [31:0]pc
);

wire [31:0]next_pc;

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
wire [1:0]RF_data_sel;
wire DM_r_en;
wire DM_w_en;
wire [1:0]mask;
wire sext_en;

wire [31:0]A;
wire [31:0]B;
wire [31:0]result;
// wire Zero;
// wire Overflow;
// wire CF;

wire [31:0]rdata;

wire [31:0]sext_out_data;

ysyx_25080204_pc PC(
    .next_pc(next_pc),
    .clk(clk),
    .rst(rst),
    .pc(pc)
);

ysyx_25080204_next_pc dnpc(
    .rst(rst),
    .pc(pc),
    .bj_en(bj_en),
    .bj_addr(result),
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
    .mask(mask)
);

assign A=ALU_A_sel?src1:pc;
assign B=ALU_B_sel?src2:imm_num;
assign a0=RF.rf[10];

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

ysyx_25080204_ALU ALU(
    .opcode(alu_op),
    .A(A),
    .B(B),
    .result(result),
    .Zero(Zero),
    .Overflow(Overflow),
    .CF(CF)
);



ysyx_25080204_DataMemory DM(
    .clk(clk),
    .rst(rst),
    .DM_r_en(DM_r_en),
    .DM_w_en(DM_w_en),
    .raddr(result),
    .waddr(result),
    .wdata(src2),
    .mask(mask),
    .rdata(rdata)
);

ysyx_25080204_sext SEXT(
    .sext_en(sext_en),
    .mask(mask),
    .sext_data(rdata),
    .sext_out_data(sext_out_data)
);

assign RF_w_data=(RF_data_sel==2'b00)?result:(RF_data_sel==2'b01)?sext_out_data:(RF_data_sel==2'b10)?pc+4:imm_num;

endmodule
