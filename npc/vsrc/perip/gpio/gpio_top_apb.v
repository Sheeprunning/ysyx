module gpio_top_apb(
  input         clock,
  input         reset,
  input  [31:0] in_paddr,
  input         in_psel,
  input         in_penable,
  input  [2:0]  in_pprot,
  input         in_pwrite,
  input  [31:0] in_pwdata,
  input  [3:0]  in_pstrb,
  output        in_pready,
  output reg [31:0] in_prdata,
  output        in_pslverr,

  output reg [15:0] gpio_out,
  input  [15:0] gpio_in,
  output [7:0]  gpio_seg_0,
  output [7:0]  gpio_seg_1,
  output [7:0]  gpio_seg_2,
  output [7:0]  gpio_seg_3,
  output [7:0]  gpio_seg_4,
  output [7:0]  gpio_seg_5,
  output [7:0]  gpio_seg_6,
  output [7:0]  gpio_seg_7
);
  localparam  ST_IDLE=2'b00, ST_SETUP=2'b01, ST_ACCESS=2'b10;

  // reg led_ready,dig_ready,seg_ready;
  reg [7:0]seg[0:7];
  reg [31:0]bin_reg;
  reg [1:0]state;

  wire [3:0] bcd_data [0:7];

  wire is_read  = ((in_psel && !in_penable) || (state == ST_SETUP)) && !in_pwrite;
  wire is_write = ((in_psel && !in_penable) || (state == ST_SETUP)) &&  in_pwrite;

  wire is_led = (in_paddr[7:0]==8'h0) && in_pwrite;
  wire is_dig = (in_paddr[7:0]==8'h4) && !in_pwrite;
  wire is_seg = (in_paddr[7:0]==8'h8) && in_pwrite;

  wire req_accept = (in_psel && in_penable);

  assign in_pready=1'b1;
  assign in_pslverr = 1'b0;
  

  always @(posedge clock) begin
    if (reset) state <= ST_IDLE;
    else
      case (state)
        ST_IDLE: state <= (is_read || is_write ? (req_accept ? ST_ACCESS : ST_SETUP) : ST_IDLE);
        ST_SETUP: state <= req_accept ? ST_ACCESS : ST_SETUP;
        ST_ACCESS: if (in_pready) state <= ST_IDLE;
        default: state <= state;
      endcase
  end

  always@(posedge clock)begin
    if(reset)begin
      gpio_out<=16'h0;
    end
    else begin
      if(req_accept && is_led)begin
        $display("LED:%016b",in_pwdata[15:0]);
        if (in_pstrb[0]) gpio_out[7:0]   <= in_pwdata[7:0];
        if (in_pstrb[1]) gpio_out[15:8]  <= in_pwdata[15:8];
      end
    end
  end

  always@(posedge clock)begin
    if(reset)begin
      in_prdata<=32'h0;
    end
    else begin
      if(req_accept && is_dig)begin
      $display("dig:%016b",gpio_in[15:0]);
        in_prdata[7:0]   <= gpio_in[7:0];
        in_prdata[15:8]  <= gpio_in[15:8];
      end
    end
  end

  always@(posedge clock)begin
    if(reset)begin
      bin_reg<=32'h0;
    end
    else begin
      if(req_accept && is_seg)begin
        $display("SEG:0x%08x",in_pwdata);
        if (in_pstrb[0]) bin_reg[7:0] <= in_pwdata[7:0];
        if (in_pstrb[1]) bin_reg[15:8] <= in_pwdata[15:8];
        if (in_pstrb[2]) bin_reg[23:16] <= in_pwdata[23:16];
        if (in_pstrb[3]) bin_reg[31:24] <= in_pwdata[31:24];
      end
    end
  end

  assign bcd_data[0] = bin_reg[3:0];
  assign bcd_data[1] = bin_reg[7:4];
  assign bcd_data[2] = bin_reg[11:8];
  assign bcd_data[3] = bin_reg[15:12];
  assign bcd_data[4] = bin_reg[19:16];
  assign bcd_data[5] = bin_reg[23:20];
  assign bcd_data[6] = bin_reg[27:24];
  assign bcd_data[7] = bin_reg[31:28];

  generate
    genvar i;
      for(i=0;i<8;i=i+1) begin : seg_gen
        bcd7seg s(
            .b(bcd_data[i]),
            .h(seg[i])
        );
      end
  endgenerate

  assign gpio_seg_0 = seg[0];
  assign gpio_seg_1 = seg[1];
  assign gpio_seg_2 = seg[2];
  assign gpio_seg_3 = seg[3];
  assign gpio_seg_4 = seg[4];
  assign gpio_seg_5 = seg[5];
  assign gpio_seg_6 = seg[6];
  assign gpio_seg_7 = seg[7];

endmodule
