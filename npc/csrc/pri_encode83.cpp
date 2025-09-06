#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vpri_encode83.h"
#include <nvboard.h>

#include <iostream>
using namespace std;

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

static TOP_NAME* top;

void nvboard_bind_all_pins(TOP_NAME* dut);

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(10);
  tfp->dump(contextp->time());
}
void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new TOP_NAME{contextp};
  contextp->traceEverOn(true);
  top->trace(tfp, 99);
  tfp->open("wave.vcd");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
  delete top;
  delete tfp;
  delete contextp;
}
int main() {
    sim_init();
    nvboard_bind_all_pins(top);
    nvboard_init();
    while (!contextp->gotFinish()){
        top->eval();
        nvboard_update();
    }
    sim_exit();
}