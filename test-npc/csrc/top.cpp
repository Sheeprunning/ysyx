#include <init.h>
#include <sdb.h>
#include <sim.h>

int main(int argc, char *argv[]) {
    Verilated::commandArgs(argc, argv);
    init_main(argc,argv);
    sdb_mainloop();
    sim_exit();
    return 0;
}