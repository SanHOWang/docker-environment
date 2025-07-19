#!/bin/bash

help() {
    cat <<EOF

Usage: eman [command]

  eman help                     : Show this help message

  C Compiler / Make
  -----------------------------
  eman c-version               : Print version of GCC and Make
  eman c-example               : Compile and run C example

  Verilator
  -----------------------------
  eman verilator-version       : Print the version of Verilator
  eman verilator-example       : Compile and run Verilator example

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
    EX_DIR="$HOME/workspace/lab0/c_cpp/arrays/multidim_array"
    if [ ! -f "$EX_DIR/Makefile" ]; then
        echo "C example not found at $EX_DIR"
        return 1
    fi

    pushd "$EX_DIR" > /dev/null
    make clean && make all && ./main.exe
    popd > /dev/null
}

verilator_example() {
    EX_DIR="$HOME/workspace/lab0/verilog/counter"
    if [ ! -f "$EX_DIR/Makefile" ]; then
        echo "Verilator example not found at $EX_DIR"
        return 1
    fi

    pushd "$EX_DIR" > /dev/null
    make clean && make run
    popd > /dev/null
}

case "$1" in
    help|"") help ;;
    verilator-version) check_verilator ;;
    verilator-example) verilator_example ;;
    c-version) c_compiler_version ;;
    c-example) c_compiler_example ;;
    *) echo "Unknown command: $1"; help ;;
esac
