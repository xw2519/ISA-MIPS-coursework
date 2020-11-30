#!/bin/bash

SOURCE_DIR="$1"   # command line argument that takes source directory, "../rtl" in our case
INSTRUCTION="${2:-all}"  # argument that takes an instruction to test, test all by default

g++ utils/hex_gen.cpp -o test/temp/hex_generator
echo ${INSTRUCTION} | test/temp/hex_generator > test/temp/test.hex.txt

iverilog -Wall -g 2012 \
    -s mips_cpu_harvard_tb test/testbench/mips_cpu_harvard_tb.v test/testbench/RAM_8x8192_harvard.v ${SOURCE_DIR}/mips_cpu_*.v ${SOURCE_DIR}/mips_cpu/*.v \
    -Pmips_cpu_harvard_tb.RAM_INIT_FILE=\"test/temp/test.hex.txt\" \
    -o test/temp/mips_harvard_test
test/temp/mips_harvard_test
