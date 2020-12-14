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
LAST_CHAR="${INSTRUCTION: -1}"



# Specify all files that are test cases 
# "INSTRUCTION" == "all"

# "INSTRUCTION" == <instruction name>
#TESTCASES_INSTR="test/1-assembly/""${INSTRUCTION}""*.asm.txt"



if [[ ${INSTRUCTION} != "all" ]]; then # Identify which option "INSTRUCTION" is
    
    if [[ ${LAST_CHAR} =~ [0-9] ]]; then # Specific test case
        
        for TEST_FOLDER in ${ASSEM_DIR}/*; # Search for speciic test case and return TEST_TYPE
        do
            TEST_TYPE="$(basename -- $TEST_FOLDER)"

            for TEST_FILE in ${TEST_FOLDER}/*;
            do
                TEST_CASE="$(basename -- ${TEST_FILE})"
                TEST_CASE=${TEST_CASE//".asm.txt"/}

                if [[ ${TEST_CASE} == ${INSTRUCTION} ]]; then
                    ./test/run_one_testcase.sh ${SOURCE_DIR} ${TEST_CASE} ${TEST_TYPE}
                fi
            done
        done

    else # All testcases of an instruction

        for TEST_FOLDER in ${ASSEM_DIR}/*; # Search for speciic test case and return TEST_TYPE
        do
            TEST_TYPE="$(basename -- $TEST_FOLDER)"

            for TEST_FILE in ${TEST_FOLDER}/*;
            do
                TEST_CASE="$(basename -- ${TEST_FILE})"
                TEST_CASE=${TEST_CASE//".asm.txt"/}

                if [[ ${TEST_CASE::-1} == ${INSTRUCTION} ]]; then
                    ./test/run_one_testcase.sh ${SOURCE_DIR} ${TEST_CASE} ${TEST_TYPE}
                fi
            done

        done

    fi

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