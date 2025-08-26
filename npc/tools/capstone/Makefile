REPO_PATH = repo
ifeq ($(wildcard repo/include/capstone/capstone.h),)
  $(shell git clone --depth=1 -b 5.0.3 git@github.com:capstone-engine/capstone.git $(REPO_PATH))
endif

CAPSTONE = $(REPO_PATH)/libcapstone.so.5
$(CAPSTONE):
	cd $(REPO_PATH) && CAPSTONE_ARCHS="x86|mips|riscv|loongarch" bash make.sh

clean:
	$(MAKE) -C $(REPO_PATH) clean

all: $(CAPSTONE)
.DEFAULT_GOAL = all

.PHONY: all clean