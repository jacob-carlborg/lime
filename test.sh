#!/usr/bin/env bash

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

test_action_description() {
  if has_argument "compile" "$@"; then
    echo "Compiling"
  elif has_argument "link" "$@"; then
    echo "Linking"
  elif has_argument "run" "$@"; then
    echo "Running"
  else
    echo "Unrecognized test action"
    exit 1
  fi
}

find tests -name test.sh -print0 |
  while IFS= read -r -d '' line; do
    pushd $(dirname "$line") > /dev/null
    echo "********** $(test_action_description "$@") tests in: $(pwd)"

    if has_argument "--verbose" "$@"; then
      ./test.sh "$@"
    else
      ./test.sh "$@" > /dev/null
    fi

    popd > /dev/null
  done
