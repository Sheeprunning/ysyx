#include "Vtop.h"
#include "verilated.h"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "verilated_vcd_c.h"
#include <nvboard.h>


//static TOP_NAME dut;
void nvboard_bind_all_pins(TOP_NAME* dut);

static void single_cycle(TOP_NAME* dut) {
  dut->clk = 0; dut->eval();
  dut->clk = 1; dut->eval();
}

static void reset(int n,TOP_NAME* dut) {
  dut->rst = 1;
  while (n -- > 0) single_cycle(dut);
  dut->rst = 0;
}

int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vtop* top = new Vtop{contextp};

		nvboard_bind_all_pins(top);
    nvboard_init();

		VerilatedVcdC* tfp = new VerilatedVcdC;
		contextp->traceEverOn(true);//打开追踪功能
    top->trace(tfp, 99);  // 追踪所有信号（深度 99）
    tfp->open("wave.vcd"); // 生成 wave.vcd 文件
		
		reset(10,top);

    while (!contextp->gotFinish()) { 
				
 	 			top->eval();
				tfp->dump(contextp->time());//dump wave
				contextp->timeInc(1);//推动仿真时间
				nvboard_update();
				single_cycle(top);
 
}
		tfp->close();
		nvboard_quit();
    delete top;
    delete contextp;
		delete tfp;
    return 0;
}
