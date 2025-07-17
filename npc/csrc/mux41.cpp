#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vmux41.h"

#include <iostream>
using namespace std;

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

static Vmux41* top;

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(10);
  tfp->dump(contextp->time());
}
void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new Vmux41{contextp};
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
  top->s=0b00;  top->a=0b1110;  step_and_dump_wave();
                top->a=0b0001;  step_and_dump_wave();
  top->s=0b01;  top->a=0b1110;  step_and_dump_wave();
                top->a=0b0010;  step_and_dump_wave();
  top->s=0b10;  top->a=0b1010;  step_and_dump_wave();
                top->a=0b0100;  step_and_dump_wave();
  top->s=0b11;  top->a=0b0111;  step_and_dump_wave();
                top->a=0b1001;  step_and_dump_wave();
  sim_exit();
}