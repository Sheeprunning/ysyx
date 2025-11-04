// define this macro to enable fast behavior simulation
// for flash by skipping SPI transfers
// `define FAST_FLASH

module spi_top_apb #(
  parameter flash_addr_start = 32'h30000000,
  parameter flash_addr_end   = 32'h3fffffff,
  parameter spi_ss_num       = 8
) (
  input         clock,
  input         reset,
  input  [31:0] in_paddr,
  input         in_psel,
  input         in_penable,
  input  [2:0]  in_pprot,
  input         in_pwrite,
  input  [31:0] in_pwdata,
  input  [3:0]  in_pstrb,
  output reg    in_pready,
  output [31:0] in_prdata,
  output        in_pslverr,

  output                  spi_sck,
  output [spi_ss_num-1:0] spi_ss,
  output                  spi_mosi,
  input                   spi_miso,
  output                  spi_irq_out
);

`ifdef FAST_FLASH

wire [31:0] data;
parameter invalid_cmd = 8'h0;
flash_cmd flash_cmd_i(
  .clock(clock),
  .valid(in_psel && !in_penable),
  .cmd(in_pwrite ? invalid_cmd : 8'h03),
  .addr({8'b0, in_paddr[23:2], 2'b0}),
  .data(data)
);
assign spi_sck    = 1'b0;
assign spi_ss     = 8'b0;
assign spi_mosi   = 1'b1;
assign spi_irq_out= 1'b0;
assign in_pslverr = 1'b0;
assign in_pready  = in_penable && in_psel && !in_pwrite;
assign in_prdata  = data[31:0];

`else

reg [31:0]in_paddr_t,in_pwdata_t;
reg in_pwrite_t,in_psel_t,in_penable_t,spi_miso_t;
reg [3:0]in_pstrb_t;
reg [2:0]state,next_state;

wire in_pready_ack;

wire if_in_flash = (in_paddr>=flash_addr_start) && (in_paddr<=flash_addr_end);
wire xip=if_in_flash && in_penable;
wire common=(!if_in_flash) && in_psel;
wire go_bsy=(in_paddr==32'h10001010&&in_pready_ack)?in_prdata[8]:0;

localparam  IDLE=3'd0,
            XIP_TX=3'd1,   XIP_DIVIDER=3'd2,
            XIP_SS=3'd3,   XIP_CTRL=3'd4,
            XIP_WAIT=3'd5, XIP_RETURN=3'd6,
            COMMON=3'd7;

always @(*)begin
  case(state)
    IDLE:           next_state=xip?XIP_TX:common?COMMON:state;
    XIP_TX:         next_state=in_pready_ack?XIP_DIVIDER:state;
    XIP_DIVIDER:    next_state=in_pready_ack?XIP_SS:state;
    XIP_SS:         next_state=in_pready_ack?XIP_CTRL:state;
    XIP_CTRL:       next_state=in_pready_ack?XIP_WAIT:state;
    XIP_WAIT:       next_state=(in_pready_ack&&!go_bsy)?XIP_RETURN:state;
    XIP_RETURN:     next_state=in_pready_ack?IDLE:state;
    COMMON:         next_state=go_bsy?state:in_pready_ack?IDLE:state;
  endcase
end

always @(posedge clock or posedge reset)begin
  if(reset)begin
    state<=IDLE;
  end
  else begin
    state<=next_state;
  end
end

always @(*)begin
  case(state)
    IDLE:begin
      in_paddr_t=0;
      in_pwdata_t=0;
      in_pstrb_t=0;
      in_pwrite_t=0;
      in_psel_t=0;
      in_penable_t=0;
      spi_miso_t=0;
      in_pready=0;
    end
    XIP_TX:begin
      in_paddr_t=32'h10001004;//tx1
      in_pwdata_t=32'h03000000+in_paddr[23:0];
      in_pstrb_t=4'b1111;
      in_pwrite_t=1;
      in_psel_t=1;
      in_penable_t=1;
      spi_miso_t=spi_miso;
      in_pready=0;
    end
    XIP_DIVIDER:begin
      in_paddr_t=32'h10001014;
      in_pwdata_t=32'd10;
      in_pstrb_t=4'b1111;
      in_pwrite_t=1;
      in_psel_t=1;
      in_penable_t=1;
      spi_miso_t=spi_miso;
      in_pready=0;
    end
    XIP_SS:begin
      in_paddr_t=32'h10001018;
      in_pwdata_t=32'h1;
      in_pstrb_t=4'b1111;
      in_pwrite_t=1;
      in_psel_t=1;
      in_penable_t=1;
      spi_miso_t=spi_miso;
      in_pready=0;
    end
    XIP_CTRL:begin
      in_paddr_t=32'h10001010;
      in_pwdata_t=32'b10010101000000;//ass=1,lsb=0,tx_neg=1,rx_neg=0,charlen=64,go/bsy=1
      in_pstrb_t=4'b1111;
      in_pwrite_t=1;
      in_psel_t=1;
      in_penable_t=1;
      spi_miso_t=spi_miso;
      in_pready=0;
    end
    XIP_WAIT:begin
      in_paddr_t=32'h10001010;
      in_pwdata_t=32'h0;
      in_pstrb_t=4'b1111;
      in_pwrite_t=0;
      in_psel_t=1;
      in_penable_t=1;
      spi_miso_t=spi_miso;
      in_pready=0;
    end
    XIP_RETURN:begin
      in_paddr_t=32'h10000000;
      in_pwdata_t=32'h0;
      in_pstrb_t=4'b1111;
      in_pwrite_t=0;
      in_psel_t=1;
      in_penable_t=1;
      spi_miso_t=spi_miso;
      in_pready=in_pready_ack;
    end
    COMMON:begin
      in_paddr_t=in_paddr;
      in_pwdata_t=in_pwdata;
      in_pstrb_t=in_pstrb;
      in_pwrite_t=in_pwrite;
      in_psel_t=in_psel;
      in_penable_t=in_penable;
      spi_miso_t=spi_miso;
      in_pready=in_pready_ack;
    end
    default:begin
      $display("\033[1;31m spi_top_apb.v 进入未知状态\033[0m");
      in_paddr_t=0;
      in_pwdata_t=0;
      in_pstrb_t=0;
      in_pwrite_t=0;
      in_psel_t=0;
      in_penable_t=0;
      spi_miso_t=1;
    end
  endcase
end

spi_top u0_spi_top (
  .wb_clk_i(clock),
  .wb_rst_i(reset),
  .wb_adr_i(in_paddr_t[4:0]),
  .wb_dat_i(in_pwdata_t),
  .wb_dat_o(in_prdata),
  .wb_sel_i(in_pstrb_t),
  .wb_we_i (in_pwrite_t),
  .wb_stb_i(in_psel_t),
  .wb_cyc_i(in_penable_t),
  .wb_ack_o(in_pready_ack),
  .wb_err_o(in_pslverr),
  .wb_int_o(spi_irq_out),

  .ss_pad_o(spi_ss),
  .sclk_pad_o(spi_sck),
  .mosi_pad_o(spi_mosi),
  .miso_pad_i(spi_miso_t)
);

always @(*)begin
  // if(in_pready_ack)begin
  //   if(in_pwrite_t)begin
  //     $display("W addr=0x%08x wdata=0x%08x",in_paddr_t,in_pwdata_t);
  //   end
  //   else $display("R addr=0x%08x rdata=0x%08x",in_paddr_t,in_prdata);
  // end
  if(state==COMMON)$display("\033[1;35mmiso_t=%b\033[0m",spi_miso_t);
end

`endif // FAST_FLASH

endmodule
