#include <iringbuf.h>
#include <string.h>
#include <stdio.h>

#define BUF_SIZE 20

static ringbuf iringbuf[BUF_SIZE]={};

static int head=0;

void init_iringbuf(){
    for(int i=0;i<BUF_SIZE;i++){
        memset(iringbuf[i].buf, 0, sizeof(iringbuf[i].buf));
    }
}

void iringbuf_add(char *buf){
    strncpy(iringbuf[head].buf, buf, sizeof(iringbuf[head].buf));
    head = (head + 1) % BUF_SIZE;
}

void iringbuf_show(){
    if(head!=0){
        printf("iringbuf:....\n");
        for(int i=0;i<BUF_SIZE;i++){
            if(i==(head-1)%BUF_SIZE)printf("->");
            printf("  %s\n",iringbuf[i].buf);
        }      
    }

}