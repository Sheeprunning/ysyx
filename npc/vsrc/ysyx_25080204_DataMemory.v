module ysyx_25080204_DataMemory(
    input clk,
    input rst,
    input DM_r_en,
    input DM_w_en,
    input [31:0]raddr,
    input [31:0]waddr,
    input [31:0]wdata,
    input [1:0]mask,
    output reg [31:0]rdata
);


import "DPI-C" function int pmem_read_v(input int raddr);
import "DPI-C" function void pmem_write_v(
  input int waddr_t, input int len , input int wdata );

reg [31:0] waddr_t,wdata_t;
reg [31:0] len,len_t;
reg write_ready;

always @(*)begin
    case(mask)
        2'b00:len=1;
        2'b01:len=2;
        2'b10:len=4;
        default:len=0;
    endcase
end

always @(*) begin
    if (DM_r_en&&raddr>32'h80000000 && raddr<32'h88000000) begin // 有读请求时
         $display("[CLK %0t] READ: DM[%0x]", $time, raddr);
        rdata = pmem_read_v(raddr);
    end
    else begin
        rdata = 32'hdeaddddd;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        write_ready <= 0;
        waddr_t <= 0;
        wdata_t <= 0;
        len_t <= 0;
    end else begin
        write_ready <= DM_w_en;
        if (DM_w_en) begin
            waddr_t <= waddr;
            wdata_t <= wdata;
            len_t <= len;
        end
        
    end
end
always@(*)begin
  if(write_ready)begin
            pmem_write_v(waddr_t, len_t, wdata_t);
            $display("[CLK %0t] Write: DM[%0x] = 0x%08x ", $time, waddr_t, wdata_t);
        end
end
endmodule

