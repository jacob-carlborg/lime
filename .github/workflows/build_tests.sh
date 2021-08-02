#!/usr/bin/env bash

set -eux
set -o pipefail

. ./tools/install_dc.sh

install_compiler
print_d_compiler_version
dub --single tools/generate_test_scripts.d
./test.sh compile
