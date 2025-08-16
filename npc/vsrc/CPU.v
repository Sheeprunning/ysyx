module ysyx_25080204_CPU(
    input clk,
    input rst,
    input [31:0]inst,
    output [31:0]result,
    output [31:0]pc
);

wire [3:0]ALU_opcode;
wire [31:0]A,B;
wire [31:0]result;
wire Zero;
wire Overflow;
wire CF;

wire [4:0]rd;
wire [4:0]rs1;
wire [4:0]rs2;
wire [6:0]opcode;
wire [31:0]imm_num;
wire [6:0]func7;
wire [2:0]func3;
wire ALU_A_sel;
wire ALU_B_sel;

ysyx_25080204_pc PC(
    .next_pc(next_pc),
    .clk(clk),
    .rst(rst),
    .pc(pc),
);

ysyx_25080204_next_pc dnpc(
    .clk(clk),
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
    .func3(fun3)    
);

ysyx_25080204_ControlUnit CU(
    .opcode(opcode),
    .func7(func7),
    .func3(fun3),
    .ALU_opcode(ALU_opcode),
    .ALU_A_sel(ALU_A_sel),
    .ALU_B_sel(ALU_B_sel)
);

assign A=ALU_A_sel?src1:pc;
assign A=ALU_B_sel?src2:imm_num;

ysyx_25080204_ALU ALU(
    .opcode(ALU_opcode)
    .A(A),
    .B(B),
    .result(result),
    .Zero(Zero),
    .Overflow(Overflow),
    .CF(CF)
);
endmodule