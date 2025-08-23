/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/cpu.h>
#include <difftest-def.h>
#include <memory/paddr.h>

__EXPORT void difftest_memcpy(paddr_t addr, void *buf, size_t n, bool direction) {
  if (direction == DIFFTEST_TO_REF) {
    // 逐字节复制，而不是直接访问指针
    uint8_t *src = (uint8_t *)buf;
    for (size_t i = 0; i < n; i++) {
      uint8_t data = src[i];  // 先在本地读取数据
      paddr_write(addr + i, 1, data);  // 然后写入到 NEMU 的内存
    }
  }
}

__EXPORT void difftest_regcpy(void *dut, bool direction) {
  CPU_state *Dut=(CPU_state *)dut;
  if(direction==DIFFTEST_TO_REF){
    
    cpu.pc=Dut->pc;
    for(int i=0;i<MUXDEF(CONFIG_RVE, 16, 32);i++){
      cpu.gpr[i]=Dut->gpr[i];
    }
  }else if(direction==DIFFTEST_TO_DUT){
    Dut->pc=cpu.pc;
    for(int i=0;i<MUXDEF(CONFIG_RVE, 16, 32);i++){
      Dut->gpr[i]=cpu.gpr[i];
    }
  }else assert(0);
}
__EXPORT void difftest_exec(uint64_t n) {
  cpu_exec(n);
}

__EXPORT void difftest_raise_intr(word_t NO) {
  assert(0);
}

__EXPORT void difftest_init(int port) {
  void init_mem();
  init_mem();
  /* Perform ISA dependent initialization. */
  init_isa();
}
