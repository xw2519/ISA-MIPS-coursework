#!/bin/bash

set -eou pipefail # Turn on warnings

# Parameter declarations
SOURCE_DIR="$1"
TESTBENCH_DIR="test/0-testbenches"
ASSEM_DIR="test/1-assembly"
BIN_DIR="test/2-binary"
SIMUL_DIR="test/3-simulator"
OUT_DIR="test/4-output"
REF_DIR="test/5-reference"


for TEST_FOLDER in ${ASSEM_DIR}/*; 
do
#echo ${TEST_FOLDER}
    TEST_TYPE="$(basename -- $TEST_FOLDER)" 
    echo ${TEST_TYPE}
    for i in ${TEST_FOLDER}/*.asm.txt; do 
        echo -e "${i}"
        INSTR_NAME="$(basename -- $i)"
        echo ${INSTR_NAME}
        INSTR_NAME=${INSTR_NAME//".asm.txt"/}
        echo ${INSTR_NAME}
        #./test/run_one_testcase.sh ${SOURCE_DIR} ${INSTR_NAME}
        exit 1
    done
        
done

