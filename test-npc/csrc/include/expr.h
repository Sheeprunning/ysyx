#ifndef _EXPR_H_
#define _EXPR_H_

#include <stdlib.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <regex.h>
#include "init.h"
#include "sim.h"
#include <stdbool.h>
#include <stdint.h>

// 初始化正则表达式
void init_regex();

// 表达式求值函数
int expr(char *e, bool *success);

// 打印token（用于调试）
void print_token();


#define ARRLEN(arr) (sizeof(arr) / sizeof(arr[0]))
#endif