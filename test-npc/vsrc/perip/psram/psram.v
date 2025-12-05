`define  OFFSET 6 
module psram(
  input sck,
  input ce_n,
  inout [3:0] dio
);

  reg qpi=0;
  reg[7:0]sram[4194304];//4MB
  reg dio_en;//dio输出使能
  reg [2:0]state,next_state;
  reg [4:0]counter;
  reg [7:0]cmd;
  reg [23:0]addr;
  reg [7:0]rdata [3:0];
  reg [31:0]wdata;
  reg [3:0]dio_out;

  wire rst=ce_n;
  wire [7:0]byte_0=sram[addr],
            byte_1=sram[addr+1],
            byte_2=sram[addr+2],
            byte_3=sram[addr+3];
  wire [4:0]cmd_cnt=qpi?5'd1:5'd7,
            addr_cnt=qpi?5'd7:5'd13,
            wait_cnt=qpi?5'd13:5'd19,
            read_cnt=qpi?5'd21:5'd27,
            write_cnt=qpi?5'd15:5'd21;

  localparam CMD=3'd0,ADDR=3'd1,WAIT=3'd2,READ=3'd3,WRITE=3'd4,ERROR=3'd5;

  assign dio = dio_en ? dio_out : 4'bz;

//state转移
  always@(*)begin
    case(state)
      CMD:next_state=(counter!=cmd_cnt)?state:(cmd==8'h35||cmd==8'hf5)?state:ADDR;
      ADDR:next_state=(counter!=addr_cnt)?state:
                      (cmd==8'heb)?WAIT:
                      (cmd==8'h38)?WRITE:ERROR;
      WAIT:next_state=(counter==wait_cnt)?READ:state;
      READ:next_state=(counter==read_cnt)?CMD:state;
      WRITE:next_state=(counter==write_cnt)?CMD:state;
      default: begin
          next_state <= state;
          $fwrite(32'h80000002, "Assertion failed: Unsupported command `%xh`, only support `E8h` read and `38h` write command\n", cmd);
          $fatal;
        end
    endcase
  end

  always@(posedge sck or posedge rst)begin
    if(rst)state<=CMD;
    else state<=next_state;
  end
//counter自增
  always@(posedge sck or posedge rst)begin
    if(rst)counter<=0;
    else begin
      counter<=counter+1;
    end
  end

//获取cmd（8个周期）
  always@(posedge sck or posedge rst)begin
    if(rst)cmd<=0;
    else if(state==CMD)begin
      // $display("\033[1;31mdin:%b\033[0m",dio[0]);
      // $display("\033[1;35mcmd:%08b\033[0m",{cmd[6:0],dio[0]});
            if(qpi) cmd<={cmd[3:0],dio};
            else cmd<={cmd[6:0],dio[0]};
    end
    
  end

//qpi更新逻辑
always @(posedge sck) begin
    if (state == CMD && counter == 5'd7) begin
    // $display("cmd:%xh",{cmd[6:0],dio[0]});
        if (!qpi && {cmd[6:0],dio[0]} == 8'h35) begin
            // $display("\033[1;32mEnter QPI mode\033[0m");
            qpi <= 1'b1;
        end else if (qpi && cmd == 8'hF5) begin
            qpi <= 1'b0;
        end
    end
end

//获取addr（6个周期）
  always@(posedge sck or posedge rst)begin
    if(rst)addr<=0;
    else if(state==ADDR)begin 
      addr<={addr[19:0],dio};
      // if(counter==5'd5)
      // $display("cmd:%xh",cmd);
    end
  end

//获取wdata(根据ce_n传输)
  wire[1:0] byte_index_w = {counter -( 5'd14 - `OFFSET)}[2:1];
  wire [23:0] waddr=addr+byte_index_w;
  always@(posedge sck or posedge rst)begin
    if(rst)wdata<=0;
    else if(state==WRITE)begin 
      sram[waddr]<={sram[waddr][3:0],dio};
      // $display("WRITE----sram[%08x]=%04x",waddr,dio);
    end
  end

//dio_en赋值
  always@(posedge sck)begin
    case(state)
      READ:dio_en<=1;
      default:dio_en<=0;
    endcase
  end

//数据输出
  wire[1:0] byte_index_r = {counter-(5'd20 - `OFFSET)}[2:1];//EF_PSRAM_CTRL.v的写法不太好理解

  always@(negedge sck or posedge rst)begin
    if(rst)begin
      dio_out<=0;
      rdata[0]<=0;
      rdata[1]<=0;
      rdata[2]<=0;
      rdata[3]<=0;
    end
    else if(counter==5'd19-`OFFSET)begin
      rdata[0]<=byte_0;
      rdata[1]<=byte_1;
      rdata[2]<=byte_2;
      rdata[3]<=byte_3;
    end
    else if(state==READ)begin
      rdata[byte_index_r]<={rdata[byte_index_r][3:0],4'b0};
      dio_out<=rdata[byte_index_r][7:4];
      // $display("\033[1;33mrdata[0x%08x]=0x%x\033[0m",addr,rdata[byte_index_r][7:4]);
    end
  end 

endmodule
