module ALU(
    input reg [2:0]opcode,
    input reg [31:0]A,B,
    output reg [31:0]result,
    output reg Zero,
    output reg Overflow,
    output reg CF
);

always@(*)begin
    Overflow=0;
    CF=0;
    Zero=0;
    case(opcode)
        3'b000:begin 
            {CF,result}={1'b0,A}+{1'b0,B};
            Overflow=(A[31]==(B[31]))&&(A[31]!=result[31]);
            Zero=~(|result);
        end
        3'b001:begin 
            {CF,result}={1'b0,A}-{1'b0,B};//({n{Cin}} ^ B) + Cin;一般补码是这样的
            Overflow=(A[31]==((~B[31]+1)))&&(A[31]!=result[31]);
            Zero=~(|result);
        end
        3'b010:result=A^{32{1'b1}};
        3'b011:result=A&B;
        3'b100:result=A|B;
        3'b101:result=A^B;
        3'b110:begin
            {CF,result}={1'b0,A}-{1'b0,B};
            Overflow=(A[31]==((~B[31]+1)))&&(A[31]!=result[31]);
            result={31'b0,Overflow^result[31]};
        end
        default:result=0;
    endcase
end

endmodule
