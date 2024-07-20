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

assert_breakpoint() {
  if ! printf "r\nsource info\n" |
    lldb -s /dev/stdin assert_handler 2>&1 |
    tail -1 |
    grep -q 'lime/tests/integration/core/debugging/assert_handler/config/config/overrides/assert_handler/core.d:23:5$'; then
      echo "Test failed: $(realpath "$0"):$(($LINENO - 1))" >&2
      exit 1
  fi
}

invoke_test_runner() {
  if has_argument "run" "$@"; then
    assert_breakpoint
  else
    ./test_runner.sh "$@"
  fi
}

invoke_dub() {
  if has_argument "--verbose" "$@"; then
    dub build
  else
    dub build > /dev/null
  fi

  assert_breakpoint
}

if [ -s test_runner.sh ]; then
  invoke_test_runner "$@"
else
  invoke_dub "$@"
fi
