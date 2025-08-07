module RegisterFile #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
  input clk,
  input [DATA_WIDTH-1:0] wdata,
  input [ADDR_WIDTH-1:0] waddr,
  input [DATA_WIDTH-1:0] rdata,
  input [ADDR_WIDTH-1:0] raddr,
  input wen
);
  reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];
  always @(posedge clk) begin
    if (wen) rf[waddr] <= wdata;
    else begin 
        rdata <= rf[waddr];
        end
  end
endmodule
