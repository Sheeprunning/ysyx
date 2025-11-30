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

  reg [15:0]sdram[0:2**14-1];
  reg [12:0]mode_reg;
  reg [2:0] counter;
  reg [15:0] dq_out;
  reg [14:0]  addr;

  localparam  NOP   =  4'b0111,  ACTIVE=  4'b0011,
              READ  =  4'b0101,  WRITE =  4'b0100,
              BURST_TERMINATE =  4'b0110,  PRECHARGE =  4'b0010,
              AUTO_REFRESH =4'b0001,   LOAD_MODE =  4'b0000;

  wire dq_o_en,read_en;
  wire [3:0]command={cs,ras,cas,we};
  wire [2:0]CAS_Lantency=mode_reg[6:4];
  wire [2:0]Burst_Length=mode_reg[2:0];
  wire [14:0] full_addr = {ba, a};

  always @(posedge clk) begin
    if (cke && command == LOAD_MODE)
      mode_reg <= a;  
  end

  always @(posedge clk) begin
    if (!cke) begin
      read_en <= 1'b0;
      counter <= 3'b0;
    end else begin
      if (command == READ) begin
        if (!read_en) begin// 第一次进入READ状态，锁存地址并启动计数器          
          addr <= full_addr;
          read_en <= 1'b1;
          counter <= 3'd1;
        end else begin
          counter <= counter + 1;      
        end
      end else begin
        read_en <= 1'b0;
        counter <= 3'b0;
      end
    end
  end

  always @(posedge clk) begin
    if (!cke) begin
      dq_o_en <= 1'b0;
    end else begin
      if (read_en && counter == CAS_Lantency)
        dq_o_en <= 1'b1;
      else if (read_en && counter > CAS_Lantency)
        dq_o_en <= 1'b1;  
      else
        dq_o_en <= 1'b0;
    end
  end
  
  always @(*)begin
    if(cke)begin
      if(counter==CAS_Lantency)dq_out=sdram[full_addr];   
      if(counter==CAS_Lantency+1)dq_out=sdram[full_addr+1];    
    end
  end
  assign dq = dq_o_en?dq_out:16'bz;

endmodule
