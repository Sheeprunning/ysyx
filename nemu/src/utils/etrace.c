#include <stdio.h>
#include <string.h>
#include <etrace.h>

FILE *etrace_fp = NULL;
char etrace_name[128];

void init_etrace(const char *filename){
    strcpy(etrace_name,filename);
    etrace_fp =fopen(etrace_name,"w");
    if(!etrace_fp){
        printf("无法打开etrace文件\n");
        return ;
    }
    fprintf(etrace_fp, "%-10s %-10s\n","mcause","mepc");
    fclose(etrace_fp);
}

void add_etrace(int NO,int PC){
    etrace_fp =fopen(etrace_name,"a");
    fprintf(etrace_fp, "0x%08x 0x%08x \n", NO,PC);
    fclose(etrace_fp);
}

