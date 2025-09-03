module ysyx_25080204_RegisterFile #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
  input clk,
  input rst,
  input [DATA_WIDTH-1:0] wdata,
  input [ADDR_WIDTH-1:0] waddr,
  input [ADDR_WIDTH-1:0]rs1,
  input [ADDR_WIDTH-1:0]rs2,
  input wen,
  output [DATA_WIDTH-1:0]src1,
  output [DATA_WIDTH-1:0]src2
);
  int i;
  reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];
  always @(posedge clk or posedge rst) begin
    if(rst)begin
            for (i=0;i<32;i=i+1)begin
                rf[i]<=0;
            end
        end
    else if (wen && waddr!=0)begin
        //$display("[CLK %0t] Write: rf[%0d] = 0x%08x ", $time, waddr, wdata);
        rf[waddr] <= wdata;
     end
  end
  assign src1=rf[rs1];
  assign src2=rf[rs2];

export "DPI-C" task show_reg;
 

task show_reg();
  for (i=0;i<32;i=i+1)begin
      $display("x[%d]: 0x%08x\n",i,rf[i]);
  end
endtask
  

endmodule
