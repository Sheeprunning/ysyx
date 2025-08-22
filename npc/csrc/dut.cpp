#include "dut.h"

#define DIFFTEST_TO_REF 1
#define DIFFTEST_TO_DUT 0

void (*ref_difftest_memcpy)(u_int32_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;

static bool is_skip_ref = false;
static int skip_dut_nr_inst = 0;


void difftest_skip_ref() {
  is_skip_ref = true;
  skip_dut_nr_inst = 0;
}


void difftest_skip_dut(int nr_ref, int nr_dut) {
  skip_dut_nr_inst += nr_dut;

  while (nr_ref -- > 0) {
    ref_difftest_exec(1);
  }
}



void init_difftest(char *ref_so_file, long img_size, int port) {
  printf("正在将%s放入ref\n",ref_so_file);
  assert(ref_so_file != NULL);

  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);

  ref_difftest_memcpy = (void (*)(u_int32_t, void*, size_t, bool))dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);

  ref_difftest_regcpy = (void (*)(void*, bool))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);

  ref_difftest_exec = (void (*)(uint64_t))dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  ref_difftest_raise_intr =  (void (*)(uint64_t))dlsym(handle, "difftest_raise_intr");
  assert(ref_difftest_raise_intr);

  void (*ref_difftest_init)(int) = (void (*)(int))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  ref_difftest_init(port);
  ref_difftest_memcpy(CONFIG_MBASE, guest_to_host(CONFIG_MBASE), img_size, DIFFTEST_TO_REF);
  ref_difftest_regcpy(&cpu, DIFFTEST_TO_REF);
}

void print_dut_and_ref(CPU_state *ref_r,int p){
  printf("---------------------------------------------\n");
  printf("| index |  name | NPC-value | NEMU-value|\n");
  for (int i = 0; i < 32; i++) {
    if(i==p)printf("->");
    printf("|x[%2d]  |%7s|%12x|%12x|\n", i, regs[i], cpu.gpr[i], ref_r->gpr[i]);
  }

    printf("|   dnpc|   dnpc|%12x|%12x|\n",cpu.pc, ref_r->pc);
  printf("---------------------------------------------\n");
}

bool isa_difftest_checkregs(CPU_state *ref_r, u_int32_t pc) {
  if(ref_r->pc!=cpu.pc){
    print_dut_and_ref(ref_r,-1);
    return false;
  }
    
  for(int i=0;i<32;i++){
    if(ref_r->gpr[i] !=cpu.gpr[i]){
      print_dut_and_ref(ref_r,i);
      return false;
    }
      
  }
  return true;
}

static void checkregs(CPU_state *ref, u_int32_t pc) {
  if (!isa_difftest_checkregs(ref, pc)) {
    npc_state.state = NPC_ABORT;
    npc_state.halt_pc = pc;
    
  }
}

void difftest_step(u_int32_t pc, u_int32_t npc) {
  CPU_state ref_r;

  if (skip_dut_nr_inst > 0) {
    ref_difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);
    if (ref_r.pc == npc) {
      skip_dut_nr_inst = 0;
      checkregs(&ref_r, npc);
      return;
    }
    skip_dut_nr_inst --;
    if (skip_dut_nr_inst == 0)
      printf("can not catch up with ref.pc = " FMT_WORD " at pc = " FMT_WORD "\n", ref_r.pc, pc);
    return;
  }

  if (is_skip_ref) {
    // to skip the checking of an instruction, just copy the reg state to reference design
    ref_difftest_regcpy(&cpu, DIFFTEST_TO_REF);
    is_skip_ref = false;
    return;
  }

  ref_difftest_exec(1);
  ref_difftest_regcpy(&ref_r, DIFFTEST_TO_DUT);

  checkregs(&ref_r, pc);
}