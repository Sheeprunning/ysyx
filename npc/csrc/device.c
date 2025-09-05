#include "device.h"

enum {
    NO_DEVICE=0,
    FB=1
};

void device_update() {
  static uint64_t last = 0;
  uint64_t now = get_time();
  if (now - last < 1000000 / 60) {
    return;
  }
  last = now;

  vga_update_screen();
}

void init_device(){
    init_vga();
}

int device_main(u_int32_t addr,  int len , u_int32_t data,int is_write){
    if(is_write){
        if(addr>=FB_ADDR&&addr<FB_ADDR+300*400*4&&len==4){
        u_int32_t *fb=(u_int32_t*)vmem;
        u_int32_t index=(addr-FB_ADDR)/4;
        fb[index]=data;
        return 1;
      }return 0;
    }else{
      return 0;
    }
    
}