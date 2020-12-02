#!/bin/bash
set -eou pipefail

SOURCE_DIRECTORY="$1"
TESTCASE="$2"

# Redirect output to stder (&2) so that it seperate from genuine outputs
>&2 echo "Testing CPU using ${TESTCASE}"

>&2 echo "Assembling input file"
#To be sorted 
#either created on the fly or access pre built files 

>&2 echo "Compiling test-bench"

#this will need changing so addressing is correct 
#and memory is initilised correctly 

iverilog -g 2012 \
   ${SOURCE_DIRECTORY} 0-testbenches/mips_cpu_bus_tb.v 0-testbenches/RAM_*.v \
   -s mips_cpu_bus_tb \
   -Pmips_cpu_bus_tb.RAM_INIT_FILE=\"2-binary/${TESTCASE}.hex.txt\" \
   -o 3-simulator/mips_cpu_bus_tb_${TESTCASE}



>&2 echo "Running test-bench"

#+e disables automatic script failure if command fails

set +e 
3-simulator/mips_cpu_bus_tb_${TESTCASE} > 4-output/mips_cpu_bus_tb_${TESTCASE}.stdout
#exit code:
RESULT=$?
set -e

if [${RESULT} -ne 0]; then 
    echo "${TESTCASE} FAILED"
    exit
fi 

#next steps are to obtain outputs from CPU to then compare them with simmulator or known values

>&2 echo "Extracting ouputs from CPU"

P="TB : INFO : register_v0="
N=""

#grep looks at lines containing P
set +e 
grep "${P}" 4-output/mips_cpu_bus_tb_${TESTCASE}.stdout > 4-output/mips_cpu_bus_tb_${TESTCASE}.out-lines
set -e 

#sed replaces unwanyed bits (P) with N
sed -e "s/${P}/${N}/g" 4-output/mips_cpu_bus_tb_${TESTCASE}.out-lines > 4-output/mips_cpu_bus_tb_${TESTCASE}.out



