#!/bin/bash

set -e

timestamp=`date +%s`
find -name "build.log.*" | sort -r | tail -n +3 | xargs rm -f
mv build.log build.log.$timestamp

export ARCH=arm64
export KBUILD_BUILD_USER=BuildUser
export KBUILD_BUILD_HOST=BuildHost
export KBUILD_COMPILER_STRING="LLVM Clang 11.0"

GCC_ARM64_BIN_PATH=$HOME/Toolchains/aarch64-linux-android-4.9/bin
GCC_ARM32_BIN_PATH=$HOME/Toolchains/arm-linux-androideabi-4.9/bin
CLANG_BIN_PATH=$HOME/Toolchains/prebuilt_clang/bin
export PATH=$CLANG_BIN_PATH:$PATH

BUILD_CROSS_COMPILE=$GCC_ARM64_BIN_PATH/aarch64-linux-android-
BUILD_CROSS_COMPILE_COMPAT=$GCC_ARM32_BIN_PATH/arm-linux-androideabi-

CLANG_AR=$CLANG_BIN_PATH/llvm-ar
CLANG_AS=$CLANG_BIN_PATH/clang
CLANG_CC=$CLANG_BIN_PATH/clang
CLANG_LD=$CLANG_BIN_PATH/ld.lld
CLANG_NM=$CLANG_BIN_PATH/llvm-nm
CLANG_OBJCOPY=$CLANG_BIN_PATH/llvm-objcopy
CLANG_OBJDUMP=$CLANG_BIN_PATH/llvm-objdump
CLANG_TRIPLE=aarch64-none-linux-gnu-

CC=$CLANG_CC
LD=$CLANG_LD
AS=$CLANG_AS
AR=$CLANG_AR
NM=$CLANG_NM
OBJCOPY=$CLANG_OBJCOPY
OBJDUMP=$CLANG_OBJDUMP

BUILD_JOB_NUMBER="$(nproc)"
# BUILD_JOB_NUMBER=1

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BUILD_DIR="${RDIR}/.build"
mkdir -p $BUILD_DIR

if [ ! "$(ls -A ${BUILD_DIR})" ]; then
	sudo mount -t tmpfs -o size=10g tmpfs $BUILD_DIR
fi

KERNEL_DEFCONFIG=vendor/instantnoodlep-perf_defconfig
KERNEL_DECORATE_DEFCONFIG=arch/arm64/configs/op8-perf_defconfig
OEM_TARGET_PRODUCT=instantnoodlep
WLAN_DISABLE_BUILD_TAG=y

COMPILE_KERNEL=true
WITH_CFI_CLANG=false

FUNC_MAKE()
{
	cd $RDIR && make -j$BUILD_JOB_NUMBER ARCH=$ARCH SUBARCH=$ARCH \
			O=$BUILD_DIR \
			KCONFIG_DECORATE_CONFIG=$KERNEL_DECORATE_DEFCONFIG \
			OEM_TARGET_PRODUCT=$OEM_TARGET_PRODUCT \
			WLAN_DISABLE_BUILD_TAG=$WLAN_DISABLE_BUILD_TAG \
			CC=$CC \
			AS=$AS \
			LD=$LD \
			AR=$AR \
			NM=$NM \
			OBJCOPY=$OBJCOPY \
			OBJDUMP=$OBJDUMP \
			CROSS_COMPILE="${BUILD_CROSS_COMPILE}" \
			CROSS_COMPILE_COMPAT="${BUILD_CROSS_COMPILE_COMPAT}" \
			CLANG_TRIPLE=$CLANG_TRIPLE \
			LLVM_IAS=1 \
			LLVM=1 \
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

	FUNC_MAKE $KERNEL_DEFCONFIG

	if [[ "$WITH_CFI_CLANG" = "true" ]] ; then
		CC=$CLANG_CC
		LD=$CLANG_LD
		AR=$CLANG_AR
		NM=$CLANG_NM

		echo ""
		echo "Enable CFI_CLANG"

		$RDIR/scripts/config --file $BUILD_DIR/.config \
		-d LTO_NONE \
		-e LTO \
		-e THINLTO \
		-e LTO_CLANG \
		-e CFI_CLANG \
		-e CFI_PERMISSIVE \
		-d CFI_CLANG_SHADOW \
		-e SHADOW_CALL_STACK \
		-d SHADOW_CALL_STACK_VMAP \
		-e TRIM_UNUSED_KSYMS \
		-e UNUSED_KSYMS_WHITELIST_ONLY \
		--set-str UNUSED_KSYMS_WHITELIST "abi_gki_aarch64_qcom_whitelist abi_gki_aarch64_qcom_internal_whitelist abi_gki_aarch64_instantnoodlep_whitelist abi_gki_aarch64_qcom_whitelist abi_gki_aarch64_cuttlefish_whitelist scripts/lto-used-symbollist.txt"

		FUNC_MAKE oldconfig
	fi
	echo ""

	FUNC_MAKE

	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

FUNC_BUILD_DTBO_IMG()
{
	cp "${BUILD_DIR}/arch/${ARCH}/boot/dtbo.img" "${RDIR}/dtbo.img/out/dtbo.img"
	orig_size=$(wc -c < ${RDIR}/dtbo.img/in/dtbo.img)
	truncate -s $orig_size "${RDIR}/dtbo.img/out/dtbo.img"
}

FUNC_BUILD_BOOT_IMG()
{
	cp "${BUILD_DIR}/arch/${ARCH}/boot/Image" "${RDIR}/boot.img/in/split_img/boot.img-zImage"
	cat "${BUILD_DIR}/arch/arm64/boot/dts/vendor/qcom/kona-v2.1.dtb" > "${RDIR}/boot.img/in/split_img/boot.img-dtb"
	cd "${RDIR}/boot.img/in" && $RDIR/aik/repackimg.sh --local --origsize --level 9
	mv "${RDIR}/boot.img/in/image-new.img" "${RDIR}/boot.img/out/boot.img"
}

FUNC_BUILD_RECOVERY_IMG()
{
	cd $RDIR && ./fix_recovery_ramdisk_permission.sh
	cp "${BUILD_DIR}/arch/${ARCH}/boot/Image" "${RDIR}/recovery.img/in/split_img/recovery.img-zImage"
	cp "${BUILD_DIR}/arch/${ARCH}/boot/dtbo.img" "${RDIR}/recovery.img/in/split_img/recovery.img-recovery_dtbo"
	cat "${BUILD_DIR}/arch/arm64/boot/dts/vendor/qcom/kona-v2.1.dtb" > "${RDIR}/recovery.img/in/split_img/recovery.img-dtb"
	cd "${RDIR}/recovery.img/in" && $RDIR/aik/repackimg.sh --local --origsize --level 9
	mv "${RDIR}/recovery.img/in/image-new.img" "${RDIR}/recovery.img/out/recovery.img"
}

# MAIN FUNCTION
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
	FUNC_BUILD_DTBO_IMG
	FUNC_BUILD_BOOT_IMG
	FUNC_BUILD_RECOVERY_IMG

	END_TIME=`date +%s`

	let "ELAPSED_TIME=${END_TIME}-${START_TIME}"
	echo "Total compile time was ${ELAPSED_TIME} seconds"

) 2>&1 | tee -a ./build.log