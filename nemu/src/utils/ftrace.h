#ifndef FTRACE_H
#define FTRACE_H

#include <stdio.h>
#include <stdlib.h>
#include <elf.h>
#include <string.h>

int process_elf_file(const char* filename);
void print_symbol(Elf32_Sym *sym, const char *strtab);


#endif