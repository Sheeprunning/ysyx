#include <string.h>
#include <iomanip>
#include <getopt.h>
#include <iostream>
#include <assert.h>

#ifndef INIT_MEM
#define IMIT_MEM

extern uint8_t *pmem;
extern u_int32_t pc;
extern char* img_file;


int parse_args(int argc, char *argv[]);
uint8_t* guest_to_host(u_int32_t paddr);

inline u_int32_t host_read(void *addr, int len);
inline void host_write(void *addr, int len, u_int32_t data);

u_int32_t pmem_read(u_int32_t addr, int len);
void pmem_write(u_int32_t addr, int len, u_int32_t data);

void init_mem();

#endif