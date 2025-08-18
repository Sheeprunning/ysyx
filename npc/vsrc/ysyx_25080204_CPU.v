module ysyx_25080204_CPU(
    input clk,
    input rst,
    input [31:0]inst,
    output [31:0]result,
    output Zero,
    output Overflow,
    output CF,
    output [31:0]a0,
    output [31:0]pc
);

wire [31:0]next_pc;

wire [3:0]alu_op;
wire [31:0]A;
wire [31:0]B;
// wire Zero;
// wire Overflow;
// wire CF;

wire [4:0]rd;
wire [4:0]rs1;
wire [4:0]rs2;
wire [6:0]opcode;
wire [31:0]imm_num;
wire [6:0]func7;
wire [2:0]func3;
wire ALU_A_sel;
wire ALU_B_sel;
wire rf_w;

wire [31:0]src1;
wire [31:0]src2;


ysyx_25080204_pc PC(
    .next_pc(next_pc),
    .clk(clk),
    .rst(rst),
    .pc(pc)
);

ysyx_25080204_next_pc dnpc(
    .rst(rst),
    .pc(pc),
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
    .wdata(result),
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
    .rf_w(rf_w)
);

assign A=ALU_A_sel?src1:pc;
assign B=ALU_B_sel?src2:imm_num;
assign a0=RF.rf[10];

ysyx_25080204_ALU ALU(
    .opcode(alu_op),
    .A(A),
    .B(B),
    .result(result),
    .Zero(Zero),
    .Overflow(Overflow),
    .CF(CF)
);
endmodule
