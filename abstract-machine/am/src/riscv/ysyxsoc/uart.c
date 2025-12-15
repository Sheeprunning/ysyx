#include <am.h>
#include <ysyxsoc.h>
#include <stdio.h>

void __am_uart_rx(AM_UART_RX_T *rx){
    //printf("lsr : %x",inb(UART_LSR) & 0x1);
    if((inb(UART_LSR) & 0x1) == 0)
        rx->data=0xff;
    else
        rx->data=inb(UART_RB);
}