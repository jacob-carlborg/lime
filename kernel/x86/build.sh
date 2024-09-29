#!/bin/bash

set -e

if [ -s "$HOME/.dvm/scripts/dvm" ] ; then
  . "$HOME/.dvm/scripts/dvm" ;
  dvm use ldc-1.39.0
fi

ldc2 \
  -ofkernel.bin \
  -mtriple i386-freestanding \
  --fno-moduleinfo \
  -g \
  --defaultlib= \
  --disable-linker-strip-dead \
  --link-internally \
  kernel.d
