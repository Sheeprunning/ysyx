#include "sim.h"

#include <nvboard.h>
void nvboard_bind_all_pins(TOP_NAME* dut);

using namespace std;

VerilatedContext* contextp = NULL;
// VerilatedVcdC* tfp = NULL;

TOP_NAME* top;
CPU_state cpu;
NPCState npc_state;
u_int32_t pc;
u_int32_t pre_pc;
uint64_t g_timer = 0;
uint64_t g_cycle = 0;
uint64_t g_inst  = 0;

void print_inst(u_int32_t pc_now,u_int32_t inst){//只有在打开itrace时运行
  char logbuf[128];
  char *p=logbuf;
  #ifdef ITRACE_ONCE
    if(top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__check){
      p += snprintf(p, sizeof(logbuf), FMT_WORD ":", pre_pc);
      p += snprintf(p, 120,"%08x ",inst);
      disassemble(p , logbuf+sizeof(logbuf)-p , pre_pc , (uint8_t*)&inst,4);
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
  // tfp->dump(contextp->time());
} 

void update_cpu(){
  for(int i=0;i<32;i++){
    cpu.gpr[i]=top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__CPU__DOT__RF__DOT__rf[i];
  }
  cpu.pc=top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
}

void single_cycle() {
  top->clock = 0; 
  step_and_dump_wave();
  nvboard_update();
  top->clock = 1; 
  if(top->reset!=1){
    #ifdef CONFIG_ITRACE
    print_inst(top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc,\
      top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__inst_reg);     
    #endif
  }
  step_and_dump_wave();
  #ifdef DIFFTEST
  update_cpu();
  #endif
  nvboard_update();
}

 void reset(int n=10) {
  top->reset = 1;
  while (n -- > 0) single_cycle();
  top->reset = 0;
}

void sim_init(){
  contextp = new VerilatedContext;
  // tfp = new VerilatedVcdC;
  top = new TOP_NAME{contextp};
  contextp->traceEverOn(true);
  // top->trace(tfp, 99);
  // tfp->open("wave.vcd");
  nvboard_bind_all_pins(top);
  nvboard_init();
  reset();
}

void sim_exit(){
  nvboard_quit();
  // tfp->close();
  delete top;
  // delete tfp;
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

extern "C" 
{
    void npc_ebreak_finish() {
        VL_PRINTF("[DPI-C] EBREAK triggered, stopping simulation.\n");
        Verilated::gotFinish(true);
        cout << "-----Result Check:-----" << endl;
        set_npc_state(NPC_END,pc,top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__CPU__DOT__RF__DOT__rf[10]);
    }
    void show_reg(); 
    int get_reg();
    int pmem_read_v( int raddr){
      if(raddr==RTC_ADDR||raddr==RTC_ADDR+4){
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
uint32_t flash[] = {
    0x100007b7,
    0x04100713,
    0x00e78023,
    0x00a00713,
    0x00e78023,
    0x0000006f
};
#define FLASH_BASE 0x30000000
extern "C" void flash_read(int32_t addr, int32_t *data) { 
  uint32_t araddr = FLASH_BASE + (addr&0xFFFFFFFC);
  uint32_t rdata = pmem_read(araddr,4);
  // printf("\033[1;33mread flash[0x%08x]=0x%08x\033[0m\n",araddr,rdata);
  *data=rdata; 
 }
extern "C" void mrom_read(int32_t addr, int32_t *data) { 
  //printf("read mrom[0x%08x]=0x%08x\n",addr,pmem_read(addr,4));
  *data=pmem_read(addr&0xFFFFFFFC,4); 
}

extern "C" void psram_read(int32_t addr, int32_t *data) {
  uint32_t raddr=addr+0x80000000;
  uint32_t rdata=pmem_read(raddr,4);
  // printf("read psram[0x%08x]=0x%08x\n",raddr,rdata);
  *data=rdata; 
}

extern "C" void psram_write(uint32_t addr, uint8_t data) { 
  //printf("write psram[0x%08x]=0x%08x\n",addr,data);
  pmem_write(addr+0x80000000,1,data); 
}

extern "C" void sdram_read(int32_t addr, int32_t *data) {
  uint32_t raddr=addr+0xa0000000;
  uint32_t rdata=pmem_read(raddr,4);
  // printf("read sdram[0x%08x]=0x%08x\n",raddr,rdata);
  *data=rdata; 
}

extern "C" void sdram_write(uint32_t addr, uint8_t data) { 
  // printf("write sdram[0x%08x]=0x%08x\n",addr,data);
  pmem_write(addr+0xa0000000,1,data); 
}

extern "C" void vga_read(uint32_t addr, uint32_t *data) {
  uint32_t raddr=addr+0x21000000;
  uint32_t rdata=pmem_read(raddr,4);
  // printf("read sdram[0x%08x]=0x%08x\n",raddr,rdata);
  *data=rdata; 
}

extern "C" void vga_write(uint32_t addr, uint32_t data) { 
  // printf("\033[1;32mwrite vga[0x%08x]=0x%08x\033[0m\n",addr,data);
  pmem_write(addr,4,data); 
}

void call_show_reg() {
    // svScope scope = svGetScopeFromName("TOP.top.CPU.RF");
    // svSetScope(scope);
    // show_reg(); 
    svScope scope = svGetScopeFromName("TOP.top.CPU.RF"); 
    printf("---------------------------------------------\n");
    printf("| index |  name | NPC-value |\n");
    for (int i = 0; i < 32; i++) {
      printf("|x[%2d]  |%7s|%12x|\n", i, regs[i], top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__CPU__DOT__RF__DOT__rf[i]);
    }
  
}

int isa_reg_str2val(const char *s, bool *success){

  for(int i=0;i<32;i++){
     if(strcmp(regs[i],s)==0){
      *success=true;
      return top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__CPU__DOT__RF__DOT__rf[i];
    }
  }
  for(int i=0;i<32;i++){
     if(strcmp(regs2[i],s)==0){
      *success=true;
      return top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__CPU__DOT__RF__DOT__rf[i];
    }
  }
  printf("输入的寄存器名称错误！\n");
  *success=false;
  return 0;
}

void trace_and_difftest(u_int32_t pc){
  
    if(top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__check){
      g_inst++;
      #ifdef DIFFTEST
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
    printf("Watchpoint change!Procedure stop!");
    set_npc_state(NPC_STOP, pc , -1);
    wp->value=change;
  }
#endif
}

static void statistic() {
  PRINTF_COLOR(COLOR_CYAN,"host time spent = %ld  us \n", g_timer);
  PRINTF_COLOR(COLOR_CYAN,"total cycle     = %ld \n" , g_cycle);
  PRINTF_COLOR(COLOR_CYAN,"total inst      = %ld \n" , g_inst);
  PRINTF_COLOR(COLOR_BLUE,"IPC = %ld \n" , g_inst / g_cycle);
  if (g_timer > 0) PRINTF_COLOR(COLOR_BLUE, "simulation frequency = %ld cycle/s\n", g_cycle * 1000000 / g_timer);
  else PRINTF_COLOR(COLOR_RED,"Finish running in less than 1 us and can not calculate the simulation frequency\n");
}

void execute(uint32_t n){
  for(int i=0;i<n;i++){
    pre_pc=pc;
    pc=top->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__pc;
    single_cycle();
    g_cycle++;
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

int sim(int argc, char *argv[]) {
    init_main(argc,argv);
    sdb_mainloop();
    sim_exit();
    return 0; 
}