#include <stdint.h>
#include <nv_test.h>
#include <amtest.h>

#define VGA_BASE 0x21000000

void vga_test(){
    volatile uint32_t* FB = (volatile uint32_t*)VGA_BASE;
    for(int i=0;i<240;i++){
        for(int j = 0;j<160;j++){//j是横宽
            FB[i*320+j]=0xFFFF00;
        } 
    }
    for(int i=0;i<240;i++){
        for(int j = 0;j<160;j++){
            FB[(i+240)*320+j+160]=0xFF00FF;//j是横宽
        } 
    }
    while(1);
}