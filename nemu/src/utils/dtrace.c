#include <stdio.h>
#include <string.h>
#include <dtrace.h>

FILE *dtrace_fp = NULL;
char ftrace_name[128];

void init_dtrace(const char *filename){
    strcpy(ftrace_name,filename);
    dtrace_fp =fopen(ftrace_name,"w");
    if(!dtrace_fp){
        printf("无法打开dtrace文件\n");
        return ;
    }
    fprintf(dtrace_fp, "%-3s %-10s %-10s %-10s \n","W/R","addr","device_name","data");
    fclose(dtrace_fp);
}

void add_dtrace(char type,int addr,const char *device_name,int data){
    dtrace_fp =fopen(ftrace_name,"a");
    fprintf(dtrace_fp, "%3c 0x%08x %-10s 0x%08x \n", type, addr, device_name, data);
    fclose(dtrace_fp);
}

