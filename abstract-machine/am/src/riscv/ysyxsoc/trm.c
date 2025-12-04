#include <am.h>
#include <klib-macros.h>
#include <ysyxsoc.h>
#include <klib.h>

extern char _scopy, _ecopy, _lscopy;
extern char _sboot, _eboot, _lsboot;
extern char _heap_start, _heap_end;
extern char _sdata, _edata,  _lsdata , _bss_start, _bss_end;
extern char _stext, _etext, _lstext;
extern char _srodata, _erodata, _lsrodata;
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

#define COPY_SECTION __attribute__((section("copy")))

COPY_SECTION __attribute__((noinline)) 
void bootset(void *s, int c, size_t n) {
  char *p=s;
  for(int i=0;i<n;i++){
    *p=c;
    p++;
  }
}

COPY_SECTION __attribute__((noinline)) 
void bootcpy(void *out, const void *in, size_t n) {
  unsigned char *d = out;
  const unsigned char *s = in;
  while(n--) {
    *d++ = *s++;
  }
}

#define ENTRY_SECTION __attribute__((section("entry")))

ENTRY_SECTION void copy_bootloader(){
  size_t copy_size = &_ecopy - &_scopy;
  char *dest = &_scopy;
  const char *src = &_lscopy;
  
  for(size_t i = 0; i < copy_size; i++) {
    dest[i] = src[i];
  }
}


ENTRY_SECTION void fsbl_bootloader(){
  size_t boot_size = &_eboot - &_sboot;
  char *dest = &_sboot;
  const char *src = &_lsboot;
  
  bootcpy(dest,src,boot_size);
}


#define BOOT_SECTION __attribute__((section("boot")))

BOOT_SECTION void _bootloader(){
  size_t data_size = &_edata - &_sdata;
  size_t rodata_size = &_erodata - &_srodata;
  size_t text_size = &_etext - &_stext;
  size_t bss_size = &_bss_end - &_bss_start;
  bootcpy(&_sdata,&_lsdata,data_size);
  bootcpy(&_srodata,&_lsrodata,rodata_size);
  bootcpy(&_stext,&_lstext,text_size);
  bootset(&_bss_start,0,bss_size);
  return ;
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
  _bootloader();
  uart_init();
  //id_read();
  int ret = main(mainargs);
  halt(ret);
}
