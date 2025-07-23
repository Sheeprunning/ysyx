/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <common.h>
#include "monitor/sdb/sdb.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void init_monitor(int, char *[]);
void am_init_monitor();
void engine_start();
int is_exit_status_bad();

int test(){
  FILE *file=fopen("tools/gen-expr/input","r");
  if (file == NULL) {
        perror("Failed to open file");
        return -1;
    }
 
    unsigned int num;
    char c='a';
    char *str=&c;  
    bool flag = true;
    bool *success = &flag;
  
    while (fscanf(file, "%u %s\n", &num, str) == 2) {
      printf("%s = %u 计算结果为", str,num);  // 输出第二个字段（字符串）
      //expr("1+1",success);
    }
 
    fclose(file);
    return *success;
}


int main(int argc, char *argv[]) {test();
  /* Initialize the monitor. */
#ifdef CONFIG_TARGET_AM
  am_init_monitor();
#else
  init_monitor(argc, argv);
#endif

  /* Start engine. */
  engine_start();

  return is_exit_status_bad();
}
