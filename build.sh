#!/bin/bash

timestamp=`date +%s`
find -name "build.log.*" | sort -r | tail -n +3 | xargs rm
mv build.log build.log.$timestamp

export ARCH=arm64
export KBUILD_BUILD_USER=BuildUser
export KBUILD_BUILD_HOST=BuildHost
export KBUILD_COMPILER_STRING="LLVM Clang 11.0"

GCC_ARM64_BIN_PATH=$HOME/Toolchains/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin
GCC_ARM32_BIN_PATH=$HOME/Toolchains/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin
CLANG_BIN_PATH=$HOME/Toolchains/prebuilt_clang/clang-r383902/bin

BUILD_CROSS_COMPILE=$GCC_ARM64_BIN_PATH/aarch64-none-linux-gnu-
BUILD_CROSS_COMPILE_ARM32=$GCC_ARM32_BIN_PATH/arm-none-linux-gnueabihf-

CLANG_AR=$CLANG_BIN_PATH/llvm-ar
CLANG_CC=$CLANG_BIN_PATH/clang
CLANG_LD=$CLANG_BIN_PATH/ld.lld
CLANG_NM=$CLANG_BIN_PATH/llvm-nm

CC=$CLANG_CC
LD=$CLANG_LD
AR=$CLANG_AR
NM=$CLANG_NM

BUILD_JOB_NUMBER="$(nproc)"
# BUILD_JOB_NUMBER=1

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BUILDDIR="${RDIR}/.build"
mkdir -p $BUILDDIR

KERNEL_DEFCONFIG=vendor/kona-perf_defconfig
KERNEL_DECORATE_DEFCONFIG=arch/arm64/configs/op8-perf_defconfig

FUNC_MAKE()
{
	cd $RDIR && make -j$BUILD_JOB_NUMBER ARCH=$ARCH SUBARCH=$ARCH \
			O=$BUILDDIR \
			KCONFIG_DECORATE_CONFIG=$KERNEL_DECORATE_DEFCONFIG \
			CC=$CC \
			LD=$LD \
			AR=$AR \
			NM=$NM \
			CROSS_COMPILE="${BUILD_CROSS_COMPILE}" \
			CROSS_COMPILE_ARM32="${BUILD_CROSS_COMPILE_ARM32}" \
			$@ || exit 1
}

FUNC_BUILD_KERNEL()
{
	echo ""
	echo "=============================================="
	echo "START : FUNC_BUILD_KERNEL"
	echo "=============================================="
	echo ""
	echo "build common config="${KERNEL_DEFCONFIG}""

	if [[ $# -eq 0 ]]; then
		FUNC_MAKE $KERNEL_DEFCONFIG
	fi

	for var in "$@"
	do
		if [[ "$var" = "--with-cfi-clang" ]] ; then
			CC=$CLANG_CC
			LD=$CLANG_LD
			AR=$CLANG_AR
			NM=$CLANG_NM

			FUNC_MAKE $KERNEL_DEFCONFIG

			echo ""
			echo "Enable CFI_CLANG"
			cd $BUILDDIR && ../scripts/config \
			-e CONFIG_LTO \
			-e CONFIG_THINLTO \
			-d CONFIG_LTO_NONE \
			-e CONFIG_LTO_CLANG \
			-e CONFIG_CFI_CLANG \
			-e CONFIG_CFI_PERMISSIVE \
			-e CONFIG_CFI_CLANG_SHADOW
			continue
        fi
	done
	echo ""

	FUNC_MAKE

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

FUNC_BUILD_BOOT_IMG()
{
	cp "${BUILDDIR}/arch/${ARCH}/boot/Image" "${RDIR}/aik/split_img/boot.img-zImage"
	cat "${BUILDDIR}/arch/arm64/boot/dts/vendor/qcom/kona.dtb" \
		"${BUILDDIR}/arch/arm64/boot/dts/vendor/qcom/kona-v2.dtb" \
		"${BUILDDIR}/arch/arm64/boot/dts/vendor/qcom/kona-v2.1.dtb" > "${RDIR}/aik/split_img/boot.img-dtb"
	cd "${RDIR}/aik"
	./repackimg.sh --nosudo
	cd "${RDIR}/out/"
	cp "${RDIR}/aik/image-new.img" "${RDIR}/out/boot.img"
}

# MAIN FUNCTION
rm -rf ./build.log
(
	START_TIME=`date +%s`

	FUNC_BUILD_KERNEL "$@"
	FUNC_BUILD_BOOT_IMG

	END_TIME=`date +%s`

	let "ELAPSED_TIME=${END_TIME}-${START_TIME}"
	echo "Total compile time was ${ELAPSED_TIME} seconds"

) 2>&1 | tee -a ./build.log