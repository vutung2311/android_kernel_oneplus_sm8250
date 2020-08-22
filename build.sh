#!/bin/bash

timestamp=`date +%s`
find -name "build.log.*" | sort -r | tail -n +3 | xargs rm
mv build.log build.log.$timestamp

export ARCH=arm64
export KBUILD_BUILD_USER=BuildUser
export KBUILD_BUILD_HOST=BuildHost
export KBUILD_COMPILER_STRING="LLVM Clang 11.0"

GCC_ARM64_BIN_PATH=$HOME/Toolchains/aarch64-linux-android-4.9/bin
GCC_ARM32_BIN_PATH=$HOME/Toolchains/arm-linux-androideabi-4.9/bin
CLANG_BIN_PATH=$HOME/Toolchains/prebuilt_clang/bin

BUILD_CROSS_COMPILE=$GCC_ARM64_BIN_PATH/aarch64-linux-android-
BUILD_CROSS_COMPILE_ARM32=$GCC_ARM32_BIN_PATH/arm-linux-androideabi-

CLANG_AR=$CLANG_BIN_PATH/llvm-ar
CLANG_CC=$CLANG_BIN_PATH/clang
CLANG_LD=$CLANG_BIN_PATH/ld.lld
CLANG_NM=$CLANG_BIN_PATH/llvm-nm
CLANG_OBJCOPY=$CLANG_BIN_PATH/llvm-objcopy
CLANG_OBJDUMP=$CLANG_BIN_PATH/llvm-objdump
CLANG_TRIPLE=aarch64-none-linux-gnu-

CC=$CLANG_CC
LD=$CLANG_LD
AR=$CLANG_AR
NM=$CLANG_NM
OBJCOPY=$CLANG_OBJCOPY
OBJDUMP=$CLANG_OBJDUMP

BUILD_JOB_NUMBER="$(nproc)"
# BUILD_JOB_NUMBER=1

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BUILDDIR="${RDIR}/.build"
mkdir -p $BUILDDIR

if [ ! "$(ls -A ${BUILDDIR})" ]; then
	sudo mount -t tmpfs -o size=5g tmpfs ${RDIR}/.build
fi

KERNEL_DEFCONFIG=vendor/kona-perf_defconfig
KERNEL_DECORATE_DEFCONFIG=arch/arm64/configs/op8-perf_defconfig
OEM_TARGET_PRODUCT=instantnoodlep
WLAN_DISABLE_BUILD_TAG=y

COMPILE_KERNEL=true
WITH_CFI_CLANG=false

FUNC_MAKE()
{
	cd $RDIR && make -j$BUILD_JOB_NUMBER ARCH=$ARCH SUBARCH=$ARCH \
			O=$BUILDDIR \
			KCONFIG_DECORATE_CONFIG=$KERNEL_DECORATE_DEFCONFIG \
			OEM_TARGET_PRODUCT=$OEM_TARGET_PRODUCT \
			WLAN_DISABLE_BUILD_TAG=$WLAN_DISABLE_BUILD_TAG \
			CC=$CC \
			LD=$LD \
			AR=$AR \
			NM=$NM \
			OBJCOPY=$OBJCOPY \
			OBJDUMP=$OBJDUMP \
			CROSS_COMPILE="${BUILD_CROSS_COMPILE}" \
			CROSS_COMPILE_ARM32="${BUILD_CROSS_COMPILE_ARM32}" \
			CLANG_TRIPLE=$CLANG_TRIPLE \
			$@ || exit 1
}

FUNC_BUILD_KERNEL()
{
	if [[ "$COMPILE_KERNEL" = "false" ]]; then
		echo ""
		echo "Skip compilling kernel"
		echo ""
		return
	fi

	echo ""
	echo "=============================================="
	echo "START : FUNC_BUILD_KERNEL"
	echo "=============================================="
	echo ""
	echo "build common config="${KERNEL_DEFCONFIG}""

	if [[ $# -eq 0 ]]; then
		FUNC_MAKE $KERNEL_DEFCONFIG
	fi

	if [[ "$WITH_CFI_CLANG" = "true" ]] ; then
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
		-e CONFIG_CFI_CLANG_SHADOW \
		--set-str CONFIG_UNUSED_KSYMS_WHITELIST ""
	fi
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
	cp "${BUILDDIR}/arch/${ARCH}/boot/Image" "${RDIR}/boot.img/in/split_img/boot.img-zImage"
	cat "${BUILDDIR}/arch/arm64/boot/dts/vendor/qcom/kona-v2.1.dtb" > "${RDIR}/boot.img/in/split_img/boot.img-dtb"
	(cd "${RDIR}/boot.img/in" && $RDIR/aik/repackimg.sh --local --level 9)
	mv "${RDIR}/boot.img/in/image-new.img" "${RDIR}/boot.img/out/boot.img"
}

FUNC_BUILD_RECOVERY_IMG()
{
	cd $RDIR && ./fix_ramdisk_permission.sh
	cp "${BUILDDIR}/arch/${ARCH}/boot/Image" "${RDIR}/recovery.img/in/split_img/recovery.img-zImage"
	cp "${BUILDDIR}/arch/${ARCH}/boot/dtbo.img" "${RDIR}/recovery.img/in/split_img/recovery.img-recovery_dtbo"
	cat "${BUILDDIR}/arch/arm64/boot/dts/vendor/qcom/kona-v2.1.dtb" > "${RDIR}/recovery.img/in/split_img/recovery.img-dtb"
	(cd "${RDIR}/recovery.img/in" && $RDIR/aik/repackimg.sh --local --level 9)
	mv "${RDIR}/recovery.img/in/image-new.img" "${RDIR}/recovery.img/out/recovery.img"
}

# MAIN FUNCTION
rm -rf ./build.log
(
	START_TIME=`date +%s`

	for var in "$@"
	do
		case $var in
			"--with-cfi-clang")
				WITH_CFI_CLANG=true
			;;
			"--packaging-only")
				COMPILE_KERNEL=false
			;;
		esac
	done

	FUNC_BUILD_KERNEL "$@"
	FUNC_BUILD_BOOT_IMG
	FUNC_BUILD_RECOVERY_IMG

	END_TIME=`date +%s`

	let "ELAPSED_TIME=${END_TIME}-${START_TIME}"
	echo "Total compile time was ${ELAPSED_TIME} seconds"

) 2>&1 | tee -a ./build.log