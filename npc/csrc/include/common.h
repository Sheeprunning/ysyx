#ifndef __COMMON_H__
#define __COMMON_H__

// #define CONFIG_FTRACE 1
// #define CONFIG_MTRACE 1
// #define CONFIG_WATCHPOINT 1
// #define CONFIG_ITRACE 1
// #define ITRACE_ONCE 1
// #define CONFIG_DIFFTEST 1
// #define CONFIG_BREAKPOINT 1
// #define WAVE


#include <stdint.h>
#include <inttypes.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <iostream>
#include <iomanip>

#define FMT_WORD "0x%08x"
#define COLOR_RED     "\033[1;31m"
#define COLOR_GREEN   "\033[1;32m"
#define COLOR_YELLOW  "\033[1;33m"
#define COLOR_BLUE    "\033[1;34m"
#define COLOR_MAGENTA "\033[1;35m"
#define COLOR_CYAN    "\033[1;36m"
#define COLOR_RESET   "\033[0m"
#define ANSI_FMT(str, color) color str COLOR_RESET

#define GET_BASENAME(path) ({ \
    const char* p = (path); \
    const char* base = strrchr(p, '/'); \
    base ? base + 1 : p; \
})

#define PRINTF_COLOR(color, format, ...) do { \
    printf("%s[%s:%d] " format "%s", color, \
        GET_BASENAME(__FILE__), __LINE__,\
         ##__VA_ARGS__, COLOR_RESET); \
} while(0)

#endif