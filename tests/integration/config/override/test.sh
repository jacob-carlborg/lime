#!/bin/bash

set -eu
set -o pipefail

if [ -s test_runner.sh ]; then
  ./test_runner.sh
else
  dub
fi
