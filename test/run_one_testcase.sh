#!/bin/bash

set -eou pipefail # Turn on warnings
rm test/4-output/* 2> /dev/null # Remove all previous output and discard warnings

# Parameter declarations
SOURCE_DIR="$1"
TEST_CASE="${2:-all}"

# Redirect output to stder (&2) so that it seperate from genuine outputs
>&2 echo "Testing instructions: ${TEST_CASE}"

>&2 echo "1 - Compiling test-bench"
iverilog -Wall -g 2012 \
    -s mips_cpu_bus_tb test/0-testbenches/RAM_8x8192_bus.v test/0-testbenches/mips_cpu_bus_tb.v ${SOURCE_DIR}/mips_cpu_*.v \
    -P mips_cpu_bus_tb.RAM_INIT_FILE=\"test/2-binary/${TEST_CASE}.hex.txt\" \
    -o test/3-simulator/mips_cpu_bus_tb_${TEST_CASE}


>&2 echo "2 - Running test-bench"
# "set +e" disable automatic script failure if command fails
set +e 
test/3-simulator/mips_cpu_bus_tb_${TEST_CASE} > test/4-output/mips_cpu_bus_tb_${TEST_CASE}.stdout


>&2 echo "3 - Extracting ouputs from CPU"
Reg_output="TB : INFO : register_v0="
Active_flag="TB : finished; active=" # To be added in later
Nothing=""

# Look at lines containing only phrases in Reg_output and Active_flag 
set +e 
grep "${Reg_output}\|${Active_flag}" test/4-output/mips_cpu_bus_tb_${TEST_CASE}.stdout > test/4-output/mips_cpu_bus_tb_${TEST_CASE}.out-lines
set -e 

# Replace "TB : INFO : register_v0=" and "TB : finished; active=" with ""
sed -e "s/${Reg_output}/${Nothing}/g; s/${Active_flag}/${Nothing}/g" test/4-output/mips_cpu_bus_tb_${TEST_CASE}.out-lines > test/4-output/mips_cpu_bus_tb_${TEST_CASE}.out

# Room for edge cases


>&2 echo "4 - Comparing output with reference"
set +e 
diff -w test/5-reference/${TEST_CASE}.out test/4-output/mips_cpu_bus_tb_${TEST_CASE}.out > test/4-output/${TEST_CASE}_comparison_errors.out
RESULT=$?
set -e

if [[ "${RESULT}" -ne 0 ]]; then 
    echo "${TEST_CASE}, FAIL"
else
    echo "${TEST_CASE}, PASS"
fi

