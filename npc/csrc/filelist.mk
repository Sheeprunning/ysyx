LIBCAPSTONE = tools/capstone/repo/libcapstone.so.5
CXXFLAGS += -I $(NPC_HOME)/tools/capstone/repo/include
tools/capstone/disasm.c: $(LIBCAPSTONE)
$(LIBCAPSTONE):
	$(MAKE) -C tools/capstone
