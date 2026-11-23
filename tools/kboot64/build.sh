#!/bin/sh
# usage: build.sh <arm64 Image> <arm64 dtb> <out kernel blob for mkbootimg>
set -e
LD=${LD:-$HOME/k130-build/tc/bin/aarch64-linux-android-ld}
LDEMU=${LDEMU-"-m armelf"}
IMG=$(readlink -f "$1"); DTB=$(readlink -f "$2"); OUT=$(readlink -f "$(dirname "$3")")/$(basename "$3")
cd "$(dirname "$0")"
lz4 -l -9 -f -q "$IMG" Image.lz4
CF="--target=armv7a-none-eabi -marm -mfloat-abi=soft -mno-unaligned-access -ffreestanding -fno-builtin -fno-pic -O2 -Wall -Werror"
clang $CF -c start.S -o start.o
clang $CF -c kboot.c -o kboot.o
$LD $LDEMU -T kboot.lds -o kboot.elf start.o kboot.o
llvm-objcopy -O binary kboot.elf kboot.bin
cat kboot.bin "$DTB" > "$OUT"
ls -l Image.lz4 kboot.bin "$OUT"
