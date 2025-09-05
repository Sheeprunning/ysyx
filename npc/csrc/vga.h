#ifndef _VGA_H_
#define _VGA_H_

#include <SDL2/SDL.h>
#include "time.h"
#include "npc.h"


extern void *vmem;

void init_vga();
void vga_update_screen();
#endif