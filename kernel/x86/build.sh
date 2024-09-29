#!/bin/bash

set -e

if [ -s "$HOME/.dvm/scripts/dvm" ] ; then
  . "$HOME/.dvm/scripts/dvm" ;
  dvm use ldc-1.39.0
fi

clang \
  -Wall -Wextra \
  -c \
  -nostdlib \
  -o boot.o \
  -target i386-freestanding \
  boot.asm

ldc2 \
  -c \
  -ofkernel.o \
  -mtriple i386-freestanding \
  --defaultlib= \
  --fno-moduleinfo \
  -g \
  kernel.d

../ld.lld \
  -T link.ld \
  -o kernel.bin \
  -m elf_i386 \
  kernel.o boot.o
