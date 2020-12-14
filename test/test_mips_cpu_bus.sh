#!/bin/bash

set -eou pipefail # Turn on warnings

# Directory parameters
ASSEM_DIR="test/1-assembly"

# Standard specification input requirement:
# - "SOURCE_DIR"  - Source directory e.g. "rtl"
# - "INSTRUCTION" - Instruction to be tested e.g "addiu". Default argument set to "-all"
SOURCE_DIR="$1"
INSTRUCTION="${2:-all}"  

# - Custom feature to test the individual test cases of an instruction e.g "addiu1"
#   -Last character identifying whether "INSTRUCTION":
#       - All test cases
#       - Specific test case 
LAST_CHARACTER="${INSTRUCTION: -1}"



# Specify all files that are test cases 
# "INSTRUCTION" == "all"

# "INSTRUCTION" == <instruction name>
#TESTCASES_INSTR="test/1-assembly/""${INSTRUCTION}""*.asm.txt"



if [[ ${INSTRUCTION} != "all" ]]; then # Identify which option "INSTRUCTION" is
    
    #if [[ ${LAST_CHARACTER} =~ [0-9] ]]; then
        # >&2 echo "Running testcase ${INSTRUCTION} only"
        # Run specific test case
    #    ./test/run_one_testcase.sh ${SOURCE_DIR} ${INSTRUCTION}
    #else 
        # Run all testcases of instruction (all testcases for one instruction)
        # >&2 echo "Running all testcases for ${INSTRUCTION}"
    #    for i in ${TESTCASES_INSTR}; do 
    #        TESTNAME_INSTR=$(basename ${i} .asm.txt)
    #        ./test/run_one_testcase.sh ${SOURCE_DIR} ${TESTNAME_INSTR}
    #    done
    #fi
    echo "HI"

else # Default case: Run all testcases

    for TEST_FOLDER in ${ASSEM_DIR}/*; 
    do
        TEST_TYPE="$(basename -- $TEST_FOLDER)"

        for i in ${TEST_FOLDER}/*.asm.txt; do 
            TEST_CASE="$(basename -- $i)"
            TEST_CASE=${TEST_CASE//".asm.txt"/} # Remove ".asm.txt"
            ./test/run_one_testcase.sh ${SOURCE_DIR} ${TEST_CASE} ${TEST_TYPE}
        done
        
    done
fi