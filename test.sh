#!/bin/bash

set -eu
set -o pipefail

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

find tests -name test.sh -print0 |
  while IFS= read -r -d '' line; do
    pushd $(dirname "$line") > /dev/null
    echo "********** Running tests in: $(pwd)"

    if has_argument "--verbose" "$@"; then
      ./test.sh
    else
      ./test.sh > /dev/null
    fi

    popd > /dev/null
  done