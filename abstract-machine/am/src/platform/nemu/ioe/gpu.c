#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {
  // int i;
  // int w = 32*9;  // TODO: get the correct width
  // int h = 32*13;  // TODO: get the correct height
  // uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  // for (i = 0; i < w * h; i ++) fb[i] = i;
  // outl(SYNC_ADDR, 1);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  uint32_t config_data=inl(VGACTL_ADDR);
  int width=config_data>>16;
  int height=config_data&0xFFFF;
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = height, .height = width,
    .vmemsz = width*height
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  uint32_t screen_w = inl(VGACTL_ADDR) >> 16;
  uint32_t screen_h = inl(VGACTL_ADDR) &0xFFFF;
  uint32_t *pixels=(uint32_t*)ctl->pixels;
  int x=ctl->x;
  int y=ctl->y;
  int h=ctl->h;
  int w=ctl->w;
  if (x < 0 || y < 0 || x + w > screen_w || y + h > screen_h) {
    return;
}
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  for (int i = 0; i < h ; i ++){
    for(int j= 0; j< w ; j++){
      fb[(y+i)*(screen_w)+(x+j)]=pixels[i*w+j];
    }
  }
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  } 
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}

