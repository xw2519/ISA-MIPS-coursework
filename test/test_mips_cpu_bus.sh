#!/bin/bash

# Capture the first two command line parameters to specify
# "SOURCE_DIR" argument that takes source directory, "../rtl" in our case
# "INSTRUCTION" argument that takes an instruction to test, test all by default
SOURCE_DIR="$1"   
INSTRUCTION="${2:-all}"  

#g++ ../utils/hex_gen.cpp -o ../test/bin/hex_generator
#echo ${INSTRUCTION} | ../bin/hex_generator > ../test/2-binary/test.hex.txt

iverilog -Wall -g 2012 \
    -s mips_cpu_bus_tb ../test/0-testbenches/RAM_8x8192_bus.v ../test/0-testbenches/mips_cpu_bus_tb.v ${SOURCE_DIR}/mips_cpu_*.v \
    -P mips_cpu_bus_tb.RAM_INIT_FILE=\"../test/2-binary/test1.hex.txt\" \
    -o ../test/3-simulator/mips_bus_test
    
../test/3-simulator/mips_bus_test
