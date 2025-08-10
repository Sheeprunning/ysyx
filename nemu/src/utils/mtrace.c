#include <stdio.h>
#include "mtrace.h"

FILE *mtrace_fp = NULL;

void init_mtrace(const char *filename){
    FILE *mtrace_fp =fopen(filename,"w");
    if(!mtrace_fp){
        printf("无法打开mtrace文件\n");
        return;
    }
}

void close_matrace(){
    fclose(mtrace_fp);
}