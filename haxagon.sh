#!/usr/bin/env bash
#
# Copyright (C) 2023 Edwiin Kusuma Jaya (ryuzenn)
#
# Simple Local Kernel Build Script
#
# Configured for Redmi Note 8 / ginkgo custom kernel source
#
# Setup build env with akhilnarang/scripts repo
#
# Use this script on root of kernel directory

SECONDS=0 # builtin bash timer
ZIPNAME="Hexagon-Ginkgo-OC-$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M").zip"
#CLANG_DIR="/usr/bin/clang"
CLANG_DIR="/home/tew/kernel/Clang-21.0.0"
GCC_64_DIR="/home/tew/kernel/Clang-21.0.0/bin"
GCC_32_DIR="/home/tew/kernel/Clang-21.0.0/bin"
DEFCONFIG="vendor/ginkgo-perf_defconfig"

export PATH="$CLANG_DIR/bin:$PATH"
export LD_LIBRARY_PATH="$CLANG_DIR/lib:$LD_LIBRARY_PATH"
export KBUILD_BUILD_VERSION="1"
export LOCALVERSION

clear
make clean
make mrproper
rm -rf out
rm -rf *.zip
mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG

echo -e "\nStarting compilation...\n"
make -j13 O=out \
					  ARCH=arm64 \
					  CC=clang \
					  LD=ld.lld \
					  AR=llvm-ar \
					  AS=llvm-as \
					  NM=llvm-nm \
					  OBJCOPY=llvm-objcopy \
					  OBJDUMP=llvm-objdump \
					  STRIP=llvm-strip \
					  CROSS_COMPILE=$GCC_64_DIR/aarch64-linux-android- \
					  CROSS_COMPILE_COMPAT=$GCC_32_DIR/arm-linux-gnueabi- \
					  CLANG_TRIPLE=aarch64-linux-gnu- \
					  CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
					  Image.gz-dtb \
					  dtbo.img

kernel="out/arch/arm64/boot/Image.gz-dtb"
dtbo="out/arch/arm64/boot/dtbo.img"

if [ ! -f "$kernel" ] || [ ! -f "$dtbo" ]; then
	echo -e "\nCompilation failed!"
	exit 1
fi

rm -rf AnyKernel3/Image.gz-dtb
rm -rf AnyKernel3/dtbo.img

cp $kernel AnyKernel3
cp $dtbo AnyKernel3

cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
cd ..
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
echo "Zip: $ZIPNAME"
