#ifndef _NPC_H_
#define _NPC_H_

#include <common.h>

#define DEVICE_BASE 0xa0000000
#define MMIO_BASE 0xa0000000

#define SERIAL_PORT     (DEVICE_BASE + 0x00003f8)
#define KBD_ADDR        (DEVICE_BASE + 0x0000060)
#define RTC_ADDR        (DEVICE_BASE + 0x0000048)
#define VGACTL_ADDR     (DEVICE_BASE + 0x0000100)
#define AUDIO_ADDR      (DEVICE_BASE + 0x0000200)
#define DISK_ADDR       (DEVICE_BASE + 0x0000300)
#define FB_ADDR         (MMIO_BASE   + 0x1000000)
#define AUDIO_SBUF_ADDR (MMIO_BASE   + 0x1200000)

// typedef struct{
//   word_t mtvec;//存异常入口地址
//   vaddr_t mepc;//存放触发异常的PC
//   word_t mstatus;//存放处理器的状态
//   word_t mcause;//存放触发异常的原因
// }CSR;

typedef struct 
{
  u_int32_t gpr[32];
  u_int32_t pc;
  u_int32_t pre_pc;
  unsigned int priv: 2;
  // CSR csr;  
}CPU_state;

extern CPU_state cpu;
extern const char *regs[]; 
extern const char *regs2[]; 

enum { NPC_RUNNING, NPC_STOP, NPC_END, NPC_ABORT, NPC_QUIT };

typedef struct {
  int state;
  u_int32_t halt_pc;
  uint32_t halt_ret;
} NPCState;

extern NPCState npc_state;

void set_npc_state(int state, u_int32_t pc, int halt_ret);

#endif