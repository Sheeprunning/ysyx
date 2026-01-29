#include <common.h>
#include <sim.h>
#include <npc.h>
#include <timer.h>
#include <device.h>
#include <disasm.h>
#include <log.h>
#include <mem.h>
#include <dut.h>
#include <breakpoint.h>
// #include <nvboard.h>
#include <string.h>
#include <vector>

// void nvboard_bind_all_pins(TOP_NAME* dut);

using namespace std;

VerilatedContext* contextp = NULL;
#ifdef WAVE
VerilatedVcdC* tfp = NULL;
#endif

TOP_NAME* top;
CPU_state cpu;
NPCState npc_state;

uint32_t inst_fi;//执行完成的指令
uint64_t g_timer = 0;
uint64_t g_cycle = 0;
uint64_t g_inst  = 0;

bool exc_inst=0;

void print_inst(u_int32_t pc_now,u_int32_t inst){//只有在打开itrace时运行
  char logbuf[128];
  char *p=logbuf;
  #ifdef ITRACE_ONCE
    if(!top->reset){
      p += snprintf(p, sizeof(logbuf), FMT_WORD ":", cpu.pre_pc);
      p += snprintf(p, 120,"%08x ",inst);
      disassemble(p , logbuf+sizeof(logbuf)-p , cpu.pre_pc , (uint8_t*)&inst,4);
      printf(COLOR_BLUE "%s\n" COLOR_RESET,logbuf);
      log_add("itrace.txt",logbuf);
    }
  #else
  p += snprintf(p, sizeof(logbuf), FMT_WORD ":", pc_now);
  p += snprintf(p, 120,"%08x ",inst);
  disassemble(p , logbuf+sizeof(logbuf)-p , pc_now , (uint8_t*)&inst,4);
  printf(COLOR_BLUE "%s\n" COLOR_RESET,logbuf);
  log_add("itrace.txt",logbuf);
  #endif
}

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(10);
} 

void update_cpu(){
  for(int i=0;i<32;i++){
    cpu.gpr[i]=top->rootp->top__DOT__CPU__DOT__RF__DOT__rf[i];
  }
  cpu.pre_pc=cpu.pc;
  cpu.pc=top->pc;
}

void single_cycle() {
  #ifdef CONFIG_BREAKPOINT
  inst_fi=top->inst;
  #endif
  top->clock = 0; 
  step_and_dump_wave();
  //nvboard_update();
  #ifdef CONFIG_ITRACE
  if(top->reset!=1){//所有非阻塞赋值会在第二个eval赋值，这里我们可以当做是下降沿赋值，下降沿赋值后相应的inst也会立马更新
    print_inst(top->pc,\
      top->inst);     
  } 
  #endif
  
  top->clock = 1; 

  if(!top->reset)top->inst=pmem_read(top->pc,4);
  
  step_and_dump_wave();
  #ifdef WAVE
  tfp->dump(contextp->time());
  #endif
  update_cpu();
  //nvboard_update();
}

 void reset(int n=10) {
  top->reset = 1;
  while (n -- > 0) single_cycle();
  top->reset = 0;
}

void sim_init(){
  contextp = new VerilatedContext;
  top = new TOP_NAME{contextp};
  contextp->traceEverOn(true);
  #ifdef WAVE
  tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  tfp->open("wave.vcd");
  #endif
  //nvboard_bind_all_pins(top);
  //nvboard_init();
  reset();
}

void sim_exit(){
  //nvboard_quit();
  #ifdef WAVE
  tfp->close();
  delete tfp;
  #endif
  delete top;
  delete contextp;
  cout<<"仿真结束！\n";
}

extern "C" 
{
    void npc_ebreak_finish() {
        VL_PRINTF("[DPI-C] EBREAK triggered, stopping simulation.\n");
        Verilated::gotFinish(true);
        cout << "-----Result Check:-----" << endl;
        set_npc_state(NPC_END,top->pc,\
          top->rootp->top__DOT__CPU__DOT__RF__DOT__rf[10]);
    }
    int pmem_read_v( int raddr){
      if(raddr==RTC_ADDR||raddr==RTC_ADDR+4){
        #ifdef CONFIG_DIFFTEST
          check_load_range(top->inst,raddr);
        #endif
        uint64_t us = get_time();
        if(raddr==RTC_ADDR)
          return (uint32_t)us;
        else 
          return us>>32;
      }else{
        return pmem_read(raddr,4);
      }
    
    }
    void pmem_write_v(int waddr,  int len , int wdata){
      if(waddr==SERIAL_PORT){
        putchar(wdata); 
      }else{
        pmem_write(waddr,len,wdata);
      }
    }
}

void call_show_reg() {
    svScope scope = svGetScopeFromName("TOP.top.CPU.RF"); 
    printf("---------------------------------------------\n");
    printf("| index |  name | NPC-value |\n");
    for (int i = 0; i < 32; i++) {
      printf("|x[%2d]  |%7s|%12x|\n", i, regs[i], top->rootp->top__DOT__CPU__DOT__RF__DOT__rf[i]);
    }
  
}

int isa_reg_str2val(const char *s, bool *success){

  for(int i=0;i<32;i++){
     if(strcmp(regs[i],s)==0){
      *success=true;
      return top->rootp->top__DOT__CPU__DOT__RF__DOT__rf[i];
    }
  }
  for(int i=0;i<32;i++){
     if(strcmp(regs2[i],s)==0){
      *success=true;
      return top->rootp->top__DOT__CPU__DOT__RF__DOT__rf[i];
    }
  }
  printf("输入的寄存器名称错误！\n");
  *success=false;
  return 0;
}

void trace_and_difftest(u_int32_t pc){
  g_cycle++;
    if(!top->reset){
      g_inst++;
      #ifdef CONFIG_DIFFTEST
      difftest_step(pc, cpu.pc);
      #endif
    }
  
  #ifdef CONFIG_WATCHPOINT
  bool success=true;
  int change;
  WP *wp = compare_watchpoint(&success,&change);
  if(wp){
    printf("--NO-- --EXP-- --VALUE--\n");
    printf("%-8d %-7s %-#8x->%#x\n",wp->NO,wp->wp_exp,wp->value,change);
    printf("Watchpoint change!Procedure stop!\n");
    set_npc_state(NPC_STOP, pc , -1);
    wp->value=change;
  }
  #endif
  #ifdef CONFIG_BREAKPOINT
    if(compare_bp(cpu.pc)){
      printf("pc is equal to Break point!Procedure stop!\n");
      set_npc_state(NPC_STOP, pc , -1);
    }
  #endif
}

// static void show_performance(){
//   for(int i=0;i<3;i++){
//     float ave=(float)pfm_cycle[i]/(float)pfm_counter[i];
//     PRINTF_COLOR(COLOR_CYAN,"the num of %28s is %10d ,cycle = %10d average = %.5f\n" , pfm_name[i],pfm_counter[i],pfm_cycle[i],ave);
//   }
//   for(int i=3;i<7;i++){
//     PRINTF_COLOR(COLOR_CYAN,"the num of %28s is %10d \n",pfm_name[i],pfm_counter[i]);
//   }
// }

static void statistic() {
  PRINTF_COLOR(COLOR_CYAN,"host time spent = %ld  us \n", g_timer);
  PRINTF_COLOR(COLOR_CYAN,"total cycle     = %ld \n" , g_cycle);
  PRINTF_COLOR(COLOR_CYAN,"total inst      = %ld \n" , g_inst);
  PRINTF_COLOR(COLOR_BLUE,"CPI = %ld \n" , g_cycle / g_inst);
  // show_performance();
  if (g_timer > 0) PRINTF_COLOR(COLOR_BLUE, "simulation frequency = %ld cycle/s\n", g_cycle * 1000000 / g_timer);
  else PRINTF_COLOR(COLOR_RED,"Finish running in less than 1 us and can not calculate the simulation frequency\n");
  
}

void execute(uint32_t n){
  for(int i=0;i<n;i++){
    single_cycle();
    
    trace_and_difftest(cpu.pc);
          
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
  uint64_t timer_start = get_time();
  execute(n);

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (npc_state.state) {
    case NPC_RUNNING: npc_state.state = NPC_STOP; break;

    case NPC_END: case NPC_ABORT:
      cout << "npc: " 
     << (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", COLOR_RED) :
        (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", COLOR_GREEN) :
         ANSI_FMT("HIT BAD TRAP", COLOR_RED)))
     << " at pc = 0x" << hex << npc_state.halt_pc << dec<<endl;
      // fall through
    case NPC_QUIT: statistic();
  }
}

void exec_inst(int n){
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT: case NPC_QUIT:
      printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }
  while (n!=0)
    {
      execute(1);
      if(!top->reset){
        print_inst(cpu.pre_pc,inst_fi); 
          n--;
      }
      if (npc_state.state != NPC_RUNNING) break;
    }
}
