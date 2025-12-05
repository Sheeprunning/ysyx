#ifndef _DUT_H_
#define _DUT_H_

#include <dlfcn.h>
#include <assert.h>
#include "init.h"
#include <stdio.h>
#include <stdlib.h>
#include "npc.h"



void difftest_step(u_int32_t pc, u_int32_t npc);
void init_difftest(char *ref_so_file, long img_size, int port) ;
void difftest_skip_ref();
void difftest_skip_dut(int nr_ref, int nr_dut) ;

#endif