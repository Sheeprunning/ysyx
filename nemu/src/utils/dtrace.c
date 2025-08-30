#include <stdio.h>
#include "dtrace.h"

FILE *dtrace_fp = NULL;

void init_dtrace(const char *filename){
    dtrace_fp =fopen(filename,"w");
    if(!dtrace_fp){
        printf("无法打开dtrace文件\n");
        return ;
    }
    fprintf(dtrace_fp, "%-3s %-10s %-4s %-10s \n","W/R","addr","size","data");
}

void close_dtrace(){
    fclose(dtrace_fp);
}