#include <mem.h>
#include <common.h>
#include <sim.h>

uint8_t *pmem = NULL;

static const u_int32_t img[]={
    0x00408093, // addi x1, x1, 4 
    0x00400113, // addi x2, x0, 4 
    0x00408193, // add x3, x2, x1
    0x00100073  // ebreak 
};

uint8_t* guest_to_host(u_int32_t paddr) { return pmem + paddr - CONFIG_MBASE; }
int check_paddr(uint32_t paddr){return paddr>=CONFIG_MBASE && paddr < CONFIG_MBASE + CONFIG_MSIZE;}
 
inline u_int32_t host_read(void *addr, int len) {
  switch (len) {
    case 1: return *(uint8_t  *)addr;
    case 2: return *(uint16_t *)addr;
    case 4: return *(uint32_t *)addr;
    default: assert(0);
  }
}

inline void host_write(void *addr, int len, u_int32_t data) {
  switch (len) {
    case 1: *(uint8_t  *)addr = data; return;
    case 2: *(uint16_t *)addr = data; return;
    case 4: *(uint32_t *)addr = data; return;
    default: assert(0);
  }
}

u_int32_t pmem_read(uint32_t addr, int len) {
  if(!check_paddr(addr)){
    printf(ANSI_FMT("超出访存位置！addr:0x%08x len:%d",COLOR_RED)"\n",addr,len);
    sim_exit();
    assert(0);
  }
  u_int32_t ret = host_read(guest_to_host(addr), len);
  #ifdef CONFIG_MTRACE
  char log[128];
  sprintf(log,"R 0x%08x %d 0x%08x",addr,len,ret);
  log_add("mtrace.txt",log);
  #endif
  return ret;
}

void pmem_write(u_int32_t addr, int len, u_int32_t data) {
  if(!check_paddr(addr)){
    printf(ANSI_FMT("写入位置错误！addr:%0#x len:%d",COLOR_RED)"\n",addr,len);
    sim_exit();
    assert(0);
  }
  host_write(guest_to_host(addr), len, data);
  #ifdef CONFIG_MTRACE
  char log[128];
  sprintf(log,"W 0x%08x %d 0x%08x",addr,len,data);
  log_add("mtrace.txt",log);
  #endif
}

int init_mem() {
  pmem = new u_int8_t[CONFIG_MSIZE];
  assert(pmem);
  printf(ANSI_FMT("正在将%s文件放入存储器！",COLOR_BLUE)"\n",img_file);
  FILE *fp=fopen(img_file,"rb");
  if(!fp){
    printf(ANSI_FMT("无法打开img文件!!",COLOR_RED)"\n");
  }
  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  int ret = fread(guest_to_host(CONFIG_MBASE + CONFIG_PC_RESET_OFFSET), 1, size, fp);
  if(size==0){
    printf(ANSI_FMT("文件为空！使用默认数组作为指令！",COLOR_RED)"\n");
    memcpy(pmem,img,sizeof(img));
    size=16;
  }
    return size;
}