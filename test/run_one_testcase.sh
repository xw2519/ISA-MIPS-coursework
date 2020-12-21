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
Active_flag="TB : Finished : active="
RAM_write="TB : INFO : RAM_ACCESS: Write to"
RAM_read="TB : INFO : RAM_ACCESS: Read from"
RAM_read_instr="TB : INFO : RAM_ACCESS: Read from 0xbfc00000"
RAM_halt="TB : INFO : RAM_ACCESS: Read from 0x00000000"
Nothing=""

set +e

grep "${Reg_output}\|${Active_flag}\|${RAM_write}\|${RAM_read_instr}\|${RAM_halt}" \
${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.stdout > ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.out
set -e

if [ $(grep -c "${RAM_read_instr}" ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.out) -gt 1 ]; then
	DUP_LINE=$(grep -m 1 "${RAM_read_instr}" ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.out)
	sed -i "/$RAM_read_instr/d" ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.out
	echo $DUP_LINE >> ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.out
fi
if [ $(grep -c "${RAM_halt}" ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.out) -gt 1 ]; then
	DUP_LINE=$(grep -m 1 "${RAM_halt}" ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.out)
	sed -i "/$RAM_halt/d" ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.out
	echo $DUP_LINE >> ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.out
fi

# Check if contents in reference files are available in .out file
# >&2 echo "4 - Comparing output with reference"
set +e
RAM_READS=$(grep -c "${RAM_read}" ${REF_DIR}/${TEST_TYPE}/${TEST_CASE}.txt )
if [ $RAM_READS -gt 2 ]; then
	diff -w <(sort <(grep "${Reg_output}\|${Active_flag}\|${RAM_write}\|${RAM_read}" ${REF_DIR}/${TEST_TYPE}/${TEST_CASE}.txt)) <(sort <(grep "${Reg_output}\|${Active_flag}\|${RAM_write}\|${RAM_read}" ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.stdout)) 1>/dev/null
	RESULT=$?
else
	diff -w <(sort ${REF_DIR}/${TEST_TYPE}/${TEST_CASE}.txt) <(sort ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.out) > ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.diff_out
#diff -q <(sort -u ${REF_DIR}/${TEST_TYPE}/${TEST_CASE}.txt)  <(grep -Fxf ${REF_DIR}/${TEST_TYPE}/${TEST_CASE}.txt ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.stdout | sort -u) > ${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}_diff_out
	RESULT=$?
#echo $RESULT
fi
set -e
#echo $RESULT
set +e

LAST_LINE=$(tail -n -1 "${OUT_DIR}/${TEST_TYPE}/${TEST_CASE}.stdout")
# >&2 echo "${LAST_LINE}"
set -e

# Output formatting
if [ "${RESULT}" -ne 0 ] || [ "${LAST_LINE}" != "TB : Finished : active=0" ]; then
    echo "${Case_ID} ${Case_Instr} Fail ${Case_Comment}"
else
    echo "${Case_ID} ${Case_Instr} Pass ${Case_Comment}"
fi
