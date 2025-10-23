#include <am.h>
#include <klib-macros.h>
#include <ysyxsoc.h>
#include <klib.h>

extern char _heap_start, _heap_end;
extern char _sdata, _edata, _bss_start, _bss_end, _lsdata;
int main(const char *args);

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

Area heap = RANGE(&_heap_start, &_heap_end);
static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {
  //while( (inb(UART_LSR) & 0x40) == 0);
  outb(UART_THR, ch);
}

void halt(int code) {
  ysyxsoc_trap(code);
  while (1);
}

void rom_to_sram(){
  size_t data_size = &_edata - &_sdata;
  size_t bss_size = &_bss_end - &_bss_start;
  memcpy(&_sdata,&_lsdata,data_size);
  memset(&_bss_start,0,bss_size);
}

void uart_init() {
  uint8_t lcr = inb(UART_LCR);
  outb(UART_LCR,lcr | 0x80);
  outb(UART_MSB,0);
  outb(UART_LSB,5);
  outb(UART_LCR,lcr & 0x7F);
}

void _trm_init() {
  rom_to_sram();
  uart_init();
  int ret = main(mainargs);
  halt(ret);
}
