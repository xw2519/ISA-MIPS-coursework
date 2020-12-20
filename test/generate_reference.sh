#!/bin/bash

set -eou pipefail # Turn on warnings

python3 utils/create_ref.py test/4-output/0-Fundemental/ test/5-reference/0-Fundemental/ -v
python3 utils/create_ref.py test/4-output/1-Dependent/ test/5-reference/1-Dependent/ -v
python3 utils/create_ref.py test/4-output/2-Dependent/ test/5-reference/2-Dependent/ -v
python3 utils/create_ref.py test/4-output/3-Integration/ test/5-reference/3-Integration/ -v