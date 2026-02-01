#include <sitrace.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
// 全局变量
FILE *sitrace_fp = NULL;
char sitrace_filename[256] = "/home/sheeprunning/ysyxworkbench/nemu/build/cachesim.bin";
int n=0;
void init_sitrace(const char *filename) {
    if (!filename) return;
    
    // // 保存文件名
    // strncpy(sitrace_filename, filename, sizeof(sitrace_filename) - 1);
    // sitrace_filename[sizeof(sitrace_filename) - 1] = '\0';
    
    // 打开文件
    sitrace_fp = fopen(sitrace_filename, "wb");
    if (!sitrace_fp) {
        printf("无法打开sitrace文件: %s\n", sitrace_filename);
        sitrace_filename[0] = '\0';  // 清空
    }else  printf("成功打开sitrace文件: %s\n", sitrace_filename);
    fclose(sitrace_fp);
}

void sitrace_add(uint32_t pc) {
    
        sitrace_fp = fopen(sitrace_filename, "ab");
        
    
    if (pc) {
        fwrite(&pc, sizeof(pc), 1, sitrace_fp);
        // fflush(sitrace_fp);
    }
    fclose(sitrace_fp);
}