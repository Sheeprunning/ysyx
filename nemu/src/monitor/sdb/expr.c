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
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256, TK_EQ,

  /* TODO: Add more token types */
  TK_PLUS, TK_SUB, TK_MUL, TK_DIV, TK_L_PRS, TK_R_PRS, TK_NUMS,\
  TK_SIGN_P ,TK_SIGN_N, TK_0X, TK_REG, TK_NEQ, TK_L_AND, TK_B_AND,\
  TK_L_OR, TK_B_OR, TK_NOT, TK_XOR
};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\n+", TK_NOTYPE},   // 换行符
  {"\"+", TK_NOTYPE},
  {"\\(", TK_L_PRS},
  {"\\)", TK_R_PRS},
  {"0[xX][0-9a-fA-F]+", TK_0X},
  {"\\$[0-9a-zA-Z]+", TK_REG},
  {"==", TK_EQ},        // equal
  {"!=", TK_NEQ},
  {"\\&\\&", TK_L_AND},
  {"\\|\\|", TK_L_OR},
  {"!", TK_NOT},
  {"\\&", TK_B_AND},
  {"\\|", TK_B_OR},
  {"\\^", TK_XOR},
  {"\\*", TK_MUL},
  {"/", TK_DIV},
  {"\\+", TK_PLUS},         // plus
  {"-", TK_SUB}, 
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
  bool success=true;

  nr_token = 0;
  memset(tokens, 0, sizeof(tokens));

  while (e[position] != '\0') {
    if(nr_token==32)return false;
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
          case TK_MUL: case TK_DIV: case TK_L_PRS: case TK_R_PRS: case TK_0X:\
          case TK_NEQ: case TK_L_AND: case TK_B_AND: case TK_L_OR: case TK_B_OR:\
          case TK_NOT: case TK_XOR:
            tokens[nr_token].type=rules[i].token_type;   
            strncpy(tokens[nr_token].str, substr_start, substr_len);
            tokens[nr_token].str[substr_len]='\0';
            nr_token++;
            break;

          case TK_REG:
            char reg_name[32];
            strncpy(reg_name, substr_start+1, substr_len-1);
            reg_name[substr_len-1] = '\0';
            int data = isa_reg_str2val(reg_name, &success);
            if(!success){
              printf("Can't find the '%s' register!",reg_name);
              return false;
            }
            tokens[nr_token].type=TK_NUMS; 
            sprintf(tokens[nr_token].str,"%d",data);
            nr_token++;
            break;

          case TK_SUB: 
            if(nr_token==0){
              tokens[nr_token].type=TK_SIGN_N;//认定该减号为负号
            }else if(tokens[nr_token-1].type!=TK_NUMS&&tokens[nr_token-1].type!=TK_0X){//前一个不是数字
              if(tokens[nr_token].type==TK_SIGN_N ||tokens[nr_token].type==TK_SIGN_P){//之前已经认定为是符号
                printf("The expression is wrong!");
                return false;
              }else tokens[nr_token].type=TK_SIGN_N;//认定该减号为负号
            }else{//普通减号
              tokens[nr_token].type=rules[i].token_type;   
              strncpy(tokens[nr_token].str, substr_start, substr_len);
              tokens[nr_token].str[substr_len]='\0';
              nr_token++;
            }break;
            
          case TK_PLUS:
            if(nr_token==0){
              tokens[nr_token].type=TK_SIGN_P;//认定该加号为正号
            }else if(tokens[nr_token-1].type!=TK_NUMS&&tokens[nr_token-1].type!=TK_0X){//前一个不是数字
              if(tokens[nr_token].type==TK_SIGN_N ||tokens[nr_token].type==TK_SIGN_P){//之前已经认定为是符号
                printf("The expression is wrong!");
                return false;
              }else tokens[nr_token].type=TK_SIGN_P;//认定该减号为正号
            }else{//普通加号
              tokens[nr_token].type=rules[i].token_type;   
              strncpy(tokens[nr_token].str, substr_start, substr_len);
              tokens[nr_token].str[substr_len]='\0';
              nr_token++;
            }break;

          case TK_NUMS:
          if(tokens[nr_token].type==TK_SIGN_N){//判定为负数
            tokens[nr_token].type=rules[i].token_type; 
            tokens[nr_token].str[0] = '-';
            strncpy(tokens[nr_token].str + 1, substr_start, substr_len);
            tokens[nr_token].str[1 + substr_len] = '\0'; 
          }else{//正数或者普通数
            tokens[nr_token].type=rules[i].token_type;   
            strncpy(tokens[nr_token].str, substr_start, substr_len);
            tokens[nr_token].str[substr_len]='\0';
          }
            nr_token++;
            break;
          case TK_NOTYPE:break;
          default: printf("Unknown token type at position %d : %c\n", position,*(position+e));TODO();break;
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
  // 检查首尾是否是 '(' 和 ')'
    if (strcmp(tokens[p].str, "(") != 0 || strcmp(tokens[q].str, ")") != 0) {
        return false;
    }
    // 检查中间部分是否括号匹配
    int balance = 1;  // 因为 tokens[p] 已经是 '('，所以初始 balance=1
    for (int i = p + 1; i < q; i++) {
        if (strcmp(tokens[i].str, "(") == 0) {
            balance++;
        } else if (strcmp(tokens[i].str, ")") == 0) {
            balance--;
            if (balance <= 0) {
                return false;  // 中间出现不匹配的情况
            }
        }
    }
    return (balance == 1);  // 最终 balance=1，因为 tokens[q] 是 ')'
}

bool check_parentheses_match(int p, int q) {
    int balance = 0;  // 用于跟踪括号的平衡情况
    for (int i = p; i <= q; i++) {
        if (strcmp(tokens[i].str, "(") == 0) {
            balance++;  // 遇到 '('，平衡+1
        } else if (strcmp(tokens[i].str, ")") == 0) {
            balance--;  // 遇到 ')'，平衡-1
            if (balance < 0) {
                return false;  // 出现 ")" 比 "(" 多的情况，不匹配
            }
        }
    }
    return (balance == 0);  // 最终平衡=0，说明匹配
}

int find_main_operator(int p, int q) {
    int paren_level = 0;
    int main_op = -1; 
    for (int i = p; i <= q; i++) {
        if (strcmp(tokens[i].str, "(") == 0) paren_level++;
        else if (strcmp(tokens[i].str, ")") == 0) paren_level--;
        else if (paren_level == 0) {
            // 根据运算符优先级更新 main_op
            if (strcmp(tokens[i].str, "+") == 0 || strcmp(tokens[i].str, "-") == 0) {
                main_op = i; // 加减优先级最低
            } else if ((strcmp(tokens[i].str, "*") == 0 || strcmp(tokens[i].str, "/") == 0) && 
                      (main_op == -1 || 
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
    printf("The expression is false! or too long\n");
    return NULL;
  }
  else if (p == q) {
    /* Single token.
     * For now this token should be a number.
     * Return the value of the number.
     */
    char *r = malloc(32 * sizeof(char));
        strcpy(r, tokens[p].str);
        return r;
  }
  else if (check_parentheses(p, q) == true) {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    if (!check_parentheses_match(p + 1, q - 1)) {
        printf("Mismatched parentheses inside!\n");
        return NULL;
    }
    return eval(p + 1, q - 1);
  }
  else {
    int op_pos = find_main_operator(p, q);
    if (op_pos == -1) {
      printf("No operator found!\n");
      return NULL;
     }
    char* val1_str,* val2_str;
    int val1,val2;
    char op = *(tokens[op_pos].str);
    val1_str=eval(p, op_pos - 1);
    val2_str=eval(op_pos + 1, q);
    if(!val1_str || !val2_str){
      return NULL;
    }
    if(val1_str[0]=='0'){
      sscanf(val1_str,"%x",&val1);
    }else sscanf(val1_str,"%d",&val1);
    if(val2_str[0]=='0'){
      sscanf(val2_str,"%x",&val2);
    }else sscanf(val2_str,"%d",&val2);
    int reslut;
    char *r=malloc(32*sizeof(char));

    switch (op) {
      case '+': reslut = val1 + val2;  break;
      case '-': reslut = val1 - val2;  break;
      case '*': reslut = val1 * val2;  break;
      case '/': reslut = val1 / val2;  break;
      default: assert(0);  break;
    }
    sprintf(r,"%d",reslut);
    return r;
  }
}

void print_token(){
  for(int i=0;i<nr_token;i++){
    printf("%s",tokens[i].str);
  }
}

word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }
  //print_token();//输出token
  /* TODO: Insert codes to evaluate the expression. */
  char * r = eval(0,nr_token-1);
  //printf("计算结果：%s\n",r);
  if(!r){
    printf("Wrong caculation!Please try again!\n");
    *success= false;
  }
  int result;
  if(r[1]=='x'&&sscanf(r,"%x",&result)==1){return result;} 
  if(sscanf(r,"%d",&result)!=1){printf("Modify the str to int fail!");assert(0);} 
  free(r);
  return result;
}
