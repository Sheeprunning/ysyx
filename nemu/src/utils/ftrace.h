#ifndef FTRACE_H
#define FTRACE_H

#include <stdio.h>
#include <stdlib.h>
#include <elf.h>
#include <string.h>

typedef struct 
{
    const char *name;
    unsigned long start;
    unsigned long end;
}Func;

extern Func func[100];
extern int func_size;

int process_elf_file(const char* filename);

void print_symbol(Elf32_Sym *sym, const char *strtab);

int func_judge(unsigned long address);

void jal_ftrace(int rd,uint32_t pc,uint32_t target);

void jalr_ftrace(int32_t inst,int rd,int imm,uint32_t pc,uint32_t target);

#endif