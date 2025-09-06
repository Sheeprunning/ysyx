#include "verilated.h"
#include "verilated_vcd_c.h"
#include "VALU.h"

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
  delete contextp;
  delete top;
  delete tfp;
}
void print_alu_status() {
    cout << "Time=" << contextp->time() << " | "
         << "opcode=" << bitset<3>(top->opcode) << " | "
         << "A=" << bitset<32>(top->A) << " (" << top->A << ") | "
         << "B=" << bitset<32>(top->B) << " (" << top->B << ") | "
         << "result=" << bitset<32>(top->result) << " (" << top->result << ") | "
         << "Zero=" << bitset<1>(top->Zero)<< " | "
         << "Overflow=" << bitset<1>(top->Overflow) << " | "
         << "CF=" << bitset<1>(top->CF) << endl;
}
int main() {
  sim_init();
  // 测试 1: 加法 (opcode=000)
    top->opcode = 0b000; top->A = 10; top->B = 20;  // 10 + 20 = 30
    step_and_dump_wave();
    print_alu_status();
 
    // 测试 2: 减法 (opcode=001)
    top->opcode = 0b001; top->A = 30; top->B = 15;  // 30 - 15 = 15
    step_and_dump_wave();
    print_alu_status();
 
    // 测试 3: 按位取反 (opcode=010)
    top->opcode = 0b010; top->A = 0xFFFFFFFF; top->B = 0;  // ~0xFFFFFFFF = 0
    step_and_dump_wave();
    print_alu_status();
 
    // 测试 4: 按位与 (opcode=011)
    top->opcode = 0b011; top->A = 0b1100; top->B = 0b1010;  // 0b1100 & 0b1010 = 0b1000
    step_and_dump_wave();
    print_alu_status();
 
    // 测试 5: 按位或 (opcode=100)
    top->opcode = 0b100; top->A = 0b1100; top->B = 0b1010;  // 0b1100 | 0b1010 = 0b1110
    step_and_dump_wave();
    print_alu_status();
 
    // 测试 6: 按位异或 (opcode=101)
    top->opcode = 0b101; top->A = 0b1100; top->B = 0b1010;  // 0b1100 ^ 0b1010 = 0b0110
    step_and_dump_wave();
    print_alu_status();
 
    // 测试 7: 比较 (opcode=110)
    top->opcode = 0b110; top->A = 10; top->B = 20;  // 10 < 20 → Overflow=1, result=1
    step_and_dump_wave();
    print_alu_status();
 
    // 测试 8: Zero 标志 (A=0)
    top->opcode = 0b000; top->A = 0; top->B = 0;  // 0 + 0 = 0 → Zero=1
    step_and_dump_wave();
    print_alu_status();
 
    // 测试 9: 加法溢出 (opcode=000)
    top->opcode = 0b000; top->A = 0x7FFFFFFF; top->B = 1;  // 0x7FFFFFFF + 1 → Overflow=1
    step_and_dump_wave();
    print_alu_status();
 
    // 测试 10: 减法溢出 (opcode=001)
    top->opcode = 0b001; top->A = 0x80000000; top->B = 1;  // 0x80000000 - 1 → Overflow=1
    step_and_dump_wave();
    print_alu_status();

  sim_exit();
}