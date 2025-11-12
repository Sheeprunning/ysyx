module ysyx_25080204_CSR(
    input clk,
    input rst,
    input stall,
    input wen,
    input en_ecall,
    input en_mret,
    input [2:0]csr_op,
    input [31:0]pc,
    input [1:0]cur_pri,//当前特权级
    input [31:0]raddr,
    input [31:0]waddr,
    input [31:0]wdata,
    output [31:0]rdata,
    output [31:0]next_pc 
);
localparam  MSTATUS =32'h300,   MTVEC = 32'h305,
            MEPC = 32'h341,     MCAUSE = 32'h342,
            MVENDORID = 32'hf11,MARCHID = 32'hf12;

localparam MIE=7,MPIE=3;

wire [31:0]csr_wdata ;
reg [31:0]mstatus,mtvec,mepc,mcause;
reg [31:0]mvendorid=32'h79737978;
reg [31:0]marchid=32'h17eb81c;
reg [31:0]e_cause;//环境调用异常号

assign csr_wdata = (csr_op == 3'b001) ? wdata :        // CSRRW: 直接写寄存器值
                   (csr_op == 3'b010) ? (rdata | waddr) : // CSRRS: 置位操作
                   (csr_op == 3'b011) ? (rdata & ~waddr) : // CSRRC: 清零操作
                   32'hdeaddddd;  

always@(*)begin
    case (cur_pri)
        2'b00:e_cause=32'd8;
        2'b01:e_cause=32'd9;
        2'b11:e_cause=32'd11;
        default: e_cause = 32'hdeadddd;
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst)begin
        mstatus<=32'h1800;
        mtvec<=32'h0;
        mepc<=32'h0;
        mcause<=32'h0;
    end
    if(stall)begin
      //保持
    end
    else if(en_ecall)begin
        mstatus<={
            mstatus[31:13], cur_pri,//MPP
            mstatus[10:8],  mstatus[MIE],//MPIE=MIE
            mstatus[6:4], 1'b0,//MIE
            mstatus[2:0]
            };
        mepc<=pc;
        mcause<=e_cause;
        //$display("[CLK %0t] ecall: mepc = 0x%08x,mecause = 0x%08x", $time, pc, e_cause);
        //切换为M特权级暂不知道如何实现
    end
    else if(en_mret)begin
        mstatus<={
            mstatus[31:8],
            1'b0,//MPIE
            mstatus[6:4],
            mstatus[MPIE],//MIE=MPIE
            mstatus[2:0]
            };
        // $display("[CLK %0t] mret: mepc = 0x%08x", $time, mepc);
        //把特权级切换为MPP暂未实现
    end
    else if(wen)begin
        // $display("[CLK %0t] Write: CSR[%0x] = 0x%08x ", $time, waddr, csr_wdata);
        case(waddr)
            MSTATUS:mstatus<=csr_wdata;
            MTVEC:mtvec<=csr_wdata;
            MEPC:mepc<=csr_wdata;
            MCAUSE:mcause<=csr_wdata;
        endcase
    end
end
assign rdata =  (raddr==MSTATUS)?mstatus:
                (raddr==MTVEC)?mtvec:
                (raddr==MEPC)?mepc:
                (raddr==MCAUSE)?mcause:
                (raddr==MVENDORID)?mvendorid:
                (raddr==MARCHID)?marchid:32'hdeadddd;

assign next_pc=en_ecall?mtvec:en_mret?mepc:32'b0;


endmodule
