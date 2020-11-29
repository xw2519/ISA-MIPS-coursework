#!/bin/bash

g++ ../utils/hex_gen.cpp -o hex_generator
./hex_generator > test.hex.txt

iverilog -Wall -g 2012 -s mips_cpu_bus_tb ../rtl/mips_cpu_bus_tb.v ../rtl/mips_cpu_bus.v ../rtl/mips_cpu_harvard.v ../rtl/mips_cpu_alu.v ../rtl/mips_cpu_register_file.v ../rtl/RAM_8x8192_bus.v -o mips_bus_test
./mips_bus_test
