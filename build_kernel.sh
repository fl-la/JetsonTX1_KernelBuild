#!/bin/bash

# To change kernel version edit the top level makefile of the kernel
# possible user settings
COMPILER_MAJOR_VERSION="5"
COMPILER_VERSION_DETAIL="gcc-linaro-5.4.1-2017.05-x86_64_aarch64-linux-gnu"
NVIDIA_KERNEL_VERSION="24-2-1"

# DO NOT CHANGE BELOW THIS LINE
COMPILER_PATH=""
KERNEL_UTS=""
MODULES_PATH=""


mkdir -p src
mkdir -p compiler
mkdir -p deploy

# first getting the compiler
cd compiler
wget https://releases.linaro.org/components/toolchain/binaries/latest-$COMPILER_MAJOR_VERSION/aarch64-linux-gnu/$COMPILER_VERSION_DETAIL.tar.xz
tar -xvf $COMPILER_VERSION_DETAIL.tar.xz
# saving the compiler path
COMPILER_PATH=$(pwd)/$COMPILER_VERSION_DETAIL/bin/aarch64-linux-gnu-
echo $COMPILER_PATH

#getting the kernel sources from nvidia
cd ../src
wget --no-check-certificate http://developer.nvidia.com/embedded/dlc/l4t-sources-$NVIDIA_KERNEL_VERSION -O l4t-sources-$NVIDIA_KERNEL_VERSION.tbz2
tar -xvf l4t-sources-$NVIDIA_KERNEL_VERSION.tbz2 sources/kernel_src.tbz2
tar -xvf sources/kernel_src.tbz2
cd ..
cp tegra_kernel_default_config src/kernel/.config

#patching and building the kernel
patch src/kernel/drivers/platform/tegra/tegra21_clocks.c tegraClocks.patch
tar -xvf vdso32Files.tbz2
cp vgettimeofday.o src/kernel/arch/arm64/kernel/vdso32
cd src/kernel
make ARCH=arm64 CROSS_COMPILE=$COMPILER_PATH prepare
make ARCH=arm64 CROSS_COMPILE=$COMPILER_PATH modules_prepare
make ARCH=arm64 CROSS_COMPILE=$COMPILER_PATH -j2
cd ../..
cp vdso32.so.dbg src/kernel/arch/arm64/kernel/vdso32
cd src/kernel
#make ARCH=arm64 CROSS_COMPILE=$COMPILER_PATH make_modules
make ARCH=arm64 CROSS_COMPILE=$COMPILER_PATH -j2
#make ARCH=arm64 CROSS_COMPILE=$COMPILER_PATH moduels_install INSTALL_MOD_PATH=

KERNEL_UTS=$(cat "include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )

cd ../..
rm vgettimeofday.o
rm vdso32.so.dbg

# now copy all relevant files and modules into the deploy folder
cp src/kernel/arch/arm64/boot/Image deploy #kernel images
cp src/kernel/arch/arm64/boot/zImage deploy 
# kernel modules
MODULES_PATH=deploy/kernel_modules/lib/modules/$KERNEL_UTS
mkdir -p $MODULES_PATH
while read p; do
	mkdir -p $MODULES_PATH/$(dirname $p) 
	cp src/$p $MODULES_PATH/$(dirname $p)
done < src/kernel/modules.order
cd deploy/kernel_modules
tar -cf kernel_modules.tar *
cp kernel_modules.tar ../
cd ..
rm -rf kernel_modules
