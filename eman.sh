#!/bin/bash

help() {
    cat <<EOF

Usage: eman [command]

  eman help                     : Show this help message

  C Compiler / Make
  -----------------------------
  eman c-compiler-version       : Print version of GCC and Make
  eman c-compiler-example       : Compile and run C example

  Verilator
  -----------------------------
  eman check-verilator          : Print the version of Verilator
  eman verilator-example        : Compile and run Verilator example

EOF
}

check_verilator() {
    if command -v verilator &> /dev/null; then
        verilator --version
    else
        echo "Verilator not found"
    fi
}

c_compiler_version() {
    gcc --version | head -n1
    make --version | head -n1
}

c_compiler_example() {
    TMPDIR=$(mktemp -d)
    cat > $TMPDIR/main.c <<EOF
#include <stdio.h>
int main() {
    int arr[2][3][4] = {
        {{1,2,3,4},{5,6,7,8},{9,10,11,12}},
        {{13,14,15,16},{17,18,19,20},{21,22,23,24}}
    };
    int *ptr = (int*)arr;
    printf("-----  print out  -----\\n");
    for (int i = 0; i < 24; ++i) {
        printf("addr: %p , value: %d\\n", &ptr[i], ptr[i]);
    }
    return 0;
}
EOF

    cat > $TMPDIR/Makefile <<EOF
BIN := main.exe
CC := gcc
CFLAGS := -Wall -Wextra -O2
SRC := main.c
OBJ := \$(SRC:.c=.o)

all: \$(BIN)

\$(BIN): \$(OBJ)
	\$(CC) \$^ -o \$@

%.o: %.c
	\$(CC) -c \$(CFLAGS) \$< -o \$@

run: \$(BIN)
	./\$(BIN)

clean:
	rm -f \$(BIN) \$(OBJ)
EOF

    cd $TMPDIR
    make all && ./main.exe
    cd -
    rm -rf $TMPDIR
}

verilator_example() {
    TMPDIR=$(mktemp -d)
    cd $TMPDIR

    cat > Counter.v <<EOF
module Counter(
    input clk,
    input rst,
    input [8:0] max,
    output reg [8:0] out
);
    reg [8:0] cnt;
    always @(posedge clk, posedge rst)
        if (rst) cnt <= max;
        else if (cnt == 0) cnt <= max;
        else cnt <= cnt - 1;
    always @(*) out = cnt;
endmodule
EOF

    cat > testbench.cc <<EOF
#include <iostream>
#include "VCounter.h"
#include "verilated_vcd_c.h"
int main() {
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC();
    auto dut = new VCounter;
    dut->trace(tfp, 0);
    tfp->open("wave.vcd");

    int clk = 0;
    const int maxclk = 10;

    dut->rst = 1;
    dut->max = 9;
    dut->clk = 1; dut->eval(); tfp->dump(clk++);
    dut->rst = 0;

    while (clk < maxclk << 1) {
        dut->clk = 0; dut->eval(); tfp->dump(clk++);
        dut->clk = 1; dut->eval(); tfp->dump(clk++);
        std::cout << "count: " << dut->out << std::endl;
    }

    tfp->close();
    dut->final();
    delete dut;
    return 0;
}
EOF

    verilator --cc --exe --trace Counter.v testbench.cc --build
    ./obj_dir/VCounter
    cd -
    rm -rf $TMPDIR
}

case "$1" in
    help|"") help ;;
    check-verilator) check_verilator ;;
    verilator-example) verilator_example ;;
    c-compiler-version) c_compiler_version ;;
    c-compiler-example) c_compiler_example ;;
    *) echo "Unknown command: $1"; help ;;
esac
