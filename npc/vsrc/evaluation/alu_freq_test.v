module alu_freq_test (
    input        clk,
    input  [3:0] op,
    input  [31:0] a,
    input  [31:0] b,
    output reg [31:0] r
);

    // ===== 输入寄存器 =====
    reg [3:0]  op_r;
    reg [31:0] a_r;
    reg [31:0] b_r;

    always @(posedge clk) begin
        op_r <= op;
        a_r  <= a;
        b_r  <= b;
    end

    // ===== ALU 组合逻辑 =====
    wire [31:0] result;

    ysyx_25080204_ALU u_alu (
        .opcode(op_r),
        .A(a_r),
        .B(b_r),
        .result(result),
        .Zero(),
        .Overflow(),
        .CF()
    );

    // ===== 输出寄存器 =====
    always @(posedge clk) begin
        r <= result;
    end

endmodule

module ysyx_25080204_ALU(
    input  [3:0]opcode,
    input  [31:0]A,B,
    output reg [31:0]result,
    output  Zero,
    output  Overflow,
    output  CF
);
localparam ALU_ADD = 4'b0000, ALU_SUB = 4'b0001, 
        ALU_AND = 4'b0010, ALU_OR = 4'b0011,
        ALU_XOR = 4'b0100, ALU_SLL = 4'b0101,
        ALU_SRL = 4'b0110, ALU_SRA = 4'b1000,
        ALU_SLT = 4'b1001, ALU_SLTU = 4'b1010;


wire [31:0] B_n;
wire [31:0] add_result;
wire [31:0] sub_result;
wire [31:0] and_result;
wire [31:0] or_result;
wire [31:0] xor_result;
wire [31:0] sll_result;
wire [31:0] srl_result;
wire [31:0] sra_result;
wire [31:0]slt_result;
wire [31:0]sltu_result;

assign B_n={B^{32{opcode[0]}}}+{31'b0,opcode[0]};//({n{Cin}} ^ B) + Cin;一般补码是这样的
assign {CF,add_result}={1'b0,A}+{1'b0,B_n};
assign sub_result=add_result;
assign Overflow=(A[31]==B_n[31])&&(A[31]!=add_result[31]);
assign and_result=A&B;
assign or_result=A|B;
assign xor_result=A^B;
assign sll_result=A<<B[4:0];
assign srl_result=A>>B[4:0];
assign sra_result=$signed(A)>>>B[4:0];
assign slt_result={31'b0,$signed(A)<$signed(B)};
assign sltu_result={31'b0,A<B};
always@(*)begin
    case(opcode)
        ALU_ADD:result=add_result;
        ALU_SUB:result=sub_result;
        ALU_AND:result=and_result;
        ALU_OR:result=or_result;
        ALU_XOR:result=xor_result;
        ALU_SLL:result=sll_result;
        ALU_SRL:result=srl_result;
        ALU_SRA:result=sra_result;
        ALU_SLT:result=slt_result;
        ALU_SLTU:result=sltu_result;
        default:result=0;
    endcase
end
assign Zero=~(|result);



endmodule
