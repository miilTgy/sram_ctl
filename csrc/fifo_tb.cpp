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

int main(int argc, char *argv[]) {
    printf("Hello WOrld!!!\n");
    return 0;
}