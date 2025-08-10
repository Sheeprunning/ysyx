#include <stdio.h>
#include "mtrace.h"

FILE *mtrace_fp = NULL;

void init_mtrace(const char *filename){
    mtrace_fp =fopen(filename,"w");
    if(!mtrace_fp){
        printf("无法打开mtrace文件\n");
        return ;
    }
    fprintf(mtrace_fp, "%3s %10s %s %10s \n","W/R","addr","size","data");
}

void close_matrace(){
    fclose(mtrace_fp);
}