#include <stdint.h>
#include <mem_test.h>
#include <amtest.h>

#define SDRAM_BASE 0xA0000000
#define BEGIN 16*1024*1024
#define num_words /* 16384 */16

void sdram_test_8bit() {
    volatile uint8_t *addr8 = (volatile uint8_t *)SDRAM_BASE;
    for (int i = BEGIN; i < num_words+BEGIN; i++) {
        addr8[i] = (uint8_t)(i & 0xFF);
    }
    for (int i = BEGIN; i < num_words+BEGIN; i++) {
        printf("sdram[%08x]=%02x\n",i,addr8[i]);
        if (addr8[i] != (uint8_t)(i & 0xFF)) {
            printf("sdram[%d]=%02x Should be %02x",i,addr8[i],(uint8_t)(i & 0xFF));
            halt(1);
        }
    }
}
void sdram_test_16bit() {
    volatile uint16_t *addr16 = (volatile uint16_t *)SDRAM_BASE;
    for (int i = BEGIN; i < num_words+BEGIN; i+=2) {
        addr16[i] = (uint16_t)(i & 0xFFFF);
    }
    
    for (int i = BEGIN; i < num_words+BEGIN; i+=2) {
        printf("sdram[%08x]=%04x\n",i,addr16[i]);
        if (addr16[i] != (uint16_t)(i & 0xFFFF)) {
            halt(1);
        }
    }
}
void sdram_test_32bit() {
    volatile uint32_t *addr32 = (volatile uint32_t *)SDRAM_BASE;
    for (int i = BEGIN; i < num_words+BEGIN; i+=4) {
        addr32[i] = (uint32_t)(i & 0xFFFFFFFF);
    }
    
    for (int i = BEGIN; i < num_words+BEGIN; i+=4) {
        printf("sdram[%08x]=%08x\n",i,addr32[i]);
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

