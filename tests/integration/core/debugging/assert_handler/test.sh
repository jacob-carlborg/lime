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

assert_assert_handler() {
  local output="$(./assert_handler 2>&1)"

  if ! echo "$output" | grep -q 'handler hit'; then
      echo "Test failed: $(realpath "$0"):$(($LINENO - 1))" >&2
      printf "Output was:\n" >&2
      echo "$output"
      exit 1
  fi
}

invoke_test_runner() {
  if has_argument "run" "$@"; then
    assert_assert_handler
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

  assert_assert_handler
}

if [ -s test_runner.sh ]; then
  invoke_test_runner "$@"
else
  invoke_dub "$@"
fi
