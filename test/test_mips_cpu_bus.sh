#!/bin/bash

set -eou pipefail # Turn on warnings

# Capture the first two command line parameters to specify
# "SOURCE_DIRECTORY" argument that takes source directory, "rtl" in our case
# "INSTRUCTION" argument that takes an instruction to test (e.g addiu), test all by default
# Added third option to test specific test case of instruction (e.g addiu1)


SOURCE_DIRECTORY="$1"
INSTRUCTION="${2:-all}"  

# Finding last character, to identify whether INSTRUCTION is "all", a specific test case or all testcases for a given instructiuon
LAST_CHARECTER="${INSTRUCTION: -1}"

# Used to specify all files that are test cases 
# For INSTRUCTION == "all"
TESTCASES_ALL="test/1-assembly/*.asm.txt"

# For INSTRUCTION == <instruction name>
TESTCASES_INSTR="test/1-assembly/""${INSTRUCTION}""*.asm.txt"

# Identifying which option INSTRUCTION is
if [[ ${INSTRUCTION} != "all" ]]; then
    
    if [[ ${LAST_CHARECTER} =~ [0-9] ]]; then
        >&2 echo "Running testcase ${INSTRUCTION} only"
# Running specific test case
        ./test/run_one_testcase.sh ${SOURCE_DIRECTORY} ${INSTRUCTION}
    else 
# Running all testcases with that name (all testcases for one instruction)
        >&2 echo "Running all testcases for ${INSTRUCTION}"
       for i in ${TESTCASES_INSTR}; do 
            TESTNAME_INSTR=$(basename ${i} .asm.txt)
            ./test/run_one_testcase.sh ${SOURCE_DIRECTORY} ${TESTNAME_INSTR}
        done
    fi

else
# Running general case, testing all by defult 
>&2 echo "Running all testcases"
    for i in ${TESTCASES_ALL}; do 
        TESTNAME_ALL=$(basename ${i} .asm.txt)
        ./test/run_one_testcase.sh ${SOURCE_DIRECTORY} ${TESTNAME_ALL}
    done
fi




