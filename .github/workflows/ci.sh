#!/usr/bin/env bash

set -eu
set -o pipefail

. ./tools/install_dc.sh

print_d_compiler_version() {
  "${DMD}" --version
}

run_tests() {
  DC="${DMD}" ./test.sh
  # dub test --verror --compiler="${DMD}" --arch="${LIME_ARCH}"
}

install_compiler
print_d_compiler_version
run_tests
