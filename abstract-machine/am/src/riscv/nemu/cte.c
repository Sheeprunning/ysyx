#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

#define YIELD   11

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  printf("0x%08x\n",0x80001520);
  //printf("mcause:0x%08x mstatus:0x%08x mepc:0x%08x\n",c->mcause,c->mstatus,c->mepc);
  if (user_handler) {
    Event ev = {0};
    switch (c->mcause) {
      case YIELD: c->mepc+=4;ev.event = EVENT_YIELD;break;
      default: ev.event = EVENT_ERROR; break;
    }

    c = user_handler(ev, c);
    assert(c != NULL);
  }

  return c;
}

extern void __am_asm_trap(void);//在trap.S中定义

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));//将自陷指令段的首地址传入

  // register event handler
  user_handler = handler;//初始化回调函数

  return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  Context *c=(Context*) ((uintptr_t)kstack.end-sizeof(Context));
  c->mepc=(uintptr_t)entry;
  c->gpr[10]=(uintptr_t)arg;
  return c;
}

void yield() {
#ifdef __riscv_e
  asm volatile("li a5, -1; ecall");
#else
  asm volatile("li a7, -1; ecall");
#endif
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
}
