`define sim 1

`ifdef sim
    import "DPI-C" function void jal_ftrace(input int rd,input int pc,input int target);

    import "DPI-C" function void jalr_ftrace(
                        input int inst,input int rd,input int imm,input int pc,input int target);

    import "DPI-C" function void performance_counter(input int pfm);

    import "DPI-C" function void performance_cycle(input int pfm,input int cycle);

    import "DPI-C" function void npc_ebreak_finish();

    import "DPI-C" function void mrom_read(input int raddr, output int rdata);

    import "DPI-C" function void flash_read(input int addr, output int data);

    import "DPI-C" function void psram_read(input int addr,output int rdata);
    import "DPI-C" function void psram_write(input int addr,input int wdata);

    import "DPI-C" function void sdram_read(input int addr,output int rdata);
    import "DPI-C" function void sdram_write(input int addr,input int wdata);

    import "DPI-C" function void vga_read(input int addr,output int rdata);
    import "DPI-C" function void vga_write(input int addr,input int wdata);

`else 
    // 空函数实现 - 用于综合
    function void jal_ftrace;
        input int rd;
        input int pc;
        input int target;
        begin
            // 空实现 - 什么都不做
        end
    endfunction

    function void jalr_ftrace;
        input int inst;
        input int rd;
        input int imm;
        input int pc;
        input int target;
        begin
            // 空实现 - 什么都不做
        end
    endfunction

    function void performance_counter;
        input int pfm;
        begin
            // 空实现 - 什么都不做
        end
    endfunction

    function void performance_cycle;
        input int pfm;
        input int cycle;
        begin
            // 空实现 - 什么都不做
        end
    endfunction

    function void npc_ebreak_finish;
        begin
            // 空实现 - 什么都不做
        end
    endfunction

    function void mrom_read;
        input int raddr;
        output int rdata;
        begin
            // 返回默认值0
            rdata = 0;
        end
    endfunction

    function void flash_read;
        input int addr;
        output int data;
        begin
            // 返回默认值0
            data = 0;
        end
    endfunction

    function void psram_read;
        input int addr;
        output int rdata;
        begin
            // 返回默认值0
            rdata = 0;
        end
    endfunction

    function void psram_write;
        input int addr;
        input int wdata;
        begin
            // 空实现 - 什么都不做
        end
    endfunction

    function void sdram_read;
        input int addr;
        output int rdata;
        begin
            // 返回默认值0
            rdata = 0;
        end
    endfunction

    function void sdram_write;
        input int addr;
        input int wdata;
        begin
            // 空实现 - 什么都不做
        end
    endfunction

    function void vga_read;
        input int addr;
        output int rdata;
        begin
            // 返回默认值0
            rdata = 0;
        end
    endfunction

    function void vga_write;
        input int addr;
        input int wdata;
        begin
            // 空实现 - 什么都不做
        end
    endfunction
`endif
