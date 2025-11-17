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

static inline uint32_t read_csr(int csr) {
    uint32_t value;
    __asm__ volatile ("csrr %0, %1" : "=r"(value) : "i"(csr));
    return value;
}

void putch(char ch) {
  while( (inb(UART_LSR) & 0x20) == 0);
  outb(UART_THR, ch);
}

void halt(int code) {
  ysyxsoc_trap(code);
  while (1);
}

void bootloader(){
  size_t data_size = &_edata - &_sdata;
  size_t bss_size = &_bss_end - &_bss_start;
  memcpy(&_sdata,&_lsdata,data_size);
  memset(&_bss_start,0,bss_size);
}

void uart_init() {
  uint8_t lcr = inb(UART_LCR);
  outb(UART_LCR,lcr | 0x80); 
  outb(UART_MSB,0);
  outb(UART_LSB,1);
  outb(UART_LCR,lcr & 0x7F);
}

void id_read(void) {
    uint32_t vendor_id = read_csr(0xf11);  // mvendorid
    uint32_t arch_id = read_csr(0xf12);    // marchid
    printf("0x%x 0x%x\n", vendor_id,arch_id);
}

void _trm_init() {
  bootloader();
  uart_init();
  //id_read();
  int ret = main(mainargs);
  halt(ret);
}
