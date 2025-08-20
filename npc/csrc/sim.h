#ifndef __SIM_H__
#define __SIM_H__

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vtop.h"
#include "Vtop___024root.h"
#include <iostream>
#include <string>
#include <iomanip>
#include <getopt.h>
#include "svdpi.h"
#include "init_mem.h"
#include "sdb.h"

// #include <nvboard.h>

#define COLOR_RED    "\033[1;31m"
#define COLOR_GREEN  "\033[1;32m"
#define COLOR_RESET  "\033[0m"


// 全局变量声明
extern VerilatedContext* contextp;
extern VerilatedVcdC* tfp;
extern TOP_NAME* top;

// 仿真控制函数
void sim_init();
void sim_exit();
void step_and_dump_wave();
void single_cycle();
void reset(int n );
void cpu_exec(uint32_t n);


// DPI-C 函数声明
extern "C" {
    void npc_ebreak_finish();
    void show_reg(); 
}

void call_show_reg();
int isa_reg_str2val(const char *s, bool *success);
// 内存访问函数
uint32_t pmem_read(uint64_t addr, int len);

int sim(int argc, char *argv[]);

#endif 