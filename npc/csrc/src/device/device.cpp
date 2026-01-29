#include <device.h>
#include <vector>
#include <array>
#include <sim.h>
#include <dut.h>

using namespace std;

vector<array<uint32_t,2>>devices;

void init_devices(){
  devices.push_back({0x02000000, 0x0200ffff});//CLINT
  PRINTF_COLOR(COLOR_CYAN, "add CLINT range [0x02000000, 0x0200ffff]\n");
  devices.push_back({0x10000000, 0x10000fff});//uart
  PRINTF_COLOR(COLOR_CYAN, "add uart range [0x10000000, 0x10000fff]\n");
  devices.push_back({0x10002000, 0x1000200f});//gpio
  PRINTF_COLOR(COLOR_CYAN, "add gpio range [0x10002000, 0x1000200f]\n");
  devices.push_back({0x10011000, 0x10011007});//ps2
  PRINTF_COLOR(COLOR_CYAN, "add ps2 range [0x10011000, 0x10011007]\n");
}

void check_load_range(uint32_t instr,uint32_t raddr) {
    if ((instr & 0x7F) != 0x03) return ;//不是load指令
    uint32_t addr= raddr;
    for(uint32_t i =0;i<devices.size();i++){
      if(addr>=devices[i][0]&&addr<=devices[i][1]){
        difftest_skip_ref();
        return ;
      }
    }
}