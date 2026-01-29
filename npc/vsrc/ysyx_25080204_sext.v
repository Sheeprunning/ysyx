module ysyx_25080204_sext (
    input sext_en,//1表示有符号扩展
    input [1:0]mask,
    input [31:0]sext_data,
    output reg [31:0] sext_out_data
);

wire [31:0]Sext_B_signed={{24{sext_data[7]}},sext_data[7:0]};
wire [31:0]Sext_H_signed={{16{sext_data[15]}},sext_data[15:0]};
wire [31:0]Sext_B_unsigned={{24{1'b0}},sext_data[7:0]};
wire [31:0]Sext_H_unsigned={{16{1'b0}},sext_data[15:0]};
always @(*) begin
    if(sext_en)begin
        case(mask)
            2'b00:begin 
                sext_out_data=Sext_B_signed;
            end 
            2'b01:begin 
                sext_out_data=Sext_H_signed;
            end
            default:begin
                sext_out_data=sext_data;
            end
                
        endcase
    end
    else begin
        case(mask)
            2'b00:begin 
                sext_out_data=Sext_B_unsigned;
            end 
            2'b01:begin 
                sext_out_data=Sext_H_unsigned;
            end
            default:begin
                sext_out_data=sext_data;
            end
                
        endcase
    end
    
end
endmodule
