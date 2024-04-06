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
void step_and_dump_wave();
void reset();
void load_data();

int main(int argc, char *argv[]) {
    sim_init();
    // printf("Hello WOrld!!!\n");
    // step_and_dump_wave();
    // reset();
    // step_and_dump_wave();
    load_data();
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
    fifo->clk = 1;
    fifo->wr_data = 0;
    step_and_dump_wave();
}

void sim_exit()
{
    step_and_dump_wave();
    tfp->dump(contextp->time());
    tfp->close();
}

void step_and_dump_wave()
{
    tfp->dump(contextp->time());
    fifo->clk ^= 1;
    fifo->eval();
    contextp->timeInc(1);
    simtime++;
    tfp->dump(contextp->time());
    fifo->clk ^= 1;
    fifo->eval();
    contextp->timeInc(1);
    simtime++;
}

void reset() {
    step_and_dump_wave();
    fifo->rst = 1;
    step_and_dump_wave();
    fifo->rst = 0;
}

void load_data() {
    step_and_dump_wave();
    fifo->wr_sop = 1;
    step_and_dump_wave();
    fifo->wr_sop = 0;
    fifo->wr_vld = 1;
    fifo->wr_data = 11;
    step_and_dump_wave();
    fifo->wr_data = 22;
    step_and_dump_wave();
    fifo->wr_data = 33;
    step_and_dump_wave();
    fifo->wr_data = 44;
    step_and_dump_wave();
    fifo->wr_data = 55;
    step_and_dump_wave();
    fifo->wr_data = 66;
    step_and_dump_wave();
    fifo->wr_data = 77;
    step_and_dump_wave();
    fifo->wr_data = 88;
    step_and_dump_wave();
    fifo->wr_eop = 1;
    fifo->wr_vld = 0;
    step_and_dump_wave();
    fifo->wr_eop = 0;
    step_and_dump_wave();
}