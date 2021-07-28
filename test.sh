#!/bin/bash

set -eu
set -o pipefail

find tests -name test.sh -print0 |
  while IFS= read -r -d '' line; do
    pushd $(dirname "$line") > /dev/null
    ./test.sh
    popd > /dev/null
  done
