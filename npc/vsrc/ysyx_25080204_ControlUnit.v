module ysyx_25080204_ControlUnit(
    input [6:0]opcode,
    input [6:0]func7,
    input [2:0]func3,
    output reg [3:0]alu_op,
    output reg ALU_A_sel,
    output reg ALU_B_sel,
    output reg rf_w
);

localparam ALU_ADD = 4'b0000, ALU_SUB = 4'b0001, 
        ALU_AND = 4'b0010, ALU_OR = 4'b0011,
        ALU_XOR = 4'b0100, ALU_SLL = 4'b0101,
        ALU_SRL = 4'b0110, ALU_SRA = 4'b1000,
        ALU_SLT = 4'b1001, ALU_SLTU = 4'b1010,
        ALU_NULL = 4'b1111;
        // MASK_B = 2'b00,
        // MASK_H = 2'b01,
        // MASK_W = 2'b10,
        // MASK_NULL = 2'b11;

always @(*) begin
    case(opcode)
        7'b0110011:begin
                //R-type
                case({func7,func3})
                    {7'b0000000,3'b000}:alu_op=ALU_ADD;//add
                    {7'b0100000,3'b000}:alu_op=ALU_SUB;//sub
                    {7'b0000000,3'b001}:alu_op=ALU_SLL;//sll
                    {7'b0000000,3'b010}:alu_op=ALU_SLT;//slt
                    {7'b0000000,3'b011}:alu_op=ALU_SLTU;//sltu
                    {7'b0000000,3'b100}:alu_op=ALU_XOR;//xor
                    {7'b0000000,3'b101}:alu_op=ALU_SRL;//srl
                    {7'b0100000,3'b101}:alu_op=ALU_SRA;//sra
                    {7'b0000000,3'b110}:alu_op=ALU_OR;//or
                    {7'b0000000,3'b111}:alu_op=ALU_AND;//and
                    default: alu_op = ALU_NULL;
                endcase
            end
        7'b0010011:begin
                //I-type
                case(func3)
                    3'b000:alu_op=ALU_ADD;//addi
                    3'b010:alu_op=ALU_SLT;//slti
                    3'b011:alu_op=ALU_SLTU;//sltiu
                    3'b100:alu_op=ALU_XOR;//xori
                    3'b110:alu_op=ALU_OR;//ori
                    3'b111:alu_op=ALU_AND;//andi
                    3'b001:alu_op=(func7 == 7'b0000000)?ALU_SLL:ALU_NULL;//slli
                    3'b101:begin
                        case(func7)
                            7'b0000000:alu_op=ALU_SRL;//srli
                            7'b0100000:alu_op=ALU_SRA;//srai   
                            default: alu_op=ALU_NULL;
                        endcase
                    end
                    default:alu_op=ALU_NULL;
                    endcase
            end
        7'b0000011,7'b0100011,7'b1100111,
        7'b0010111,7'b1100011,7'b1101111://load,store,jalr,auipc,B-type,jal
            alu_op=ALU_ADD;
        default:
            alu_op=ALU_NULL;
    endcase
end    

//ALU_a_sel
always @(*) begin
    ALU_A_sel=(opcode==7'b1101111 || opcode==7'b0010111 ||opcode==7'b1100011)?0:1;//jal & auipc &B
end

//ALU_b_sel
always @(*) begin
    case(opcode)
        7'b0010011,7'b0000011,7'b0100011,
        7'b1100111,7'b1100011,7'b1101111, 7'b0010111://I-type & load & jalr & B-type & jal & auipc
            ALU_B_sel=0;
        default:
            ALU_B_sel=1;
    endcase
end

//rf_w
always @(*) begin
    case(opcode)
        7'b0100011,7'b1100011://S-type & B-Type
            rf_w=0;
        default:
            rf_w=1;
    endcase
end


endmodule
