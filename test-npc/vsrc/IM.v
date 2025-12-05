module IM (
    input [31:0] addr,
    output [31:0] inst
);
    reg [31:0] mem [0:4095]; 

    assign inst = mem[(addr-32'h80000000) >> 2];
endmodule
