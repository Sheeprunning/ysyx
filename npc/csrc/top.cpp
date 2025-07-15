#include "Vtop.h"
#include "verilated.h"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vtop* top = new Vtop{contextp};

		VerilatedVcdC* tfp = new VerilatedVcdC;
		contextp->traceEverOn(true);//打开追踪功能
    top->trace(tfp, 99);  // 追踪所有信号（深度 99）
    tfp->open("wave.vcd"); // 生成 wave.vcd 文件


    while (!contextp->gotFinish()) { 
				int a = rand() & 1;
 				int b = rand() & 1;
 	 			top->a = a;
 	 			top->b = b;
 	 			top->eval();
  			printf("a = %d, b = %d, f = %d\n", a, b, top->f);

				tfp->dump(contextp->time());//dump wave
				contextp->timeInc(1);//推动仿真时间

	  		assert(top->f == (a ^ b));
 
}
    delete top;
    delete contextp;
    return 0;
}
