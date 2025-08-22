//我把和npc有关的全放在这好了
#ifndef _NPC_H_
#define _NPC_H_

#include <iostream>
#include "dut.h"

#define FMT_WORD "0x%08x"


typedef struct 
{
    u_int32_t pc;
    u_int32_t gpr[32];
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