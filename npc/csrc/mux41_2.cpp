#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vmux41_2.h"
#include <nvboard.h>

#include <iostream>
using namespace std;

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

static Vmux41_2* top;

void nvboard_bind_all_pins(TOP_NAME* dut);

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(10);
  tfp->dump(contextp->time());
}
void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new Vmux41_2{contextp};
  contextp->traceEverOn(true);
  top->trace(tfp, 99);
  tfp->open("wave.vcd");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
  delete top;
  delete tfp;
}
int main() {
    sim_init();
    nvboard_bind_all_pins(top);
    nvboard_init();
    sim_exit();
}