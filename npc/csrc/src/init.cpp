#include <init.h>
#include <common.h>
#include <getopt.h>
#include <sdb.h>
#include <log.h>
#include <disasm.h>
#include <ftrace.h>
#include <mem.h>
#include <dut.h>
#include <device.h>

using namespace std;

char* img_file =NULL;
char* ftrace_file=NULL;
static char *diff_so_file = NULL;
static int difftest_port = 1234;

int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"image"    , required_argument, NULL, 'i'},
    {"diff"     , required_argument, NULL, 'd'},
    {"batch"    , no_argument      , NULL, 'b'},
    {"ftrace"   , required_argument, NULL, 'f'},
    {0          , 0                , NULL,  0 },
  };
  int o;
  while ( (o = getopt_long(argc, argv, "bi:d:f:", table, NULL)) != -1) {
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

void init_main(int argc, char *argv[]) {
    parse_args(argc, argv);
    
    long img_size = init_mem();
    PRINTF_COLOR(COLOR_BLUE, "存储器初始化中...");  
    printf(ANSI_FMT("✓ 成功\n",COLOR_GREEN));
    
    PRINTF_COLOR(COLOR_BLUE, "仿真环境初始化中...");
    sim_init();
    printf(ANSI_FMT("✓ 成功\n",COLOR_GREEN));
    
    PRINTF_COLOR(COLOR_BLUE, "调试器初始化中...");
    init_sdb();
    printf(ANSI_FMT("✓ 成功\n",COLOR_GREEN));
    
#ifdef CONFIG_DIFFTEST
    PRINTF_COLOR(COLOR_GREEN, "✓ 差分测试已启用\n");
    init_difftest(diff_so_file, img_size, difftest_port);
    init_devices();
    PRINTF_COLOR(COLOR_BLUE, "差分测试文件初始化中...");
    printf(ANSI_FMT("✓ 成功\n",COLOR_GREEN));
#else
    PRINTF_COLOR(COLOR_YELLOW, "⚠ 差分测试已禁用\n");
#endif

    PRINTF_COLOR(COLOR_BLUE, "反汇编工具初始化中...");
    init_disasm();
    printf(ANSI_FMT("✓ 成功\n",COLOR_GREEN));
    
    PRINTF_COLOR(COLOR_BLUE, "日志系统初始化中...");
    init_log();
    printf(ANSI_FMT("✓ 成功\n",COLOR_GREEN));
    
#ifdef CONFIG_FTRACE
    if (ftrace_file) {
        PRINTF_COLOR(COLOR_BLUE, "函数跟踪初始化中...");
        process_elf_file(ftrace_file);
        printf(ANSI_FMT("✓ 成功\n",COLOR_GREEN));
    } else {
        PRINTF_COLOR(COLOR_YELLOW, "⚠ 已开启ftrace但未指定elf文件\n");
    }
#endif

    
    PRINTF_COLOR(COLOR_GREEN, "所有初始化完成！\n");
}