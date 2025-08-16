module ysyx_25080204_ALU(
    input reg [3:0]opcode,
    input reg [31:0]A,B,
    output reg [31:0]result,
    output reg Zero,
    output reg Overflow,
    output reg CF
);
wire [31:0]B_neg,add_result,sub_result,and_result,or_result,xor_result;

assign B_n=b^{32{opcode[0]}}+opcode[0];//({n{Cin}} ^ B) + Cin;一般补码是这样的
assign {CF,add_result}={1'b0,A}+{1'b0,B_n};
assign sub_result=add_result;
assign Overflow=(A[31]==b_n[31])&&(A[31]!=add_result[31]);
assign not_result=A^{32{1'b1}};
assign and_result=A&B;
assign or_result=A|B;
always@(*)begin
    case(opcode)
        3'b0000:result=add_result;
        3'b0001:result=sub_result;
        3'b0010:result=add_result;
        3'b0011:result=or_result;
        3'b0100:result=xor_result;
        default:result=0;
    endcase
end
assign Zero=~(|result);


endmodule
