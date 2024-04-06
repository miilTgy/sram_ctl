#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <math.h>
#include <string.h>
#include "Vfifo.h"
#include "verilated.h"
// #include <nvboard.h>

#include "verilated_vcd_c.h"

VerilatedContext *contextp = NULL;
VerilatedVcdC *tfp = NULL;
static Vfifo *fifo;
vluint64_t simtime = 0;

void sim_init();
void sim_exit();

int main(int argc, char *argv[]) {
    sim_init();
    // printf("Hello WOrld!!!\n");
    sim_exit();
    return 0;
}

void sim_init() {
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    fifo = new Vfifo;
    contextp->traceEverOn(true);
    fifo->trace(tfp, 0);
    tfp->open("dump.vcd");
    fifo->wr_data = 0;
}
void sim_exit()
{
  tfp->close();
}