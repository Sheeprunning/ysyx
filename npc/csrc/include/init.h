#ifndef INIT_MEM_H
#define IMIT_MEM_H


#include <string.h>
#include <iomanip>
#include <getopt.h>
#include <iostream>
#include <assert.h>
#include "sdb.h"
#include "npc.h"
#include "log.h"
#include "disasm.h"
#include "ftrace.h"

#define CONFIG_MSIZE 0xf0000000
#define CONFIG_MBASE 0x00000000


extern uint8_t *pmem;
extern char* img_file;
extern int enable_nvboard;

int parse_args(int argc, char *argv[]);
uint8_t* guest_to_host(u_int32_t paddr);

inline u_int32_t host_read(void *addr, int len);
inline void host_write(void *addr, int len, u_int32_t data);

u_int32_t pmem_read(u_int32_t addr, int len);
void pmem_write(u_int32_t addr, int len, u_int32_t data);

void init_main(int argc, char *argv[]);

#endif