#include <stdint.h>
#include <nv_test.h>
#include <amtest.h>

#define GPIO_BASE 0x10002000

void led_test(){
    uint16_t x = 1;
    while(1){
        *(uint16_t*)GPIO_BASE = x;
        uint16_t msb = (x >> 15) & 0x1;
        // 左移1位，再将最高位补到最低位
        x = (x << 1) | msb;
    }
}

