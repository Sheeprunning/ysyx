#include "sim.h"

// #include <nvboard.h>
// void nvboard_bind_all_pins(TOP_NAME* dut);

using namespace std;

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

TOP_NAME* top;
CPU_state cpu;
NPCState npc_state;
u_int32_t pc;


void print_inst(u_int32_t pc,u_int32_t inst){
  char logbuf[128];
  char *p=logbuf;
  p += snprintf(p, sizeof(logbuf), FMT_WORD ":", pc);
  p += snprintf(p, 120,"%08x ",inst);
  disassemble(p , logbuf+sizeof(logbuf)-p , pc , (uint8_t*)&inst,4);
  printf("%s\n",logbuf);
  log_add("itrace.txt",logbuf);
}

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(10);
  tfp->dump(contextp->time());
} 

void update_cpu(){
  for(int i=0;i<32;i++){
    cpu.gpr[i]=top->rootp->top__DOT__CPU__DOT__RF__DOT__rf[i];
  }
  cpu.pc=top->pc;
}

void single_cycle() {
  top->clk = 0; 
  step_and_dump_wave();
  // nvboard_update();
  top->clk = 1; 
  if(top->rst!=1){
    top->inst=pmem_read(top->pc,4);
    print_inst(top->pc,top->inst);     
  }
  else 
    top->inst=0;
  step_and_dump_wave();
  update_cpu();

  // nvboard_update();
}

 void reset(int n=10) {
  top->rst = 1;
  while (n -- > 0) single_cycle();
  top->rst = 0;
}

void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new TOP_NAME{contextp};
  contextp->traceEverOn(true);
  top->trace(tfp, 99);
  tfp->open("wave.vcd");
  reset();
}

void sim_exit(){
  tfp->close();
  delete top;
  delete tfp;
  delete contextp;
  cout<<"仿真结束！\n";
}





const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};
const char *regs2[] = {
  "x0", "x1", "x2", "x3", "x4", "x5", "x6", "x7",
  "x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15",
  "x16", "x17", "x18", "x19", "x20", "x21", "x22", "x23",
  "x24", "x25", "x26", "x27", "x28", "x29", "x30", "x31"
};

extern "C" {
    void npc_ebreak_finish() {
        VL_PRINTF("[DPI-C] EBREAK triggered, stopping simulation.\n");
        Verilated::gotFinish(true);
        cout << "-----Result Check:-----" << endl;
        set_npc_state(NPC_END,pc,top->a0);
    }
    void show_reg(); 
    int get_reg();
    int pmem_read_v( int raddr,int len){
      return pmem_read(raddr,len);
    }
    void pmem_write_v(int waddr,  int len , int wdata){
      pmem_write(waddr,len,wdata);
    }
}

void call_show_reg() {
    svScope scope = svGetScopeFromName("TOP.top.CPU.RF");
    svSetScope(scope);
    show_reg();  
}

int isa_reg_str2val(const char *s, bool *success){

  for(int i=0;i<32;i++){
     if(strcmp(regs[i],s)==0){
      *success=true;
      svScope scope = svGetScopeFromName("TOP.top.CPU.RF");
      return top->rootp->top__DOT__CPU__DOT__RF__DOT__rf[i];
    }
  }
  for(int i=0;i<32;i++){
     if(strcmp(regs2[i],s)==0){
      *success=true;
      svScope scope = svGetScopeFromName("TOP.top.CPU.RF");
      return top->rootp->top__DOT__CPU__DOT__RF__DOT__rf[i];
    }
  }
  printf("输入的寄存器名称错误！\n");
  *success=false;
  return 0;
}

void trace_and_difftest(u_int32_t pc){
  difftest_step(pc, cpu.pc);
}

void execute(uint32_t n){
  for(int i=0;i<n;i++){
    pc=top->pc;
    single_cycle();
    trace_and_difftest(cpu.pc);//删除了decoder的部分
    if (npc_state.state != NPC_RUNNING) break;
  }
}


void cpu_exec(uint32_t n){
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT: case NPC_QUIT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }

  execute(n);
  switch (npc_state.state) {
    case NPC_RUNNING: npc_state.state = NPC_STOP; break;

    case NPC_END: case NPC_ABORT:
      cout << "npc: " 
     << (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", COLOR_RED) :
        (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", COLOR_GREEN) :
         ANSI_FMT("HIT BAD TRAP", COLOR_RED)))
     << " at pc = 0x" << hex << npc_state.halt_pc << dec<<endl;
      // fall through
    //case NPC_QUIT: statistic();
  }
}

int sim(int argc, char *argv[]) {
    init_main(argc,argv);
    // nvboard_bind_all_pins(top);
    // nvboard_init();
    sdb_mainloop();
    sim_exit();
    return 0;
}