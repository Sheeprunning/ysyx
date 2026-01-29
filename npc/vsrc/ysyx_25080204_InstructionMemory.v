module ysyx_25080204_InstructionMemory (
    input [31:0] addr,
    output [31:0] inst
);
import "DPI-C" function int pmem_read_v(input int raddr);

    assign inst = pmem_read_v(addr);
endmodule
