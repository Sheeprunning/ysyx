#include <stdint.h>
#include <nv_test.h>
#include <amtest.h>

#define VGA_BASE 0x21000000

void vga_test(){
    volatile uint32_t* FB = (volatile uint32_t*)VGA_BASE;
    for(int i=0;i<153600;i++){
        FB[i]=0xFFFF00;
    }
    while(1);
}