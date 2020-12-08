#!/bin/bash
set -eou pipefail

TESTCASE="$1"

mipsel-linux-gnu-gcc -c -EL -mfp32 -mips1 test/1-assembly/${TESTCASE}.asm.txt -o test/2-binary/plswrk/obj/${TESTCASE}.o

#xxd test/2-binary/plswrk/${TESTCASE}.o > test/2-binary/plswrk/${TESTCASE}_hex.txt

