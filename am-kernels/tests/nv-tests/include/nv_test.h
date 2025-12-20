#ifndef __NV_H__
#define __NV_H__

#define GPIO_BASE 0x10002000

#define DIG_ADDR  (GPIO_BASE + 0x4)
#define SEG_ADDR  (GPIO_BASE + 0x8)

void gpio_test();
void vga_test();
#endif