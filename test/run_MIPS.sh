#!/bin/bash

#effectivly turning on warnings, may want to be changed if we want
# to continue testing if one test case has faild
set -eou pipefail 

SOURCE_DIRECTORY="$1"
INSTRUCTION="${2:-all}"  

#finding last charecter
LC="${INSTRUCTION: -1}"



#used to specify all files that are test cases
TESTCASES="1-assembly/*.asm.txt"

#Speciific instructions 

if [[ ${INSTRUCTION} != "all" ]]; then
    
    if [[ ${LC} =~ [0-9] ]]; then
        >&2 echo "Running testcase ${INSTRUCTION} only"
        #Running specific test case
        ./run_one_testcase.sh ${SOURCE_DIRECTORY} ${INSTRUCTION}
    else 
        #run all testcases with that name (all testcases for one instruction)
        #STILL DOESNT WORK !!!!!!!
        >&2 echo "Running all testcases for ${INSTRUCTION}"
    TESTCS="1-assembly/*${INSTRUCTION}.asm.txt" 
       for i in ${TESTCS}; do 
            echo "${i}"
            #TESTNAME_S=$(basename ${i} .txt)
            #./run_one_testcase.sh ${SOURCE_DIRECTORY} ${TESTNAME_S}
        done
    fi

else
#general case 
>&2 echo "Running all testcases"
    for i in ${TESTCASES}; do 
        TESTNAME=$(basename ${i} .asm.txt)
        ./run_one_testcase.sh ${SOURCE_DIRECTORY} ${TESTNAME}
    done
fi




