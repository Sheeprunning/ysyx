#include "log.h"

char* logname[]={"itrace.txt","ftrace.txt","mtrace.txt"};

void build_path(char *dest, size_t size, const char *filename) {
    snprintf(dest, size, "../build/%s", filename);
}

void init_log(){
    for(int i=0;i<3;i++){
        char fullpath[256];
        build_path(fullpath, sizeof(fullpath), logname[i]);
        
        FILE *fp = fopen(fullpath, "w");
        if(!fp)printf("%s\n",fullpath);
        assert(fp);
        fprintf(fp, "%s\n", logname[i]);
        fclose(fp);
    }
}


void log_add(const char *filename,char *context){
    char fullpath[256];
    build_path(fullpath, sizeof(fullpath), filename);
        
    FILE *fp=fopen(fullpath,"a");
    assert(fp);
    fprintf(fp,"%s",context);
    fclose(fp);
}