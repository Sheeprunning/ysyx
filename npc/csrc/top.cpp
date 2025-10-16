#include "sim.h"



int main(int argc, char *argv[]) {
    Verilated::commandArgs(argc, argv);
    sim(argc,argv);
    return 0;
}