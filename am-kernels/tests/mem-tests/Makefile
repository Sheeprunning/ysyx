NAME = memtest

WORK_DIR  = $(shell pwd)
SRCS = $(shell find src/ -name "*.[cS]")
INCPATH = $(WORK_DIR)/include

CROSS_COMPILE := riscv64-linux-gnu-
LD 		  = $(CROSS_COMPILE)ld
CC 		  = $(CROSS_COMPILE)gcc
OBJDUMP   = $(CROSS_COMPILE)objdump
OBJCOPY   = $(CROSS_COMPILE)objcopy

CFLAGS = -I$(INCPATH) -march=rv64gc -mabi=lp64d -nostdlib -ffreestanding
LDFLAGS = LDFLAGS = -Ttext=0x30000000 -Tdata=0x30010000 -Tbss=0x30020000 -nostdlib -nostartfiles
all: $(NAME).bin

$(NAME).elf: $(SRCS)
	$(CC) $(CFLAGS) -o $@ $(SRCS)

$(NAME).bin: $(NAME).elf
	$(OBJDUMP) -d $(NAME).elf > $(NAME).txt
	@$(OBJCOPY) -O binary -j .text $(NAME).elf $(NAME).bin

sim: $(NAME).bin
	make -C $(NPC_HOME) IMG=$(NAME).bin sim

clean:
	rm -rf $(NAME).elf $(NAME).bin $(NAME).txt