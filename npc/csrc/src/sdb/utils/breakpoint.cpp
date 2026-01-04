#include <breakpoint.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

uint32_t bp;
int flag =1;

void add_bp(char* args){//暂时感觉只用设置一个bp就行
    flag=0;
    char *endptr; // 用于错误检查
    errno = 0;

    bp = strtol(args, &endptr, 16); // 明确指定 base=16
    if (errno != 0) {
        perror("strtol");
        return ;
    } else if (endptr == args) {
        printf("No digits were found in \"%s\"\n", args);
        return ;
    } else {
        printf("add bp: 0x%08x\n", bp);
        return ;
    }

}
int compare_bp(uint32_t pc){
    if(flag==0 && pc==bp){
        flag=1;
        printf("pc==0x%08x\n",pc);
        return 1;
    }
    else return 0;
    
}