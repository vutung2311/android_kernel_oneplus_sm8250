#!/bin/bash

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

fastboot flash dtbo $RDIR/.build/arch/arm64/boot/dtbo.img
fastboot flash --slot=all boot $RDIR/boot.img/out/boot.img