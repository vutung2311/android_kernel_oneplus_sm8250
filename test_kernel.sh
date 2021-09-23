#!/bin/bash

FASTBOOT=$(./get_fastboot.sh)
ADB=$(./get_adb.sh)

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$ADB reboot-bootloader && $FASTBOOT boot $RDIR/boot.img/out/boot.img && $ADB logcat -b kernel | tee $RDIR/kernel.log