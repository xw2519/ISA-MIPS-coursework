#!/bin/bash

set -eou pipefail # Turn on warnings

# Parameter declarations
TESTBENCH_DIR="test/0-testbenches"
ASSEM_DIR="test/1-assembly"
BIN_DIR="test/2-binary"
SIMUL_DIR="test/3-simulator"
OUT_DIR="test/4-output"
REF_DIR="test/5-reference"

# Script input
# - "SOURCE_DIR"    - Source directory e.g. "rtl"
# - "TEST_CASE"     - Instruction to be tested e.g "addiu". Default argument set to "-all"
# - "TEST_TYPE"   - Folder of the instruction to be tested
SOURCE_DIR="$1"
TEST_CASE="${2:-all}"
TEST_TYPE="$3"

# Remove all previous output of specific testcase and discard warnings
rm -rf test/4-output/${TEST_TYPE}/${TEST_CASE}* 

# Assembling all testcase files in test/1-assembly with the file extention .asm.txt
#./test/assembler.sh

# Extract assembly file parameters
Case_ID=$(awk 'NR==7' ${ASSEM_DIR}/${TEST_TYPE}/${TEST_CASE}.asm.txt)
Case_Instr=$(awk 'NR==8' ${ASSEM_DIR}/${TEST_TYPE}/${TEST_CASE}.asm.txt)
Case_Comment=$(awk 'NR==9' ${ASSEM_DIR}/${TEST_TYPE}/${TEST_CASE}.asm.txt)


# Redirect output to stder (&2) so that it seperated from genuine outputs
# >&2 echo "Testing instructions: ${TEST_CASE}"
# >&2 echo "1 - Compiling test-bench"
iverilog -Wall -g 2012 \
    -s mips_cpu_bus_tb ${TESTBENCH_DIR}/RAM_8x8192_avalon_mapped.v ${TESTBENCH_DIR}/mips_cpu_bus_tb.v ${SOURCE_DIR}/mips_cpu_*.v \
    -P mips_cpu_bus_tb.RAM_INIT_FILE=\"${BIN_DIR}/${TEST_TYPE}/${TEST_CASE}.hex.txt\" \
    -o ${SIMUL_DIR}/${TEST_TYPE}/mips_cpu_bus_tb_${TEST_CASE}

# >&2 echo "2 - Running test-bench"
# "set +e" disable automatic script failure if command fails
set +e 
${SIMUL_DIR}/${TEST_TYPE}/mips_cpu_bus_tb_${TEST_CASE} > ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.stdout

# >&2 echo "3 - Extracting ouputs from CPU"
Reg_output="TB : INFO : register_v0="
Active_flag="TB : finished; active=" 
RAM_accesses="TB : INFO : RAM_ACCESS:"
Nothing=""

# Check if contents in reference files are available in .stdout file
# >&2 echo "4 - Comparing output with reference"
set +e 
diff -q <(sort -u ${REF_DIR}/${TEST_TYPE}/${TEST_CASE}.txt) \
        <(grep -Fxf ${REF_DIR}/${TEST_TYPE}/${TEST_CASE}.txt ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.stdout | sort -u) \
        > ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}_diff_out

RESULT=$?
set -e

set +e 
LAST_LINE=$(tail -n -1 "${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.stdout")
# >&2 echo "${LAST_LINE}"
set -e

# Output formatting
if [ "${RESULT}" -ne 0 ]; then 
    echo "${Case_ID} ${Case_Instr} Fail ${Case_Comment}"
else
    echo "${Case_ID} ${Case_Instr} Pass ${Case_Comment}"
fi
