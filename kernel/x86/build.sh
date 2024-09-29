#!/bin/bash

set -e

if [ -s "$HOME/.dvm/scripts/dvm" ] ; then
  . "$HOME/.dvm/scripts/dvm" ;
  dvm use ldc-1.39.0
fi

ldc2 \
  -c \
  -ofkernel.o \
  -mtriple i386-freestanding \
  --fno-moduleinfo \
  -g \
  kernel.d

../ld.lld \
  -T link.ld \
  -o kernel.bin \
  -m elf_i386 \
  kernel.o

# ldc2 \
#   -ofkernel.bin \
#   -mtriple i386-freestanding \
#   --fno-moduleinfo \
#   --defaultlib= \
#   --link-internally \
#   -L-m -Lelf_i386 \
#   -L-T -Llink.ld -v \
#   -L--no-gc-sections \
#   kernel.d
