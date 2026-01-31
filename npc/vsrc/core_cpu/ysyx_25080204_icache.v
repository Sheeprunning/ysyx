/* verilator lint_off  UNUSEDSIGNAL*/
module ysyx_25080204_icache #(
    parameter CACHE_OFFSET_W    =   2,
    parameter CACHE_INDEX_W    =   4
) (
    input clk,
    input rst,
    input inst_r_handshake,//表示ifu和外存握手取指成功
    input [31:0]inst_araddr,
    input [31:0]inst_rdata,
    input [31:0]i_addr,
    output reg [31:0]i_data,
    output reg i_rvalid
);

    parameter CACHE_INDEX = 2**CACHE_INDEX_W;
    parameter CACHE_TAG_W = 32 - CACHE_INDEX_W - CACHE_OFFSET_W;
    reg [2**CACHE_OFFSET_W*8-1:0] cache   [0:CACHE_INDEX -1];//存储数据的cache
    reg [CACHE_TAG_W-1:0]  tag  [0:CACHE_INDEX -1];//tag标志
    reg [CACHE_INDEX -1:0]valid;//有效位

    wire [CACHE_TAG_W-1:0]  tag_d   = i_addr[31 : CACHE_OFFSET_W+CACHE_INDEX_W];//输入数据的tag
    wire [CACHE_INDEX_W-1:0]index_d = i_addr[CACHE_OFFSET_W+CACHE_INDEX_W -1: CACHE_OFFSET_W];//输入数据的组号

    wire [CACHE_TAG_W-1:0]  tag_i   = inst_araddr[31 : CACHE_OFFSET_W+CACHE_INDEX_W];//输入数据的tag
    wire [CACHE_INDEX_W-1:0]index_i = inst_araddr[CACHE_OFFSET_W+CACHE_INDEX_W -1: CACHE_OFFSET_W];//输入数据的组号

    always @(posedge clk or posedge rst) begin
        if(rst)begin
            valid<={CACHE_INDEX{1'b0}};
        end
        else begin
            if(inst_r_handshake)begin
                valid[index_d]<=1'b1;
            end
        end
    end


    always @(posedge clk or posedge rst) begin
        if(rst)begin
            
        end
        else if(inst_r_handshake)begin//我认为对cache可以不用初始化，因为此时valid=0，可以为随机值
            cache[index_i]<=inst_rdata;
            tag[index_i]<=tag_i;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst)begin
            i_rvalid<=1'b0;
            i_data<=32'b0;
        end
        else begin
            if(valid[index_d]&&tag[index_d]==tag_d)begin//命中
                i_rvalid<=1'b1;
                i_data<=cache[index_d];
            end
            else begin
                i_rvalid<=1'b0;
            end
        end
    end

endmodule
/* verilator lint_on  UNUSEDSIGNAL*/
