#!/bin/bash

set -eou pipefail # Turn on warnings

# Capture the first two command line parameters
# - "SOURCE_DIR" argument defines source directory: "rtl" in our case
# - "INSTRUCTION" argument defines instruction to test (e.g addiu): test all by default
# - Added third option to test specific test case of instruction (e.g addiu1)


SOURCE_DIR="$1"
INSTRUCTION="${2:-all}"  

# Last character identifying whether "INSTRUCTION":
# - All test cases
# - Specific test case 
LAST_CHARACTER="${INSTRUCTION: -1}"

# Specify all files that are test cases 
# "INSTRUCTION" == "all"
TESTCASES_ALL="test/1-assembly/*.asm.txt"
# "INSTRUCTION" == <instruction name>
TESTCASES_INSTR="test/1-assembly/""${INSTRUCTION}""*.asm.txt"

# Identify which option "INSTRUCTION" is
if [[ ${INSTRUCTION} != "all" ]]; then
    
    if [[ ${LAST_CHARACTER} =~ [0-9] ]]; then
        # >&2 echo "Running testcase ${INSTRUCTION} only"
        # Run specific test case
        ./test/run_one_testcase.sh ${SOURCE_DIR} ${INSTRUCTION}
    else 
        # Run all testcases of instruction (all testcases for one instruction)
        # >&2 echo "Running all testcases for ${INSTRUCTION}"
        for i in ${TESTCASES_INSTR}; do 
            TESTNAME_INSTR=$(basename ${i} .asm.txt)
            ./test/run_one_testcase.sh ${SOURCE_DIR} ${TESTNAME_INSTR}
        done
    fi

else

# Running general case, testing all by defult 
# >&2 echo "Running all testcases"
    for i in ${TESTCASES_ALL}; do 
        TESTNAME_ALL=$(basename ${i} .asm.txt)
        ./test/run_one_testcase.sh ${SOURCE_DIR} ${TESTNAME_ALL}
    done
fi