module RegisterFile #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
  input clk,
  input rst,
  input [DATA_WIDTH-1:0] wdata,
  input [ADDR_WIDTH-1:0] waddr,
  input [ADDR_WIDTH-1:0]rs1,
  input [ADDR_WIDTH-1:0]rs2,
  input wen,
  output input [ADDR_WIDTH-1:0]src1,
  output input [ADDR_WIDTH-1:0]src2
);
  reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];
  always @(posedge clk or posedge rst) begin
    if(rst)begin
            for (i=0;i<32;i=i+1)begin
                register[i]<=0;
            end
        end
    else if (wen && rd!=0) rf[waddr] <= wdata;
  end
  assign src1=rf[rs1];
  assign src2=re[rs2];
endmodule
