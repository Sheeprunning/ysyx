TOPNAME ?= ysyxSoCFull
NXDC_FILES = constr/top.nxdc
INC_PATH ?=/vsrc

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  --trace --Wall\
                 -O3 --x-assign fast --x-initial fast --noassert\
				 --timescale "1ns/1ns" --no-timing
#将警告视为非致命错误
#VERILATOR_CFLAGS += -Wno-fatal
#忽略#延迟时序的警告
VERILATOR_CFLAGS += -Wno-ASSIGNDLY
#设置include路径
VERILATOR_CFLAGS += -I$(MYSOC_HOME)/vsrc/perip/uart16550/rtl 
VERILATOR_CFLAGS += -I$(MYSOC_HOME)/vsrc/perip/spi/rtl
VERILATOR_CFLAGS += -I$(MYSOC_HOME)/vsrc/include
#刷新缓冲区
VERILATOR_CFLAGS += --autoflush
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: $(BIN)

$(BUILD_DIR):
		mkdir -p $@

# project source
VSRCS = $(shell find $(abspath ./vsrc) -maxdepth 1 -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/perip) -name "*.v")
VSRCS += $(shell find $(abspath ./vsrc/core_cpu) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.cpp")
CSRCS += $(shell find $(abspath ./csrc) -maxdepth 1 -name "*.c")
CSRCS += $(SRC_AUTO_BIND)
IMG ?=  ./default.bin
DIFF ?= $(NEMU_HOME)/build/riscv32-nemu-interpreter-so
ELF ?= ./default.elf

# constraint file
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)

#I add the choice to choose if run nvboard
ifeq ($(findstring r,$(filter-out --%,$(MAKEFLAGS))),r)
  RUN_NVBOARD = 1
else
  RUN_NVBOARD ?= 1
endif

#run nvboard
ifeq ($(RUN_NVBOARD), 1)
# rules for NVBoard
$(SRC_AUTO_BIND): $(NXDC_FILES) | $(BUILD_DIR)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $< $@
include $(NVBOARD_HOME)/scripts/nvboard.mk
sim: $(BIN)
	@echo "=== doing git_commit ...==="
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "=== finish git_commit! ==="
	@echo "Running simulation with NVBoard..."
	@ASAN_OPTIONS=new_delete_type_mismatch=0:detect_leaks=0 $(BIN) -i $(IMG) -f $(ELF) 

run: $(BIN)
	@echo "=== doing git_commit ...==="
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "=== finish git_commit! ==="
	@echo "Running simulation with NVBoard..."
	@ASAN_OPTIONS=new_delete_type_mismatch=0:detect_leaks=0 $(BIN) -i $(IMG) -d $(DIFF) -f $(ELF) -b
#don't run nvboard
else
$(SRC_AUTO_BIND): | $(BUILD_DIR)
	@echo "Skipping pin binding (BIND_PINS=0)"
	touch $@  
sim: $(BIN)
	@echo "=== doing git_commit ...==="
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "=== finish git_commit! ==="
	@echo "Running simulation (without NVBoard)..."
	@$(BIN) -i $(IMG) -d $(DIFF) -f $(ELF)

run: $(BIN)
	@echo "=== doing git_commit ...==="
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "=== finish git_commit! ==="
	@echo "Running simulation (without NVBoard)..."
	@$(BIN) -i $(IMG) -d $(DIFF) -f $(ELF) -b
endif

# Include all filelist.mk to merge file lists
FILELIST_MK = $(shell find -L ./csrc -name "filelist.mk")
include $(FILELIST_MK)

$(CSRCS):$(LIBCAPSTONE)

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
CXXFLAGS += -I$(abspath ./csrc/include)
LDFLAGS += -lreadline -lhistory -lncurses
CXXFLAGS += -fsanitize=address
LDFLAGS += -fsanitize=address
LDFLAGS += -lSDL2

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE) 
	rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
	--top-module $(TOPNAME) $^ \
	$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
  --Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))
	

perf:
	rm -rf $(YOSYS_HOME)/example/*.v
	cp -r  ./vsrc/core_cpu/* $(YOSYS_HOME)/example
	make -C $(YOSYS_HOME)  CLK_PORT_NAME=clock sta
	mv $(YOSYS_HOME)/result/ysyx_25080204-1500MHz ./vsrc/evaluation

all: default


clean:
	rm -rf $(BUILD_DIR)
	rm -rf *vcd

.PHONY: default all clean run
include ../Makefile
