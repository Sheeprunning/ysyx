#ifndef YSYXSOC_H__
#define YSYXSOC_H__

#include <klib-macros.h>

#include ISA_H // the macro `ISA_H` is defined in CFLAGS
               // it will be expanded as "x86/x86.h", "mips/mips32.h", ...

#if defined(__ISA_X86__)
# define ysyxsoc_trap(code) asm volatile ("int3" : :"a"(code))
#elif defined(__ISA_MIPS32__)
# define ysyxsoc_trap(code) asm volatile ("move $v0, %0; sdbbp" : :"r"(code))
#elif defined(__riscv)
# define ysyxsoc_trap(code) asm volatile("mv a0, %0; ebreak" : :"r"(code))
#elif defined(__ISA_LOONGARCH32R__)
# define ysyxsoc_trap(code) asm volatile("move $a0, %0; break 0" : :"r"(code))
#else
# error unsupported ISA __ISA__
#endif

#if defined(__ARCH_X86_YSYXSOC)
# define DEVICE_BASE 0x0
#else
# define DEVICE_BASE 0xa0000000
#endif

static const int key_code_to_enum[256] = {
  // 初始化所有值为AM_KEY_NONE
  [0 ... 255] = AM_KEY_NONE,
  // 按通码填写对应枚举
  [0x76] = AM_KEY_ESCAPE,
  [0x05] = AM_KEY_F1,
  [0x06] = AM_KEY_F2,
  [0x04] = AM_KEY_F3,
  [0x0C] = AM_KEY_F4,
  [0x03] = AM_KEY_F5,
  [0x0B] = AM_KEY_F6,
  [0x83] = AM_KEY_F7,
  [0x0A] = AM_KEY_F8,
  [0x01] = AM_KEY_F9,
  [0x09] = AM_KEY_F10,
  [0x78] = AM_KEY_F11,
  [0x07] = AM_KEY_F12,
  [0x0E] = AM_KEY_GRAVE,
  [0x16] = AM_KEY_1,
  [0x1E] = AM_KEY_2,
  [0x26] = AM_KEY_3,
  [0x25] = AM_KEY_4,
  [0x2E] = AM_KEY_5,
  [0x36] = AM_KEY_6,
  [0x3D] = AM_KEY_7,
  [0x3E] = AM_KEY_8,
  [0x46] = AM_KEY_9,
  [0x45] = AM_KEY_0,
  [0x4E] = AM_KEY_MINUS,
  [0x55] = AM_KEY_EQUALS,
  [0x66] = AM_KEY_BACKSPACE,
  [0x0D] = AM_KEY_TAB,
  [0x15] = AM_KEY_Q,
  [0x1D] = AM_KEY_W,
  [0x24] = AM_KEY_E,
  [0x2D] = AM_KEY_R,
  [0x2C] = AM_KEY_T,
  [0x35] = AM_KEY_Y,
  [0x3C] = AM_KEY_U,
  [0x43] = AM_KEY_I,
  [0x44] = AM_KEY_O,
  [0x4D] = AM_KEY_P,
  [0x54] = AM_KEY_LEFTBRACKET,
  [0x5B] = AM_KEY_RIGHTBRACKET,
  [0x5D] = AM_KEY_BACKSLASH,
  [0x58] = AM_KEY_CAPSLOCK,
  [0x1C] = AM_KEY_A,
  [0x1B] = AM_KEY_S,
  [0x23] = AM_KEY_D,
  [0x2B] = AM_KEY_F,
  [0x34] = AM_KEY_G,
  [0x33] = AM_KEY_H,
  [0x3B] = AM_KEY_J,
  [0x42] = AM_KEY_K,
  [0x4B] = AM_KEY_L,
  [0x4C] = AM_KEY_SEMICOLON,
  [0x52] = AM_KEY_APOSTROPHE,
  [0x5A] = AM_KEY_RETURN,
  [0x12] = AM_KEY_LSHIFT,
  [0x1A] = AM_KEY_Z,
  [0x22] = AM_KEY_X,
  [0x21] = AM_KEY_C,
  [0x2A] = AM_KEY_V,
  [0x32] = AM_KEY_B,
  [0x31] = AM_KEY_N,
  [0x3A] = AM_KEY_M,
  [0x41] = AM_KEY_COMMA,
  [0x49] = AM_KEY_PERIOD,
  [0x4A] = AM_KEY_SLASH,
  [0x59] = AM_KEY_RSHIFT,
  [0x14] = AM_KEY_LCTRL,
  [0x65] = AM_KEY_APPLICATION,
  [0x11] = AM_KEY_LALT,
  [0x29] = AM_KEY_SPACE,
  [0x75] = AM_KEY_UP,
  [0x72] = AM_KEY_DOWN,
  [0x6B] = AM_KEY_LEFT,
  [0x74] = AM_KEY_RIGHT,
  [0x70] = AM_KEY_INSERT,
  [0x71] = AM_KEY_DELETE,
  [0x6C] = AM_KEY_HOME,
  [0x69] = AM_KEY_END,
  [0x7D] = AM_KEY_PAGEUP,
  [0x7A] = AM_KEY_PAGEDOWN,
};


#define UART_BASE 0x10000000L

#define UART_RB   (UART_BASE + 0)
#define UART_THR  (UART_BASE + 0)
#define UART_IE   (UART_BASE + 1)
#define UART_II   (UART_BASE + 2)
#define UART_FC   (UART_BASE + 2)
#define UART_LCR  (UART_BASE + 3)
#define UART_MC   (UART_BASE + 4)
#define UART_LSR  (UART_BASE + 5)
#define UART_MS   (UART_BASE + 6)
#define UART_LSB  (UART_BASE + 0)
#define UART_MSB  (UART_BASE + 1)

#define MMIO_BASE 0xa0000000

#define SERIAL_PORT     (DEVICE_BASE + 0x00003f8)
#define KBD_ADDR        (0x10011000)
#define RTC_ADDR        (DEVICE_BASE + 0x0000048)
#define VGACTL_ADDR     (DEVICE_BASE + 0x0000100)
#define AUDIO_ADDR      (DEVICE_BASE + 0x0000200)
#define DISK_ADDR       (DEVICE_BASE + 0x0000300)
#define FB_ADDR         (0x21000000)
#define AUDIO_SBUF_ADDR (MMIO_BASE   + 0x1200000)

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)
#define YSYXSOC_PADDR_SPACE \
  RANGE(&_pmem_start, PMEM_END), \
  RANGE(FB_ADDR, FB_ADDR + 0x200000), \
  RANGE(MMIO_BASE, MMIO_BASE + 0x1000) /* serial, rtc, screen, keyboard */

typedef uintptr_t PTE;

#define PGSIZE    4096

#endif
