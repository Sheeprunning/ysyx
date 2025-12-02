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

  // // 4个Bank:4 * 8192行 * 512列 * 16位
  // reg [15:0] bank0 [0:8191][0:511];
  // reg [15:0] bank1 [0:8191][0:511];
  // reg [15:0] bank2 [0:8191][0:511];
  // reg [15:0] bank3 [0:8191][0:511];

  // reg [1:0] latch_bank;
  // reg [12:0]latch_row;
  // reg [8:0] latch_col;

  // reg [1:0]row_open;//置1表示该bank被激活
  // reg [12:0]active_row[0:1];//记录每个被bank被激活的行

  // reg [12:0]mode_reg;
  // reg [2:0] counter,burst_counter;
  // reg [15:0]dq_out;
  // reg dq_o_en,read_en,write_en;
  // reg [14:0] addr;

  // localparam  NOP   =  4'b0111,  ACTIVE=  4'b0011,
  //             READ  =  4'b0101,  WRITE =  4'b0100,
  //             BURST_TERMINATE =  4'b0110,  PRECHARGE =  4'b0010,
  //             AUTO_REFRESH =4'b0001,   LOAD_MODE =  4'b0000;

  
  // wire [3:0]command={cs,ras,cas,we};
  // wire [2:0]CAS_Lantency=mode_reg[6:4];
  // wire [2:0]Burst_Length=mode_reg[2:0];
  // wire [14:0] full_addr = {ba, a};

  // reg [15:0] current_bank [0:8191][0:511];

  // always@(*)begin
  //   current_bank = 
  //       (latch_bank == 2'b00) ? bank0 :
  //       (latch_bank == 2'b01) ? bank1 :
  //       (latch_bank == 2'b10) ? bank2 : bank3;
  // end
  
  
  // //LOAD MODE
  // always @(posedge clk) begin
  //   if (cke && command == LOAD_MODE)
  //     mode_reg <= a;  
  // end

  // //ACTIVE
  // always @(posedge clk)begin
  //   if(cke && command == ACTIVE)begin
  //     latch_bank<=ba;
  //     latch_row<=a[8:0];

  //     active_row[ba] <= a;
  //     row_open[ba]  <= 1'b1;
  //   end
  // end

  // //PRECHARGE
  // always @(posedge clk)begin
  //   if(cke && command == PRECHARGE)begin
  //     if(a[10])begin//预充电所有
  //       row_open[0]<=1'b0;
  //       row_open[1]<=1'b0;
  //       row_open[2]<=1'b0;
  //       row_open[3]<=1'b0;
  //     end
  //     else  row_open[ba]<=1'b0;
  //   end
  // end

  // //READ
  // always @(posedge clk) begin
  //   if (!cke) begin
  //     read_en <= 1'b0;
  //     counter <= 3'b0;
  //   end else begin
  //     if (command == READ) begin
  //       if (!read_en) begin// 第一次进入READ状态，锁存地址并启动计数器          
  //         latch_col <= a[8:0];
  //         latch_bank <= ba;
  //         read_en <= 1'b1;
  //         counter <= 3'd1;
  //         burst_counter <= 3'b0;
  //       end else begin
  //         counter <= counter + 1;      
  //       end
  //     end else begin
  //       read_en <= 1'b0;
  //       counter <= 3'b0;
  //     end
  //   end
  // end

  // always @(posedge clk) begin
  //   if (!cke) begin
  //     dq_o_en <= 1'b0;
  //   end else begin
  //     if (read_en && counter >= CAS_Lantency && burst_counter<Burst_Length)begin
  //       dq_o_en <= 1'b1;
  //     end
  //     else
  //       dq_o_en <= 1'b0;
  //   end
  // end

  // always @(posedge clk) begin
  //     if (read_en && counter >= CAS_Lantency && burst_counter<Burst_Length)
  //       burst_counter <= burst_counter+1;
  //     if (write_en && burst_counter<Burst_Length)
  //       burst_counter <= burst_counter+1;
  // end
  
  // always @(posedge clk) begin
  //   if (cke && read_en && row_open[latch_bank]) begin
  //     case (counter)//固定传输长度为2
  //       3'd2: dq_out <= current_bank[active_row[latch_bank]][latch_col];      
  //       3'd3: dq_out <= current_bank[active_row[latch_bank]][latch_col+1];  
  //       default: dq_out <= 16'b0;
  //     endcase
  //   end else begin
  //     dq_out <= 16'b0;
  //   end
  // end

  // //WRITE
  // always @(posedge clk)begin
  // if (!cke) begin
  //     read_en <= 1'b0;
  //     counter <= 3'b0;
  // end else begin
  //   if(cke && command == WRITE)begin
  //     if(!write_en)begin
  //       latch_bank<=ba;
  //       latch_row<=a[8:0];
  //       write_en<=1'b1;
  //       counter<=3'b1;
  //       burst_counter<=3'b1;
  //     end else counter<=counter+1;
  //   end 
  //   else begin
  //     counter<=0;
  //     write_en<=1;
  //   end
  // end
  // end

  // always @(posedge clk)begin
  //   if(cke && command == WRITE)begin
  //     if (!dqm[0]) 
  //     current_bank[active_row[ba]][a][7:0] <= dq[7:0];
  //     if (!dqm[1]) 
  //     current_bank[active_row[ba]][a][15:8] <= dq[15:8];
  //   end
  //   else if (write_en && burst_counter<Burst_Length)begin
  //     if (!dqm[0]) 
  //     current_bank[active_row[latch_bank]][latch_bank+burst_counter][7:0] <= dq[7:0];
  //     if (!dqm[1]) 
  //     current_bank[active_row[latch_bank]][latch_col+burst_counter][15:8] <= dq[15:8];
  //   end
  // end


  // assign dq = dq_o_en?dq_out:16'bz;

endmodule
