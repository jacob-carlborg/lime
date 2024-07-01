#!/usr/bin/env bash

set -eu
set -o pipefail

. ./tools/install_dc.sh

if [ -z ${LIME_CROSS_COMPILE} ]; then
  cross_compile=false
else
  cross_compile=true
fi

install_c_compiler() {
  if "$cross_compile" && ! command -v cc > /dev/null; then
    apt update
    apt install -y gcc
  fi
}

run_tests() {
  local extra_args=""

  if "$cross_compile"; then
    ./test.sh --verbose link
    extra_args="run"
  fi

  ./test.sh --verbose "$extra_args"
}

install_dc() {
  if ! "$cross_compile"; then
    install_compiler
    print_d_compiler_version
  fi
}

install_dc
install_c_compiler
run_tests
