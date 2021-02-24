#!/bin/bash

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

adb reboot-bootloader && fastboot boot $RDIR/boot.img/out/boot.img && adb logcat -b kernel | tee $RDIR/kernel.log