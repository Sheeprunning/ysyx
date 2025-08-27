#include "log.h"

char* logname[]={"itrace.txt","ftrace.txt","mtrace.txt"};
static char temp[256];
char* build_path(const char *path){
    int i=sprintf(temp,"../build/%s",path);
    assert(i);
    return temp;
}

void init_log(){
    for(int i=0;i<3;i++){
        FILE *fp=fopen(build_path(logname[i]),"w");
        assert(fp);
        fprintf(fp,"%s\n",logname[i]);
        fclose(fp);
    }
}


void log_add(const char *filename,char *context){
    FILE *fp=fopen(build_path(filename) ,"a");
    assert(fp);
    fprintf(fp,"%s",context);
    fclose(fp);
}