#!/bin/bash

# Turn on warnings
set -eou pipefail 

# Parameter declarations
SOURCE_DIRECTORY="$1"
INSTRUCTION="${2:-all}"  
TESTCASES="test/1-assembly/*.asm.txt"

#finding last charecter
LC="${INSTRUCTION: -1}"


if [${INSTRUCTION} != "all"]; then # Instructions specified
    
    if [[ ${LC} =~ [0-9] ]]; then

		>&2 echo "Running testcase ${INSTRUCTION} only"

		#Running specific test case
		./test/run_one_testcase.sh ${SOURCE_DIRECTORY} ${INSTRUCTION}

	else 

		#run all testcases with that name (all testcases for one instruction)

		>&2 echo "Running all testcases for ${INSTRUCTION}"

		TESTCS="test/1-assembly/*${INSTRUCTION}.asm.txt" 
		for i in ${TESTCS}; do 

			echo "${i}"
			
			#TESTNAME_S=$(basename ${i} .txt)
			#./test/run_one_testcase.sh ${SOURCE_DIRECTORY} ${TESTNAME_S}
		done

    fi

else # Run all

	>&2 echo "Running all testcases"

	for i in ${TESTCASES}; do 
	TESTNAME=$(basename ${i} .asm.txt)
	./test/run_one_testcase.sh ${SOURCE_DIRECTORY} ${TESTNAME}
	done
fi




