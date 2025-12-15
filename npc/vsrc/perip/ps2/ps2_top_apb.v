module ps2_top_apb(
  input         clock,
  input         reset,
  input  [31:0] in_paddr,
  input         in_psel,
  input         in_penable,
  input  [2:0]  in_pprot,
  input         in_pwrite,
  input  [31:0] in_pwdata,
  input  [3:0]  in_pstrb,
  output  reg   in_pready,
  output [31:0] in_prdata,
  output        in_pslverr,

  input         ps2_clk,
  input         ps2_data
);

// internal signal, for test
  reg [9:0] buffer;        // ps2_data bits
  reg [7:0] fifo[7:0];     // data fifo
  reg [2:0] w_ptr,r_ptr;   // fifo write and read pointers
  reg [3:0] count;  // count ps2_data bits
  // detect falling edge of ps2_clk
  reg [2:0] ps2_clk_sync;
  reg overflow;

  wire is_ps2 = (in_paddr[7:0]==8'h0) && !in_pwrite;
  wire req_accept = (in_psel && in_penable);
  wire nextdata= req_accept&is_ps2;


  always @(posedge clock) begin
      ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};//保存3个周期的电平状态
  end

  wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];//高电平和低电平之间必定有下降沿

  always @(posedge clock) begin
      if (reset) begin // reset
          count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; in_pready<= 0;
      end
      else begin
          if ( in_pready ) begin // read to output next data
              if(nextdata) //read next data
              begin
                  r_ptr <= r_ptr + 3'b1;
                  if(w_ptr==(r_ptr+1'b1)) //empty
                      in_pready <= 1'b0;
              end
          end
          if (sampling) begin
            if (count == 4'd10) begin
              if ((buffer[0] == 0) &&  // start bit
                  (ps2_data)       &&  // stop bit
                  (^buffer[9:1])) begin      // odd  parity（奇校验)
                  fifo[w_ptr] <= buffer[8:1];  // kbd scan code 把收集的buffer数据放入缓存队列
                  w_ptr <= w_ptr+3'b1;//队列尾指针加一
                  in_pready <= 1'b1;
                  overflow <= overflow | (r_ptr == (w_ptr + 3'b1));//因为ptr是3位的，可以高位进位直接舍去，所以可以实现循环队列
              end
              count <= 0;     // for next
            end else begin //count！=10
              buffer[count] <= ps2_data;  // store ps2_data
              count <= count + 3'b1;
            end
          end
      end
  end
  assign in_prdata[7:0] = fifo[r_ptr]; //always set output data

endmodule
