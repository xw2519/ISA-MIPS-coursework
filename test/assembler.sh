#!/bin/bash

set -eou pipefail # Turn on warnings

#python3 utils/assembler.py test/1-assembly/2-Fundamental/ test/2-binary/2-Fundamental/ -v
python3 utils/assembler.py test/1-assembly/4-R-type/ test/2-binary/4-R-type/ -v
python3 utils/assembler.py test/1-assembly/5-I-type/ test/2-binary/5-I-type/ -v
python3 utils/assembler.py test/1-assembly/6-J-type/ test/2-binary/6-J-type/ -v
