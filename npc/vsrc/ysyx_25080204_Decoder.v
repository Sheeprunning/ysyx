module ysyx_25080204_Decoder (
    input [31:0] inst,
    output [4:0]rd,
    output [4:0]rs1,
    output [4:0]rs2,
    output [6:0]opcode,
    output reg [31:0]imm_num,
    output [6:0]func7,
    output [2:0]func3    
);
    
    assign rs1=inst[19:15];
    assign rs2=inst[24:20];
    assign rd=inst[11:7];
    assign opcode=inst[6:0];
    assign func7=inst[31:25];
    assign func3=inst[14:12];
    //预先并行处理立即数
    wire [31:0] i_imm = {{20{inst[31]}},inst[31:20]};;
    wire [31:0] u_imm = {inst[31:12], 12'b0};
    wire [31:0] b_imm = {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
    wire [31:0] j_imm = {{12{inst[31]}},inst[19:12],inst[20],inst[30:21],1'b0};
    wire [31:0] s_imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
    
    //wire is_r_type = (opcode == 7'b0110011);  // R-type
    wire is_i_type = (opcode == 7'b0000011 ||  // LOAD
                 opcode == 7'b0010011 ||  // 立即数运算 (ADDI, ANDI, etc.)
                 opcode == 7'b1100111);     //I-type 
    wire is_s_type = (opcode == 7'b0100011);//S-type
    wire is_b_type = (opcode == 7'b1100011);//B-type
    wire is_u_type = (opcode == 7'b0110111 ||  // LUI
                 opcode == 7'b0010111);//auipc
    wire is_j_type = (opcode == 7'b1101111);//J-type

    
    always @(*) begin
        if      (is_i_type) imm_num = i_imm;
        else if (is_b_type) imm_num = b_imm;
        else if (is_j_type) imm_num = j_imm;
        else if (is_s_type) imm_num = s_imm;
        else if (is_u_type) imm_num = u_imm;
        else                imm_num = 32'hdeadbbbb;
    end

    //ai建议的：添加判断是否非法
    // wire illegal_inst = !(is_r_type || is_i_type || is_s_type || 
    //                      is_b_type || is_u_type || is_j_type);
    // output illegal;
    
endmodule
