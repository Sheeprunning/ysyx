VERILATOR = verilator
VERILATOR_FLAGS = --cc --trace --exe --build -j 0 -Wall
TOP_MODULE = top
VSRC_DIR = vsrc
CSRC_DIR = csrc
OBJ_DIR = obj_dir
SIM_EXE = $(OBJ_DIR)/V$(TOP_MODULE)

all:
	@echo "Write this Makefile by your self."

sim: $(SIM_EXE)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."
	@echo "Running simulation..."
	@./$(SIM_EXE)


$(SIM_EXE): $(VSRC_DIR)/$(TOP_MODULE).v $(CSRC_DIR)/$(TOP_MODULE).cpp
	@echo "Compiling with Verilator..."
	@$(VERILATOR) $(VERILATOR_FLAGS) \
		$(VSRC_DIR)/$(TOP_MODULE).v \
		$(CSRC_DIR)/$(TOP_MODULE).cpp

.PHONY: clean
clean:
	@echo "Cleaning up..."
	@rm -rf $(OBJ_DIR) *.vcd

include ../Makefile
