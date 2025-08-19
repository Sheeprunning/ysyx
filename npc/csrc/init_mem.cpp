#include "./init_mem.h"

using namespace std;


uint8_t *pmem = NULL;
u_int32_t pc=0;
char* img_file =NULL;

static const u_int32_t img[]={
    0x00408093, // addi x1, x1, 4 
    0x00400113, // addi x2, x0, 4 
    0x00408193, // add x3, x2, x1
    0x00100073  // ebreak 
};

int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"image"      , required_argument, NULL, 'i'},
    {0            , 0                , NULL,  0 },
  };
  int o;
  while ( (o = getopt_long(argc, argv, "-i:", table, NULL)) != -1) {
    switch (o) {
      case 'i': img_file = optarg; return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-i,--image=IMAGE_BIN    initial  with file.bin\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}

uint8_t* guest_to_host(u_int32_t paddr) { return pmem + paddr - CONFIG_MBASE; }

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

u_int32_t pmem_read(u_int32_t addr, int len) {
  u_int32_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

void pmem_write(u_int32_t addr, int len, u_int32_t data) {
  host_write(guest_to_host(addr), len, data);
}

void init_mem() {
  pmem = new u_int8_t[CONFIG_MSIZE];
  assert(pmem);
  FILE *fp=fopen(img_file,"rb");
  if(!fp){
    cout<<"无法打开img文件"<<endl;
  }
  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  int ret = fread(guest_to_host(CONFIG_MBASE), 1, size, fp);
  if(size==0){
    memcpy(pmem,img,sizeof(img));
    size=16;
  }
  cout << "-----PMEM Initialization Check:-----" << endl;
    for (int i = 0; i < size/4; i++) { 
        u_int32_t inst;
        memcpy(&inst, pmem + i * 4, 4);  // 按 4 字节读取
        if(inst==0)break;
        cout << "pmem["<< setw(8) << setfill('0') <<hex  << i * 4+CONFIG_MBASE << "]: 0x" << 
        setw(8) << setfill('0') << inst << dec << endl;
    }
    cout << "----------" << endl;
}