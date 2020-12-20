#!/bin/bash

set -eou pipefail # Turn on warnings


python3 utils/assembler.py test/1-assembly/0-Fundemental/ test/2-binary/0-Fundemental/ -v
python3 utils/assembler.py test/1-assembly/1-Dependent/ test/2-binary/1-Dependent/ -v
python3 utils/assembler.py test/1-assembly/2-Dependent/ test/2-binary/2-Dependent/ -v
python3 utils/assembler.py test/1-assembly/3-Integration/ test/2-binary/3-Integration/ -v