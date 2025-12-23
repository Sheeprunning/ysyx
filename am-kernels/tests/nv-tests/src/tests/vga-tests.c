#include <stdint.h>
#include <nv_test.h>
#include <amtest.h>

#define VGA_BASE 0x21000000

void vga_test(){
    volatile uint32_t* FB = (volatile uint32_t*)VGA_BASE;
    for(int i=0;i<240;i++){
        for(int j = 0;j<320;j++){
            FB[i*320+j]=0xFFFF00;//j是横宽
        }
        
    }
    for(int i=0;i<6400;i++){
        FB[i+12800]=0xFF00FF;
    }
    while(1);
}