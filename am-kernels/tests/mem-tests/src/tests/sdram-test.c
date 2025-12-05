#include <stdint.h>
#include <sdram_test.h>

#define SDRAM_BASE 0xA0000000

void quick_sdram_test() {
    volatile uint8_t *addr8 = (volatile uint8_t *)SDRAM_BASE;
    // for (int i = 0; i < 10; i++) {
    //     addr8[i] = i & 0xFF;
    // }
    for (int i = 0; i < 10; i++) {
        if (addr8[i] != (i & 0xFF)) {
            return;
        }
    }
}
void sdram_test(){
    quick_sdram_test();
}

