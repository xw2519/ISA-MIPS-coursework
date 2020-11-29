#!/bin/bash

g++ ../utils/hex_gen.cpp -o hex_generator
./hex_generator > test.hex.txt

iverilog -Wall -g 2012 -s mips_cpu_harvard_tb ../rtl/mips_cpu_harvard_tb.v ../rtl/mips_cpu_harvard.v ../rtl/mips_cpu_alu.v ../rtl/mips_cpu_register_file.v ../rtl/RAM_8x8192_harvard.v -o mips_harvard_test
./mips_harvard_test
