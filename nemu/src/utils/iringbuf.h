#ifndef IRING_BUF
#define IRING_BUF


typedef struct
{
    char buf[128];
}ringbuf;


void init_iringbuf();

void iringbuf_add(char *buf);

void iringbuf_show();


#endif