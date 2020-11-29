
iverilog -Wall -g 2012 -s mips_cpu_harvard_tb mips_cpu_harvard_tb.v mips_cpu_harvard.v mips_cpu_alu.v mips_cpu_register_file.v RAM_8x8192_harvard.v -o mips_harvard_test
./mips_harvard_test
