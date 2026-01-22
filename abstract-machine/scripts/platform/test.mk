AM_SRCS := riscv/test/start.S \
           riscv/test/trm.c \
           riscv/ysyxsoc/ioe.c \
           riscv/ysyxsoc/timer.c \
           riscv/ysyxsoc/input.c \
           riscv/ysyxsoc/cte.c \
           riscv/ysyxsoc/trap.S \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

TEXT = $(IMAGE)-text
DATA = $(IMAGE)-data

CFLAGS    += -fdata-sections -ffunction-sections
CFLAGS    += -I$(AM_HOME)/am/src/riscv/ysyxsoc/include 
LDSCRIPTS += $(AM_HOME)/scripts/test_linker.ld #改成mrom和sram的链接
LDFLAGS   += --defsym=_pmem_start=0x30000000 --defsym=_entry_offset=0x0
LDFLAGS   += --gc-sections -e _start #--gc-sections：清楚未使用的垃圾段 -e _start：指定程序入口

MAINARGS_MAX_LEN = 64
MAINARGS_PLACEHOLDER = the_insert-arg_rule_in_Makefile_will_insert_mainargs_here
CFLAGS += -DMAINARGS_MAX_LEN=$(MAINARGS_MAX_LEN) -DMAINARGS_PLACEHOLDER=$(MAINARGS_PLACEHOLDER)


insert-arg: image
	#@python $(AM_HOME)/tools/insert-arg.py $(IMAGE).bin $(MAINARGS_MAX_LEN) $(MAINARGS_PLACEHOLDER) "$(mainargs)"


image: image-dep
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin
	@$(OBJCOPY) -O binary --only-section=.text --only-section=.rodata* $(IMAGE).elf $(TEXT).bin
	@$(OBJCOPY) -O binary --only-section=.bss --only-section=.data* --only-section=.sdata* $(IMAGE).elf $(DATA).bin
	@echo + bin2coe "->" $(TEXT).coe
	@python $(AM_HOME)/tools/bin2coe.py $(TEXT).bin
	@echo + bin2coe "->" $(DATA).coe
	@python $(AM_HOME)/tools/bin2coe.py $(DATA).bin 

run: insert-arg
	$(MAKE) -C $(TEST_NPC_HOME) IMG=$(IMAGE).bin ELF=$(IMAGE).elf run

sim: insert-arg
	$(MAKE) -C $(TEST_NPC_HOME) IMG=$(IMAGE).bin ELF=$(IMAGE).elf sim

.PHONY: insert-arg
