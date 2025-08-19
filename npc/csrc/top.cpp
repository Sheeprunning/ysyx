#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include "Vtop.h"
#include <string.h>
#include <iomanip>
#include <getopt.h>
#include "init_mem.h"

// #include <nvboard.h>
// void nvboard_bind_all_pins(TOP_NAME* dut);

using namespace std;

#define COLOR_RED    "\033[1;31m"
#define COLOR_GREEN  "\033[1;32m"
#define COLOR_RESET  "\033[0m"
#define CONFIG_MSIZE 0x8000000
#define CONFIG_MBASE 0x80000000
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
  delete contextp;
}

static void single_cycle() {
  top->clk = 0; top->eval();
  contextp->timeInc(10);
  tfp->dump(contextp->time());
  // nvboard_update();
  top->clk = 1; top->eval();
  if(pc!=top->pc){
    pc=top->pc;
    cout<<"pc:"<<hex<<pc<<endl;
  }
  contextp->timeInc(10);
  tfp->dump(contextp->time());
  top->inst=pmem_read(top->pc,4);
  // nvboard_update();
}

static void reset(int n=10) {
  top->rst = 1;
  while (n -- > 0) single_cycle();
  top->rst = 0;
}



extern "C" {
    void npc_ebreak_finish() {
        VL_PRINTF("[DPI-C] EBREAK triggered, stopping simulation.\n");
        Verilated::gotFinish(true);
        cout << "-----Result Check:-----" << endl;
        if(top->a0==0){
          cout<< COLOR_GREEN "HIT_GOOD" COLOR_RESET<<endl;
        }
        else{
          cout<< COLOR_RED "BAD_TRAP" COLOR_RESET<<endl;
        }
        exit(0);
    }
    void show_reg();
}

void cpu_exec(uint32_t n){
  for(int i=0;i<n;i++){
    single_cycle();
  }
}

int main(int argc, char *argv[]) {
    sim_init();
    parse_args(argc, argv);
    init_mem();
    // nvboard_bind_all_pins(top);
    // nvboard_init();
    reset();
    cpu_exec(-1);
    sim_exit();
}