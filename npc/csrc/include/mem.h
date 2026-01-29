#ifndef _MEM_H_
#define _MEM_H_

#include <common.h>

#define CONFIG_MSIZE 0x8000000
#define CONFIG_PC_RESET_OFFSET 0x00000000
#define CONFIG_MBASE 0x80000000

extern char* img_file;
extern uint8_t *pmem;

uint8_t* guest_to_host(u_int32_t paddr);

inline u_int32_t host_read(void *addr, int len);
inline void host_write(void *addr, int len, u_int32_t data);

u_int32_t pmem_read(u_int32_t addr, int len);
void pmem_write(u_int32_t addr, int len, u_int32_t data);

int init_mem();

#endif