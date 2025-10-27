module bitrev (
  input  sck,
  input  ss,
  input  mosi,
  output miso
);
  parameter [1:0] data_i_t = 0, data_o_t = 1;
  reg [1:0]state;
  reg [7:0]data_i;
  reg [7:0]data_o;
  reg [2:0]counter;
  wire rst=ss;
  assign miso =ss? 1'b1:(state==data_o_t)?data_o[7]:1'b1;

  always@(posedge sck or posedge rst)begin
    if(rst) counter<=0;
    else begin
      case(state)
        data_i_t: counter<=(counter==3'd7)?0:counter+1;
        data_o_t: counter<=0;
        default: $display("ERROR!");
      endcase
    end
  end

  always@(posedge sck or posedge rst)begin
    if(rst) state<=data_i_t;
    else begin
      case(state)
        data_i_t: state<=(counter==3'd7)?data_o_t:state;
        data_o_t: state<=(counter==3'd7)?data_i_t:state;
        default: $display("ERROR!");
      endcase
    end
  end

  always@(negedge sck or posedge rst)begin
    if(rst)data_i<=8'b0;
    else if(state==data_i_t) data_i<={mosi,data_i[7:1]};
  end

  always@(posedge sck)begin
    if(counter==3'd7)data_o<=data_i;
    else if(state==data_o_t) begin
      data_o<={data_o[6:0],1'b0};
    end
  end

endmodule
