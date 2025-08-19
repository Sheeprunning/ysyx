#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vdecode24.h"

#include <iostream>
using namespace std;

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

static TOP_NAME* top;

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
}

int main() {
  sim_init();

  top->en = 0b0;  top->x = 0b00;  step_and_dump_wave();
                  top->x = 0b01;  step_and_dump_wave();
                  top->x = 0b10;  step_and_dump_wave();
                  top->x = 0b11;  step_and_dump_wave();
  top->en = 0b1;  top->x = 0b00;  step_and_dump_wave();
                  top->x = 0b01;  step_and_dump_wave();
                  top->x = 0b10;  step_and_dump_wave();
                  top->x = 0b11;  step_and_dump_wave();
  sim_exit();
}