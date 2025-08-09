#ifndef IRING_BUF
#define IRING_BUF


typedef struct
{
    char buf[128];
}ringbuf;


void iringbuf_init();

void iringbuf_add(char *buf);


#endif