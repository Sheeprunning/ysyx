#include <am.h>
#include <klib-macros.h>
#include <ysyxsoc.h>
#include <klib.h>

extern char _heap_start, _heap_end;
extern char _sdata, _edata, _bss_start, _lsdata;
extern size_t _data_size,_bss_size;
int main(const char *args);

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

Area heap = RANGE(&_heap_start, &_heap_end);
static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {
  outb(0x10000000, ch);
}

void halt(int code) {
  ysyxsoc_trap(code);
  while (1);
}

void _trm_init() {
  memcpy(&_sdata,&_lsdata,_data_size);
  memset(&_bss_start,0,_bss_size);
  int ret = main(mainargs);
  halt(ret);
}
