#include <stdint.h>
#include <nv_test.h>
#include <amtest.h>


void seg_test(){

    *(volatile uint16_t*)LED_ADDR = 0xf;
    *(volatile uint32_t*)SEG_ADDR = 0x1111;
    *(volatile uint16_t*)LED_ADDR = 0xff;
    while(1){}
}

