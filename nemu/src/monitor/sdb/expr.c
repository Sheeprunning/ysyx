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

#include <isa.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256, TK_EQ,

  /* TODO: Add more token types */
  TK_PLUS, TK_SUB, TK_MUL, TK_DIV, TK_L_PRS, TK_R_PRS, TK_NUMS
};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\(", TK_L_PRS},
  {"\\)", TK_R_PRS},
  {"\\*", TK_MUL},
  {"/", TK_DIV},
  {"\\+", TK_PLUS},         // plus
  {"-", TK_SUB}, 
  {"==", TK_EQ},        // equal
  {"[0-9]+", TK_NUMS}
};

#define NR_REGEX ARRLEN(rules)//rules数组长度

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);//编译正则表达式,将rule[i].regex转为相应格式存在re
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[32] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
      /*匹配正则表达式
      int regexec (regex_t *compiled, char *string, size_t nmatch, regmatch_t match_ptr [], int eflags)*/
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;//rm_so 存放匹配文本串在目标串中的开始位置，rm_eo 存放结束位置

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */
        switch (rules[i].token_type) {
          case TK_PLUS:case TK_SUB: case TK_MUL: case TK_DIV: case TK_L_PRS: case TK_R_PRS:
            tokens[nr_token].type=rules[i].token_type;   
            strncpy(tokens[nr_token].str, substr_start, substr_len);
            tokens[nr_token].str[substr_len]='\0';
            nr_token++;
            break;
          case TK_NUMS:
            tokens[nr_token].type=rules[i].token_type;   
            strncpy(tokens[nr_token].str, substr_start, substr_len);
            tokens[nr_token].str[substr_len]='\0';
            nr_token++;
            break;
          case TK_NOTYPE:break;
          default: printf("Unknown token type at position %d\n", position);TODO();break;
        }

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

bool check_parentheses(int p, int q) {
  return (strcmp(tokens[p].str , "(") && strcmp( tokens[q].str , ")" )); 
}

int find_main_operator(int p, int q) {//AI辅助生成
    int paren_level = 0;
    int main_op = p; // 默认第一个运算符（实际需遍历找优先级最低的）
    for (int i = p; i <= q; i++) {
        if (strcmp(tokens[i].str, "(") == 0) paren_level++;
        else if (strcmp(tokens[i].str, ")") == 0) paren_level--;
        else if (paren_level == 0) {
            // 根据运算符优先级更新 main_op
            if (strcmp(tokens[i].str, "+") == 0 || strcmp(tokens[i].str, "-") == 0) {
                main_op = i; // 加减优先级最低
            } else if ((strcmp(tokens[i].str, "*") == 0 || strcmp(tokens[i].str, "/") == 0) && 
                      (main_op == p || 
                       strcmp(tokens[main_op].str, "+") == 0 || 
                       strcmp(tokens[main_op].str, "-") == 0)) {
                main_op = i; // 乘除优先级高于加减
            }
        }
    }
    return main_op;
}

char* eval(int p, int q) {
  if (p > q) {
    printf("The expression is false!");
    return NULL;
  }
  else if (p == q) {
    /* Single token.
     * For now this token should be a number.
     * Return the value of the number.
     */
    return tokens[p].str;
  }
  else if (check_parentheses(p, q) == true) {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    return eval(p + 1, q - 1);
  }
  else {
    char op = *(tokens[find_main_operator(p,q)].str);
    int val1,val2;
    sscanf(eval(p, op - 1),"%d",&val1);
    sscanf(eval(op + 1, q),"%d",&val1);
    int reslut;
    char *r=malloc(32*sizeof(char));

    switch (op) {
      case '+': reslut = val1 + val2;
      case '-': reslut = val1 - val2;
      case '*': reslut = val1 * val2;
      case '/': reslut = val1 / val2;
      default: assert(0);
    }
    sprintf(r,"%d",reslut);
    return r;
  }
}
word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */
  char * r = eval(0,nr_token-1);
  printf("%s\n",r);
  for(int i=0;i<nr_token;i++){
    printf("%s",tokens[i].str);
  }
  free(r);
  return 0;
}
