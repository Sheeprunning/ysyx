#ifndef DTRACE_H
#define DTRACE_H



void init_dtrace(const char *filename);
#define DTRACE_LOG(type, addr, size, data) \
    extern FILE *dtrace_fp;\
    fprintf(dtrace_fp, "%3c 0x%08x %-4d 0x%08x \n", \
            (type), (addr), (size), (data));\
    fflush(dtrace_fp);
void add_dtrace(char type,int addr,const char *device_name,int data);

#endif