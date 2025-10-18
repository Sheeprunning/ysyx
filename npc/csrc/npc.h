#ifndef _NPC_H_
#define _NPC_H_

#include <iostream>
#include "dut.h"

// #define CONFIG_FTRACE 1
// #define CONFIG_MTRACE 1
#define CONFIG_WATCHPOINT 1
#define CONFIG_ITRACE 1
#define DIFFTEST 1


#define FMT_WORD "0x%08x"
#define COLOR_RED     "\033[1;31m"
#define COLOR_GREEN   "\033[1;32m"
#define COLOR_YELLOW  "\033[1;33m"
#define COLOR_BLUE    "\033[1;34m"
#define COLOR_MAGENTA "\033[1;35m"
#define COLOR_CYAN    "\033[1;36m"
#define COLOR_RESET   "\033[0m"
#define ANSI_FMT(str, color) color str COLOR_RESET

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

typedef struct 
{
  u_int32_t gpr[32];
  u_int32_t pc;
    
}CPU_state;

extern CPU_state cpu;

enum { NPC_RUNNING, NPC_STOP, NPC_END, NPC_ABORT, NPC_QUIT };

typedef struct {
  int state;
  u_int32_t halt_pc;
  uint32_t halt_ret;
} NPCState;

extern NPCState npc_state;

void set_npc_state(int state, u_int32_t pc, int halt_ret);

#endif