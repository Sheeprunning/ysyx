#ifndef _DISASM_H_
#define _DISASM_H_

#include <common.h>

void init_disasm();
void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte); 
#endif