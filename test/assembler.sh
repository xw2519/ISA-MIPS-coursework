#!/bin/bash

set -eou pipefail # Turn on warnings


python3 utils/assembler.py test/1-assembly/0-Independent/ test/2-binary/0-Independent/ -v
python3 utils/assembler.py test/1-assembly/1-Dependent/ test/2-binary/1-Dependent/ -v
python3 utils/assembler.py test/1-assembly/2-Dependent/ test/2-binary/2-Dependent/ -v
python3 utils/assembler.py test/1-assembly/3-Fundamental/ test/2-binary/3-Fundamental/ -v
python3 utils/assembler.py test/1-assembly/5-I-type/ test/2-binary/5-I-type/ -v
