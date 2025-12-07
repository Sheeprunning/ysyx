module sdram(
  input        clk,
  input        cke,
  input        cs,
  input        ras,
  input        cas,
  input        we,
  input [12:0] a,
  input [ 1:0] ba,
  input [ 1:0] dqm,
  inout [15:0] dq
);
  reg [1:0] latch_bank;
  reg [12:0]latch_row;
  reg [8:0] latch_col;

  reg [3:0]row_open;//置1表示该bank被激活
  reg [12:0]active_row[0:3];//记录每个被bank被激活的行

  reg [12:0]mode_reg;
  reg [2:0] write_counter,read_counter,burst_counter_w,burst_counter_r;
  reg [15:0]dq_out;
  reg dq_o_en,read_en,write_en;
  reg [14:0] addr;

  localparam  NOP   =  4'b0111,  ACTIVE=  4'b0011,
              READ  =  4'b0101,  WRITE =  4'b0100,
              BURST_TERMINATE =  4'b0110,  PRECHARGE =  4'b0010,
              AUTO_REFRESH =4'b0001,   LOAD_MODE =  4'b0000;

  
  wire [3:0]command={cs,ras,cas,we};
  wire [2:0]CAS_Lantency=mode_reg[6:4];//010
  wire [2:0]Burst_Length=mode_reg[2:0];//001
  wire [24:0] full_addr = {latch_bank , latch_row ,latch_col,1'b0};

  
  
  //LOAD MODE
  always @(posedge clk) begin
    if (cke && command == LOAD_MODE)
      mode_reg <= a;  
  end

  //ACTIVE
  always @(posedge clk)begin
    if(cke && command == ACTIVE)begin
      latch_bank<=ba;
      latch_row<=a;

      active_row[ba] <= a;
      row_open[ba]  <= 1'b1;
    end
  end

  //PRECHARGE
  always @(posedge clk)begin
    if(cke && command == PRECHARGE)begin
      if(a[10])begin//预充电所有
        row_open[0]<=1'b0;
        row_open[1]<=1'b0;
        row_open[2]<=1'b0;
        row_open[3]<=1'b0;
      end
      else  row_open[ba]<=1'b0;
    end
  end

  //READ
  always @(posedge clk) begin
    if (!cke) begin
      read_en <= 1'b0;
      read_counter <= 3'b0;
    end else begin
      if (command == READ) begin  
          latch_col <= a[8:0];
          latch_bank <= ba;
          read_en <= 1'b1;
          read_counter <= 3'd0;
          burst_counter_r <= 3'b0;
      end 
      else begin
          if(read_en) begin  // 仅在读使能时计数
            read_counter <= read_counter + 1;
            if(read_counter >= CAS_Lantency + Burst_Length) begin  // 结合CL和突发长度关闭
              read_en <= 1'b0;
              read_counter <= 3'b0;
            end
        end
      end
    end
  end

  always @(posedge clk) begin
    if (!cke) begin
      dq_o_en <= 1'b0;
    end else begin
      if (read_en /*&& read_counter >= CAS_Lantency && burst_counter_r<Burst_Length*/)begin
        dq_o_en <= 1'b1;
      end
      else
        dq_o_en <= 1'b0;
    end
  end

always @(posedge clk) begin
      if(cke && command == READ)  
        burst_counter_r<=3'b0;
      else if (read_en && burst_counter_r<Burst_Length)begin
        burst_counter_r <= burst_counter_r+1;
      end 
  end

  import "DPI-C" function void sdram_read(input int addr,output int rdata);
  import "DPI-C" function void sdram_write(input int addr,input int wdata);

  reg [31:0]rdata;
  always @(posedge clk) begin
    if (cke && read_en && row_open[latch_bank]) begin
      case (read_counter)//固定传输长度为2
        3'd0: begin
          sdram_read(full_addr,rdata);
          dq_out <= rdata[15:0];   
        end    
        3'd1: begin
          sdram_read(full_addr,rdata);
          dq_out <= rdata[31:16];  
        end
        
        default: dq_out <= 16'b0;
      endcase
    end else begin
      dq_out <= 16'b0;
    end
  end

  //WRITE
  always @(posedge clk)begin
  if (!cke) begin
      write_en <= 1'b0;
      write_counter <= 3'b0;
  end else begin
    if(cke && command == WRITE)begin
      if(!write_en)begin
        latch_bank<=ba;
        latch_col<=a[8:0]; 
        write_en<=1'b1;
        write_counter<=3'b1;
      end else write_counter<=write_counter+1;
    end 
    else begin
      if(write_en) begin  // 仅在写使能时计数
            write_counter <= write_counter + 1;
            if(write_counter >= Burst_Length) begin  // 结合CL和突发长度关闭
              write_en <= 1'b0;
              write_counter <= 3'b0;
            end
        end
    end
  end
  end

  always @(posedge clk) begin
      if(cke && command == WRITE)  
        burst_counter_w<=3'b0;
      else if (write_en && burst_counter_w<Burst_Length)begin
        burst_counter_w <= burst_counter_w+1;
      end
  end

  always @(posedge clk)begin
    if(cke)begin
      if(command == WRITE)begin
        if (!dqm[0]) 
        sdram_write({ba,latch_row,a[8:0],1'b0},dq[7:0]);
        if (!dqm[1]) 
        sdram_write({ba,latch_row,a[8:0],1'b1},dq[15:8]);
      end
      else if (write_en && burst_counter_w<Burst_Length)begin
        if (!dqm[0]) 
        sdram_write(full_addr+2,dq[7:0]);
        if (!dqm[1]) 
        sdram_write(full_addr+3,dq[15:8]);
      end
    end
  end


  assign dq = dq_o_en?dq_out:16'bz;

endmodule
