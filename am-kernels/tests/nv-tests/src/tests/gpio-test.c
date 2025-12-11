#include <stdint.h>
#include <nv_test.h>
#include <amtest.h>

static inline uint32_t read_csr(int csr) {
    uint32_t value;
    __asm__ volatile ("csrr %0, %1" : "=r"(value) : "i"(csr));
    return value;
}
void gpio_test(){
    uint16_t x = 1;
    uint16_t d = 0;
    uint32_t arch_id = read_csr(0xf12);
    uint32_t stu_id  = 0x25080204;
    printf("ID:0x%08x 25080204\n",arch_id);
    while (1){
        d=*(volatile uint16_t*)DIG_ADDR;
        printf("dig:%d\n",d);
        if(d==1) *(volatile uint32_t*)SEG_ADDR=stu_id;
        else *(volatile uint32_t*)SEG_ADDR=arch_id;
        
        *(volatile uint16_t*)GPIO_BASE = x;
        uint16_t msb = (x >> 15) & 0x1;
        x = (x << 1) | msb;
        for(int i =0 ;i<1000;i++);
    }
    
    
    
}

