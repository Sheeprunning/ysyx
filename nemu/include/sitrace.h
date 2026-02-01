#ifndef SITRACE_H
#define SIRACE_H

#include <stdint.h>

void init_sitrace(const char *filename);
void sitrace_add(uint32_t pc);

#endif