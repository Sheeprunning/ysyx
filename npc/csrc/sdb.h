#ifndef _SDB_H_
#define _SDB_H_

#include <stdio.h>
#include <stdlib.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <string.h>
#include "sim.h"



/* 核心函数 */
void sdb_set_batch_mode(void);
void sdb_mainloop(void);


/* 数组长度计算宏 */
#define ARRLEN(arr) (sizeof(arr) / sizeof(arr[0]))




#endif