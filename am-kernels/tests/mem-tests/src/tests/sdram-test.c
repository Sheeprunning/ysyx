#include <stdint.h>
#include <sdram_test.h>
#include <amtest.h>

#define SDRAM_BASE 0xA0000000

#define num_words 16

void sdram_test_8bit() {
    volatile uint8_t *addr8 = (volatile uint8_t *)SDRAM_BASE;
    for (int i = 0; i < num_words; i++) {
        addr8[i] = (uint8_t)(i & 0xFF);
    }
    for (int i = 0; i < num_words; i++) {
        if (addr8[i] != (uint8_t)(i & 0xFF)) {
            halt(1);
        }
    }
}
void sdram_test_16bit() {
    volatile uint16_t *addr16 = (volatile uint16_t *)SDRAM_BASE;
    for (int i = 0; i < num_words; i+=2) {
        addr16[i] = (uint16_t)(i & 0xFFFF);
    }
    
    for (int i = 0; i < num_words; i+=2) {
        if (addr16[i] != (uint16_t)(i & 0xFFFF)) {
            halt(1);
        }
    }
}
void sdram_test_32bit() {
    volatile uint32_t *addr32 = (volatile uint32_t *)SDRAM_BASE;
    for (int i = 0; i < num_words; i+=4) {
        addr32[i] = (uint32_t)(i & 0xFFFFFFFF);
    }
    
    for (int i = 0; i < num_words; i+=4) {
        if (addr32[i] != (uint32_t)(i & 0xFFFFFFFF)) {
            halt(1);
        }
    }
}
void sdram_test(){
    sdram_test_8bit();
    sdram_test_16bit();
    sdram_test_32bit();
}

