#!/bin/bash

set -e

clang \
  -ffreestanding \
    -Wall -Wextra \
    -c \
    -nostdlib \
    -target i386-freestanding \
    kernel.c boot.asm

../ld.lld \
  -T link.ld \
  -o kernel.bin \
  -m elf_i386 \
  kernel.o boot.o
