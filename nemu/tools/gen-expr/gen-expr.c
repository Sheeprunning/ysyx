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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

#define MAX_INT 10//设置为10减少乘法溢出等问题
// this should be enough
static char buf[65536] = {};
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  unsigned result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";
static int buff_end=0;
static int token_len=0;
static int choose_with_max(int max) {
    return rand() % max;
}
static int choose_without_max() {
    return rand() % MAX_INT; 
}

static void gen(char s){
  token_len++;
  buf[buff_end]=s;
  buff_end++;
  buf[buff_end]='\0';
}

static void gen_num(){
  token_len++;
  int num = choose_without_max();
  if (num < 0) {
      num = -num;
    }
    char num_str[32];
    sprintf(num_str, "%d", num);
    for (int i = 0; num_str[i] != '\0'; i++) {
        gen(num_str[i]);
    }
}

static void gen_rand_op(){
  switch (choose_with_max(3)){//先忽略除法。
    case 0: gen('+');break;
    case 1: gen('-');break;
    case 2: gen('*');break;
    case 3: gen('/');break;
  }
}

static int gen_rand_expr() {
  switch (choose_with_max(3)) {
    case 0: gen_num(); break;
    case 1: gen('('); gen_rand_expr(); gen(')'); break;
    default: gen_rand_expr(); gen_rand_op(); gen_rand_expr(); break;
  }
  if (buff_end == 65534 ||token_len>=32) {//表达式过长
        return -1;
  }
  return 0;
}

int main(int argc, char *argv[]) {
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
 while (i<loop){
    buff_end=0;
    token_len=0;
    buf[0] = '\0';
    if(gen_rand_expr()!=0)continue;

    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc /tmp/.code.c -o /tmp/.expr");
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result;
    if (fscanf(fp, "%d", &result) != 1) {
      //printf("Error: Expression '%s' is invalid!\n", buf);
      pclose(fp);
      continue;
    }
    pclose(fp);

    printf("%u %s\n", result, buf);
    i++;
  }
  return 0;
}
