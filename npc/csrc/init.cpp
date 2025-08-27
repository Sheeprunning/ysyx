#include "init.h"

using namespace std;


uint8_t *pmem = NULL;
char* img_file =NULL;
char* ftrace_file=NULL;
static char *diff_so_file = NULL;
static int difftest_port = 1234;

static const u_int32_t img[]={
    0x00408093, // addi x1, x1, 4 
    0x00400113, // addi x2, x0, 4 
    0x00408193, // add x3, x2, x1
    0x00100073  // ebreak 
};

int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"image"    , required_argument, NULL, 'i'},
    {"diff"     , required_argument, NULL, 'd'},
    {"batch"    , no_argument      , NULL, 'b'},
    {"ftrace"   , required_argument, NULL, 'f'},
    {0          , 0                , NULL,  0 },
  };
  int o;
  while ( (o = getopt_long(argc, argv, "i:d:b", table, NULL)) != -1) {
    switch (o) {
      case 'i': img_file = optarg; break;
      case 'd': diff_so_file = optarg; break;
      case 'b': sdb_set_batch_mode(); break;
      case 'f': ftrace_file = optarg; break;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-i,--image=IMAGE_BIN    initial  with file.bin\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-f,--ftrace=FTRACE_ELF  run ftrace with file.elf\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}

uint8_t* guest_to_host(u_int32_t paddr) { return pmem + paddr - CONFIG_MBASE; }
int check_paddr(u_int32_t paddr){return paddr>=CONFIG_MBASE&& paddr < CONFIG_MBASE + CONFIG_MSIZE;}

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
  if(!check_paddr(addr)){
    printf("addr:%0#x len:%d\n",addr,len);
    sim_exit();
    assert(0);
  }
  
  u_int32_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

void pmem_write(u_int32_t addr, int len, u_int32_t data) {
  if(!check_paddr(addr)){
    printf("addr:%0#x len:%d\n",addr,len);
    sim_exit();
    assert(0);
  }
  host_write(guest_to_host(addr), len, data);
}

int init_mem() {
  pmem = new u_int8_t[CONFIG_MSIZE];
  assert(pmem);
  printf("正在将%s文件放入存储器！\n",img_file);
  FILE *fp=fopen(img_file,"rb");
  if(!fp){
    printf("无法打开img文件!!\n");
  }
  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  int ret = fread(guest_to_host(CONFIG_MBASE), 1, size, fp);
  if(size==0){
    memcpy(pmem,img,sizeof(img));
    size=16;
  }
  // cout << "-----PMEM Initialization Check:-----" << endl;
  //   for (int i = 0; i < size/4; i++) { 
  //       u_int32_t inst;
  //       memcpy(&inst, pmem + i * 4, 4);  // 按 4 字节读取
  //       if(inst==0)break;
  //       cout << "pmem["<< setw(8) << setfill('0') <<hex  << i * 4+CONFIG_MBASE << "]: 0x" << 
  //       setw(8) << setfill('0') << inst << dec << endl;
  //   }
  //   cout << "----------" << endl;
    return size;
}

void init_main(int argc, char *argv[]){
    parse_args(argc, argv);
    long img_size = init_mem();
    printf("存储器初始化完成！\n");
    init_sdb() ;
    printf("调试器初始化完成！\n");
    sim_init();
    printf("仿真初始化完成！\n");
    init_difftest(diff_so_file, img_size, difftest_port);
    printf("差分测试初始化完成！\n");
    init_disasm();
    printf("反汇编工具初始化完成！\n");
    init_log();
    if(ftrace_file)process_elf_file(ftrace_file);
    printf("日志工具初始化完成！\n");
}