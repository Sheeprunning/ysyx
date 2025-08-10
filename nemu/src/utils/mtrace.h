#ifndef MTRACE_H
#define MTRACE_H



void init_mtrace(const char *filename);
#define MTRACE_LOG(type, addr, size, data) \
    extern FILE *mtrace_fp;\
    fprintf(mtrace_fp, "%c 0x%08x %d 0x%08x \n", \
            (type), (addr), (size), (data));\
    fflush(mtrace_fp);


#endif