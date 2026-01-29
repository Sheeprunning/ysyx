/*
	Copyright 2020 Efabless Corp.

	Author: Mohamed Shalan (mshalan@efabless.com)

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at:
	http://www.apache.org/licenses/LICENSE-2.0
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/
/*
    QSPI PSRAM Controller

    Pseudostatic RAM (PSRAM) is DRAM combined with a self-refresh circuit.
    It appears externally as slower SRAM, albeit with a density/cost advantage
    over true SRAM, and without the access complexity of DRAM.

    The controller was designed after https://www.issi.com/WW/pdf/66-67WVS4M8ALL-BLL.pdf
    utilizing both EBh and 38h commands for reading and writting.

    Benchmark data collected using CM0 CPU when memory is PSRAM only

        Benchmark       PSRAM (us)  1-cycle SRAM (us)   Slow-down
        ---------       ----------  -----------------   ---------
        xtea            840         212                 3.94
        stress          1607        446                 3.6
        hash            5340        1281                4.16
        chacha          2814        320                 8.8
        aes sbox        2370        322                 7.3
        nqueens         3496        459                 7.6
        mtrans          2171        2034                1.06
        rle             903         155                 5.8
        prime           549         97                  5.66
*/

`timescale              1ns/1ps
`default_nettype        none
`define OFFSET 6
/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSEDSIGNAL */
module PSRAM_READER (
    input   wire            clk,
    input   wire            rst_n,
    input   wire [23:0]     addr,
    input   wire            rd,
    input   wire [2:0]      size,
    output  wire            done,
    output  wire [31:0]     line,

    output  reg             sck,
    output  reg             ce_n,
    input   wire [3:0]      din,
    output  wire [3:0]      dout,
    output  wire            douten
);

    localparam  IDLE = 2'b0,
                READ = 2'b1,
                QPI  = 2'd2,
                INIT = 2'd3;
                

    wire [7:0]  FINAL_COUNT = 19 + size*2 - `OFFSET; // was 27: Always read 1 word
    wire [3:0]  dout_o,dout_qpi;


    reg [1:0]   state, nstate;
    reg [7:0]   counter;
    reg [23:0]  saddr;
    reg [7:0]   data [3:0];

    wire[7:0]   CMD_EBH = 8'heb;
    wire[7:0]   CMD_35H = 8'h35;

    always @*
        case (state)
            INIT: if(rd) nstate = QPI; else nstate = INIT;
            QPI : if(done) nstate = IDLE; else nstate = QPI;
            IDLE: if(rd) nstate = READ; else nstate = IDLE;
            READ: if(done) nstate = IDLE; else nstate = READ;
        endcase

    always @ (posedge clk or negedge rst_n)
        if(!rst_n) state <= INIT;
        else state <= nstate;

    // Drive the Serial Clock (sck) @ clk/2
    always @ (posedge clk or negedge rst_n)
        if(!rst_n)
            sck <= 1'b0;
        else if(~ce_n)//ce_n(开始读数据选中)，sck1周期翻转一次，也就是普通时钟的2倍
            sck <= ~ sck;
        else if(state == IDLE)
            sck <= 1'b0;

    // ce_n logic
    always @ (posedge clk or negedge rst_n)
        if(!rst_n)
            ce_n <= 1'b1;
        else if(state == READ ||state == QPI)//psram开始工作
            ce_n <= 1'b0;
        else
            ce_n <= 1'b1;

    always @ (posedge clk or negedge rst_n)
        if(!rst_n)
            counter <= 8'b0;
        else if(sck & ~done)
            counter <= counter + 1'b1;//可以当做sck每个上升沿计数，从而计算发送了个半字节
        else if(state == IDLE)
            counter <= 8'b0;

    always @ (posedge clk or negedge rst_n)
        if(!rst_n)
            saddr <= 24'b0;
        else if((state == IDLE) && rd)
            //saddr <= {addr[23:2], 2'b0};
            saddr <= {addr[23:0]};//对地址进行锁存

    // Sample with the negedge of sck
    wire[1:0] byte_index = {counter[7:1] - 8'd7}[1:0];//以counter=开始，每个data_index保持2次，获取2次4位
    always @ (posedge clk)
        if(counter >= (20-`OFFSET) && counter <= FINAL_COUNT)
            if(sck)
                data[byte_index] <= {data[byte_index][3:0], din}; // Optimize!移位，将新4位拼接

    assign dout_qpi =   (counter < 8)   ?   {3'b0, CMD_35H[7 - counter]}:0;

    assign dout_o   =   (counter < 8 - `OFFSET)   ?   CMD_EBH[(1-counter)*4 +: 4]://分阶段发送，前8个周期发送命令
                        (counter == 8 - `OFFSET)  ?   saddr[23:20]        ://开始发送24位地址
                        (counter == 9 - `OFFSET)  ?   saddr[19:16]        :
                        (counter == 10 - `OFFSET) ?   saddr[15:12]        :
                        (counter == 11 - `OFFSET) ?   saddr[11:8]         :
                        (counter == 12 - `OFFSET) ?   saddr[7:4]          :
                        (counter == 13 - `OFFSET) ?   saddr[3:0]          :
                        4'h0;//开始接收

    assign dout    = (state==QPI)?dout_qpi:dout_o;

    assign douten   = (state==QPI)?(counter < 8):(counter < 14);

    assign done     = (state==QPI)?(counter == 8'd8):(counter == FINAL_COUNT+1);

    generate
        genvar i;
        for(i=0; i<4; i=i+1)
            assign line[i*8+7: i*8] = data[i];//把data拼接成32位的line 可以看出来是小段序（data[0]先传输，放在小端）
    endgenerate
    // always@(posedge clk)begin
    // if(counter >= (20-`OFFSET) && counter <= FINAL_COUNT)
    //             if(sck)$display("\033[1;36m%02d data:0x%x\033[0m",counter-14,din);
    //if(done)$display("\033[1;35mline:0x%08x\033[0m",line);
    // if(state==QPI&&sck)$display("\033[1;34mdout:0x%02x\033[0m",dout);
    // end

endmodule

// Using 38H Command
module PSRAM_WRITER (
    input   wire            clk,
    input   wire            rst_n,
    input   wire [23:0]     addr,
    input   wire [31: 0]    line,
    input   wire [2:0]      size,
    input   wire            wr,
    output  wire            done,

    output  reg             sck,
    output  reg             ce_n,
    input   wire [3:0]      din,
    output  wire [3:0]      dout,
    output  wire            douten
);
    //localparam  DATA_START = 14;
    localparam  IDLE = 1'b0,
                WRITE = 1'b1;

    wire[7:0]        FINAL_COUNT = 13 + size*2 - `OFFSET;

    reg         state, nstate;
    reg [7:0]   counter;
    reg [23:0]  saddr;
    //reg [7:0]   data [3:0];

    wire[7:0]   CMD_38H = 8'h38;

    always @*
        case (state)
            IDLE: if(wr) nstate = WRITE; else nstate = IDLE;
            WRITE: if(done) nstate = IDLE; else nstate = WRITE;
        endcase

    always @ (posedge clk or negedge rst_n)
        if(!rst_n) state <= IDLE;
        else state <= nstate;

    // Drive the Serial Clock (sck) @ clk/2
    always @ (posedge clk or negedge rst_n)
        if(!rst_n)
            sck <= 1'b0;
        else if(~ce_n)
            sck <= ~ sck;
        else if(state == IDLE)
            sck <= 1'b0;

    // ce_n logic
    always @ (posedge clk or negedge rst_n)
        if(!rst_n)
            ce_n <= 1'b1;
        else if(state == WRITE)
            ce_n <= 1'b0;
        else
            ce_n <= 1'b1;

    always @ (posedge clk or negedge rst_n)
        if(!rst_n)
            counter <= 8'b0;
        else if(sck & ~done)
            counter <= counter + 1'b1;
        else if(state == IDLE)
            counter <= 8'b0;

    always @ (posedge clk or negedge rst_n)
        if(!rst_n)
            saddr <= 24'b0;
        else if((state == IDLE) && wr)
            saddr <= addr;

    assign dout     =   (counter < 8 - `OFFSET)   ?   CMD_38H[(1-counter)*4 +: 4]:
                        (counter == 8 - `OFFSET)  ?   saddr[23:20]        :
                        (counter == 9 - `OFFSET)  ?   saddr[19:16]        :
                        (counter == 10 - `OFFSET) ?   saddr[15:12]        :
                        (counter == 11 - `OFFSET) ?   saddr[11:8]         :
                        (counter == 12 - `OFFSET) ?   saddr[7:4]          :
                        (counter == 13 - `OFFSET) ?   saddr[3:0]          :
                        (counter == 14 - `OFFSET) ?   line[7:4]           :
                        (counter == 15 - `OFFSET) ?   line[3:0]           :
                        (counter == 16 - `OFFSET) ?   line[15:12]         :
                        (counter == 17 - `OFFSET) ?   line[11:8]          :
                        (counter == 18 - `OFFSET) ?   line[23:20]         :
                        (counter == 19 - `OFFSET) ?   line[19:16]         :
                        (counter == 20 - `OFFSET) ?   line[31:28]         :
                        line[27:24];

    assign douten   = (~ce_n);

    assign done     = (counter == FINAL_COUNT + 1);


endmodule
/* verilator lint_on DECLFILENAME */
/* verilator lint_on UNUSEDSIGNAL */
