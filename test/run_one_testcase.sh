#!/bin/bash

set -eou pipefail # Turn on warnings
rm -rf test/4-output/* # Remove all previous output and discard warnings

# Parameter declarations
SOURCE_DIR="$1"
TEST_CASE="${2:-all}"
TESTBENCH_DIR="test/0-testbenches"
ASSEM_DIR="test/1-assembly"
BIN_DIR="test/2-binary"
SIMUL_DIR="test/3-simulator"
OUT_DIR="test/4-output"
REF_DIR="test/5-reference"

# Redirect output to stder (&2) so that it seperate from genuine outputs
>&2 echo "Testing instructions: ${TEST_CASE}"

>&2 echo "1 - Compiling test-bench"
iverilog -Wall -g 2012 \
    -s mips_cpu_bus_tb ${TESTBENCH_DIR}/RAM_8x8192_bus.v ${TESTBENCH_DIR}/mips_cpu_bus_tb.v ${SOURCE_DIR}/mips_cpu_*.v \
    -P mips_cpu_bus_tb.RAM_INIT_FILE=\"${BIN_DIR}/${TEST_CASE}.hex.txt\" \
    -o ${SIMUL_DIR}/mips_cpu_bus_tb_${TEST_CASE}


>&2 echo "2 - Running test-bench"
# "set +e" disable automatic script failure if command fails
set +e 
${SIMUL_DIR}/mips_cpu_bus_tb_${TEST_CASE} > ${OUT_DIR}/${TEST_CASE}.stdout


>&2 echo "3 - Extracting ouputs from CPU"
Reg_output="TB : INFO : register_v0="
Active_flag="TB : finished; active=" # To be added in later
Nothing=""

# Look at lines containing only phrases in Reg_output and Active_flag 
set +e 
grep "${Reg_output}\|${Active_flag}" ${OUT_DIR}/${TEST_CASE}.stdout > ${OUT_DIR}/${TEST_CASE}.out-lines
set -e 

# Replace "TB : INFO : register_v0=" and "TB : finished; active=" with ""
sed -e "s/${Reg_output}/${Nothing}/g; s/${Active_flag}/${Nothing}/g" ${OUT_DIR}/${TEST_CASE}.out-lines > ${OUT_DIR}/${TEST_CASE}.out

# Room for edge cases


>&2 echo "4 - Comparing output with reference"
set +e 
diff -w ${REF_DIR}/${TEST_CASE}.out ${OUT_DIR}/${TEST_CASE}.out > ${OUT_DIR}/${TEST_CASE}_diff_out
RESULT=$?
set -e

if [[ "${RESULT}" -ne 0 ]]; then 
    echo "${TEST_CASE}, FAIL"
else
    echo "${TEST_CASE}, PASS"
fi

