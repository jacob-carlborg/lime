#!/usr/bin/env bash

set -eu
set -o pipefail

export MACOSX_DEPLOYMENT_TARGET=13.3

has_argument() {
  local term="$1"
  shift
  for arg; do
    if [ $arg == "$term" ]; then
      return 0
    fi
  done

  return 1
}

compile_cpp() {
  c++ -std=c++20 -c cpp_source/utility.cpp -o utility.o
}

if [ -s test_runner.sh ]; then
  if has_argument "link" "$@"; then
    compile_cpp
  fi

  ./test_runner.sh "$@"
else
  compile_cpp
  dub -b unittest
fi
