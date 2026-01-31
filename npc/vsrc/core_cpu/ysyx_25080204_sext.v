module ysyx_25080204_sext (
    input sext_en,//1表示有符号扩展
    input [3:0]mask,
    input [31:0]sext_data,
    output reg [31:0] sext_out_data
);

wire [31:0]Sext_B_signed_0={{24{sext_data[7]}},sext_data[7:0]};
wire [31:0]Sext_B_signed_1={{24{sext_data[15]}},sext_data[15:8]};
wire [31:0]Sext_B_signed_2={{24{sext_data[23]}},sext_data[23:16]};
wire [31:0]Sext_B_signed_3={{24{sext_data[31]}},sext_data[31:24]};
wire [31:0]Sext_H_signed_0={{16{sext_data[15]}},sext_data[15:0]};
wire [31:0]Sext_H_signed_2={{16{sext_data[31]}},sext_data[31:16]};
wire [31:0]Sext_B_unsigned_0={{24{1'b0}},sext_data[7:0]};
wire [31:0]Sext_B_unsigned_1={{24{1'b0}},sext_data[15:8]};
wire [31:0]Sext_B_unsigned_2={{24{1'b0}},sext_data[23:16]};
wire [31:0]Sext_B_unsigned_3={{24{1'b0}},sext_data[31:24]};
wire [31:0]Sext_H_unsigned_0={{16{1'b0}},sext_data[15:0]};
wire [31:0]Sext_H_unsigned_2={{16{1'b0}},sext_data[31:16]};
always @(*) begin
    if(sext_en)begin
        case(mask)
            4'b0001:begin 
                sext_out_data=Sext_B_signed_0;
            end 
            4'b0010:begin 
                sext_out_data=Sext_B_signed_1;
            end
            4'b0100:begin 
                sext_out_data=Sext_B_signed_2;
            end
            4'b1000:begin 
                sext_out_data=Sext_B_signed_3;
            end
            4'b0011:begin 
                sext_out_data=Sext_H_signed_0;
            end
            4'b1100:begin 
                sext_out_data=Sext_H_signed_2;
            end
            default:begin
                sext_out_data=sext_data;
            end
                
        endcase
    end
    else begin
        case(mask)
            4'b0001:begin 
                sext_out_data=Sext_B_unsigned_0;
            end 
            4'b0010:begin 
                sext_out_data=Sext_B_unsigned_1;
            end 
            4'b0100:begin 
                sext_out_data=Sext_B_unsigned_2;
            end 
            4'b1000:begin 
                sext_out_data=Sext_B_unsigned_3;
            end 
            4'b0011:begin 
                sext_out_data=Sext_H_unsigned_0;
            end
            4'b1100:begin 
                sext_out_data=Sext_H_unsigned_2;
            end
            default:begin
                sext_out_data=sext_data;
            end
                
        endcase
    end
    
end
endmodule
